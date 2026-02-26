"""
Coupang product parser.

Coupang uses aggressive Akamai bot protection that blocks:
- httpx/requests (403)
- curl (403)
- Playwright headless & non-headless (Access Denied)
- curl_cffi with TLS impersonation (JS challenge)

Strategy:
1. Try curl_cffi with session cookies (best chance)
2. Try Playwright as fallback
3. If blocked, return clear error with guidance
"""

import re
import json
from bs4 import BeautifulSoup


def _normalize_image(src: str | None) -> str | None:
    if not src:
        return None
    if src.startswith("//"):
        return "https:" + src
    return src


def _parse_price(text: str) -> int | None:
    if not text:
        return None
    cleaned = re.sub(r"[^\d]", "", text)
    return int(cleaned) if cleaned else None


def _extract_json_ld(soup: BeautifulSoup) -> dict | None:
    """Extract JSON-LD Product data from script tags."""
    try:
        scripts = soup.find_all("script", {"type": "application/ld+json"})
        for script in scripts:
            try:
                data = json.loads(script.string)
                if isinstance(data, dict) and data.get("@type") == "Product":
                    return data
                if isinstance(data, list):
                    for item in data:
                        if isinstance(item, dict) and item.get("@type") == "Product":
                            return item
            except (json.JSONDecodeError, TypeError):
                continue
    except Exception:
        pass
    return None


def _parse_html(html: str, url: str) -> dict:
    """Parse Coupang product HTML into structured data."""
    result = {
        "productName": None,
        "brandName": None,
        "originalPrice": None,
        "description": None,
        "category": None,
        "origin": None,
        "weight": None,
        "mainImage": None,
        "galleryImages": [],
        "detailImages": [],
        "options": [],
        "sourceUrl": url,
        "detectedSite": "쿠팡",
    }

    soup = BeautifulSoup(html, "lxml")
    json_ld = _extract_json_ld(soup)

    # productName
    if json_ld and json_ld.get("name"):
        result["productName"] = json_ld["name"]
    else:
        for sel in [
            "h2.prod-buy-header__title",
            "span.prod-buy-header__title",
            "h1.prod-buy-header__title",
            ".prod-buy-header__title",
        ]:
            tag = soup.select_one(sel)
            if tag:
                result["productName"] = tag.get_text(strip=True)
                break
        if not result["productName"]:
            og_title = soup.find("meta", property="og:title")
            if og_title and og_title.get("content"):
                result["productName"] = og_title["content"].strip()

    # brandName
    brand_tag = soup.select_one("a.prod-brand-name")
    if brand_tag:
        result["brandName"] = brand_tag.get_text(strip=True)
    elif json_ld and json_ld.get("brand"):
        brand = json_ld["brand"]
        result["brandName"] = brand.get("name", brand) if isinstance(brand, dict) else str(brand)

    # originalPrice
    if json_ld and json_ld.get("offers"):
        offers = json_ld["offers"]
        if isinstance(offers, dict):
            price = offers.get("price") or offers.get("lowPrice")
            if price:
                try:
                    result["originalPrice"] = int(float(str(price)))
                except (ValueError, TypeError):
                    pass
    if not result["originalPrice"]:
        for sel in [
            "span.total-price strong",
            "span.origin-price",
            ".prod-sale-price .total-price",
            ".prod-price .total-price strong",
        ]:
            tag = soup.select_one(sel)
            if tag:
                result["originalPrice"] = _parse_price(tag.get_text())
                if result["originalPrice"]:
                    break

    # description
    og_desc = soup.find("meta", property="og:description")
    if og_desc and og_desc.get("content"):
        result["description"] = og_desc["content"].strip()

    # mainImage
    og_image = soup.find("meta", property="og:image")
    if og_image and og_image.get("content"):
        result["mainImage"] = _normalize_image(og_image["content"])
    else:
        for sel in ["div.prod-image img", "#repImageContainer img", "img.prod-image__detail"]:
            tag = soup.select_one(sel)
            if tag:
                src = tag.get("src") or tag.get("data-src")
                result["mainImage"] = _normalize_image(src)
                if result["mainImage"]:
                    break

    # galleryImages
    gallery_imgs = (
        soup.select("div.prod-image__items img")
        or soup.select("ul.prod-thumbnail__list img")
        or soup.select("li.prod-image__item img")
    )
    gallery = []
    for img in gallery_imgs:
        src = _normalize_image(img.get("src") or img.get("data-src"))
        if src and src not in gallery:
            full = re.sub(r"/thumbnails/remote/\d+x\d+ex/", "/thumbnails/remote/600x600ex/", src)
            gallery.append(full)
    result["galleryImages"] = gallery

    # detailImages
    detail_container = (
        soup.select_one("#productDetail")
        or soup.select_one("div.product-detail-content-inside")
        or soup.select_one("div.product-detail__content")
        or soup.select_one("#btfContent")
    )
    if detail_container:
        details = []
        for img in detail_container.select("img"):
            src = _normalize_image(img.get("src") or img.get("data-src") or img.get("data-img"))
            if src and src not in details:
                details.append(src)
        result["detailImages"] = details

    # category
    breadcrumbs = soup.select("ul.breadcrumb li a")
    if breadcrumbs:
        result["category"] = " > ".join(a.get_text(strip=True) for a in breadcrumbs)

    # origin & weight
    attr_rows = soup.select("table.prod-attr-table tr, div.prod-attr-item, li.prod-attr-item")
    for row in attr_rows:
        text = row.get_text()
        if "원산지" in text and not result["origin"]:
            parts = row.get_text(separator="|").split("|")
            for i, part in enumerate(parts):
                if "원산지" in part and i + 1 < len(parts):
                    result["origin"] = parts[i + 1].strip()
                    break
        if ("중량" in text or "용량" in text) and not result["weight"]:
            parts = row.get_text(separator="|").split("|")
            for i, part in enumerate(parts):
                if ("중량" in part or "용량" in part) and i + 1 < len(parts):
                    result["weight"] = parts[i + 1].strip()
                    break

    # options
    option_items = soup.select("ul.prod-option__item li")
    if option_items:
        result["options"] = [
            item.get_text(strip=True) for item in option_items if item.get_text(strip=True)
        ]

    return result


async def _try_curl_cffi(url: str) -> str | None:
    """Try fetching with curl_cffi (TLS fingerprint impersonation)."""
    try:
        from curl_cffi import requests as cffi_requests

        session = cffi_requests.Session(impersonate="chrome")
        # Warm up with homepage cookies
        session.get("https://www.coupang.com/", headers={
            "Accept-Language": "ko-KR,ko;q=0.9",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        })
        # Fetch product page
        r = session.get(url, headers={
            "Accept-Language": "ko-KR,ko;q=0.9",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Referer": "https://www.coupang.com/",
        })
        if r.status_code == 200 and len(r.text) > 5000:
            if "prod-buy-header" in r.text or "og:title" in r.text:
                return r.text
    except Exception as e:
        print(f"[coupang] curl_cffi error: {e}")
    return None


async def _try_playwright(url: str) -> str | None:
    """Try fetching with Playwright headless browser."""
    try:
        from playwright.async_api import async_playwright
    except ImportError:
        return None

    try:
        async with async_playwright() as p:
            browser = await p.chromium.launch(
                headless=True,
                args=["--disable-blink-features=AutomationControlled"],
            )
            context = await browser.new_context(
                user_agent=(
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/131.0.0.0 Safari/537.36"
                ),
                locale="ko-KR",
                viewport={"width": 1920, "height": 1080},
            )
            page = await context.new_page()
            await page.add_init_script(
                'Object.defineProperty(navigator, "webdriver", {get: () => undefined});'
            )
            await page.route("**/*.{mp4,webm,ogg,mp3,wav}", lambda route: route.abort())

            try:
                await page.goto(url, wait_until="domcontentloaded", timeout=20000)
                await page.wait_for_timeout(3000)
                await page.evaluate("window.scrollTo(0, document.body.scrollHeight / 2)")
                await page.wait_for_timeout(1000)
                await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                await page.wait_for_timeout(1000)
                html = await page.content()
            finally:
                await browser.close()

            if "Access Denied" in html or len(html) < 1000:
                return None
            return html
    except Exception as e:
        print(f"[coupang] Playwright error: {e}")
    return None


async def parse_coupang(url: str) -> dict:
    """
    Parse a Coupang product page.
    Tries multiple methods to bypass bot protection.
    """
    # Method 1: curl_cffi
    print(f"[coupang] Trying curl_cffi for {url}")
    html = await _try_curl_cffi(url)

    # Method 2: Playwright
    if not html:
        print("[coupang] curl_cffi failed, trying Playwright...")
        html = await _try_playwright(url)

    # Both failed — Akamai blocked us
    if not html:
        raise RuntimeError(
            "쿠팡의 보안 시스템(Akamai)에 의해 자동 접근이 차단되었습니다. "
            "상품 정보를 직접 입력해 주세요."
        )

    return _parse_html(html, url)
