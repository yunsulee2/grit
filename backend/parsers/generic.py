"""
Generic product page parser for food brands and other e-commerce sites.

Layered approach:
1. httpx (fastest, works for simple sites with OG tags / JSON-LD)
2. curl_cffi (TLS fingerprint impersonation, bypasses basic WAF)
3. Playwright headless (JS rendering for SPAs)
4. nodriver (real Chrome, for heavily protected sites)

Optimized for Korean food brand websites:
- Cafe24 / Godomall / Makeshop platforms
- 마켓컬리, 오아시스마켓, SSG, etc.
"""

import re
import json
import httpx
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0.0.0 Safari/537.36"
    ),
    "Accept": (
        "text/html,application/xhtml+xml,application/xml;"
        "q=0.9,image/avif,image/webp,*/*;q=0.8"
    ),
    "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
    "Accept-Encoding": "gzip, deflate, br",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1",
}


def _normalize_image(src: str | None) -> str | None:
    if not src:
        return None
    src = src.strip()
    if src.startswith("//"):
        return "https:" + src
    if not src.startswith("http"):
        return None
    return src


def _parse_price(text: str) -> int | None:
    if not text:
        return None
    cleaned = re.sub(r"[^\d]", "", text)
    return int(cleaned) if cleaned else None


def _is_blocked(html: str) -> bool:
    """Check if the response is a block/challenge page."""
    indicators = [
        "Access Denied",
        "보안 확인을 완료해 주세요",
        "captcha",
        "challenge",
        "bot detection",
        "에러페이지",
        "Just a moment",
        "Checking your browser",
    ]
    lower = html[:3000].lower()
    return any(ind.lower() in lower for ind in indicators)


def _extract_json_ld(soup: BeautifulSoup) -> dict | None:
    """Extract JSON-LD Product data."""
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


def _extract_from_soup(soup: BeautifulSoup, url: str) -> dict:
    """Extract product data from a BeautifulSoup parsed page."""
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
        "detectedSite": "other",
    }

    json_ld = _extract_json_ld(soup)

    # productName — JSON-LD > HTML selectors > og:title > title tag
    if json_ld and json_ld.get("name"):
        result["productName"] = json_ld["name"]
    else:
        # Try common product name selectors first (more specific than og/title)
        for sel in [
            "h1[class*=product]", "h1[class*=goods]", "h1[class*=item]",
            "h2[class*=product]", "h2[class*=goods]", "h2[class*=item]",
            "[class*=product-name]", "[class*=product_name]",
            "[class*=goods-name]", "[class*=goods_name]",
            "[class*=item-name]", "[class*=item_name]",
            "[itemprop=name]",
            "h1", "h2",
        ]:
            tag = soup.select_one(sel)
            if tag:
                text = tag.get_text(strip=True)
                # Skip very short or site-title-like names
                if text and len(text) > 2 and len(text) < 200:
                    result["productName"] = text
                    break

        if not result["productName"]:
            og_title = soup.find("meta", property="og:title")
            if og_title and og_title.get("content"):
                result["productName"] = og_title["content"].strip()
            else:
                title_tag = soup.find("title")
                if title_tag:
                    result["productName"] = title_tag.get_text(strip=True)

    # brandName
    if json_ld and json_ld.get("brand"):
        brand = json_ld["brand"]
        result["brandName"] = brand.get("name", brand) if isinstance(brand, dict) else str(brand)
    else:
        brand_meta = soup.find("meta", {"property": "product:brand"})
        if brand_meta and brand_meta.get("content"):
            result["brandName"] = brand_meta["content"].strip()

    # originalPrice — multiple extraction strategies
    if json_ld and json_ld.get("offers"):
        offers = json_ld["offers"]
        if isinstance(offers, dict):
            price = offers.get("price") or offers.get("lowPrice")
            if price:
                try:
                    result["originalPrice"] = int(float(str(price)))
                except (ValueError, TypeError):
                    pass
        elif isinstance(offers, list) and offers:
            price = offers[0].get("price")
            if price:
                try:
                    result["originalPrice"] = int(float(str(price)))
                except (ValueError, TypeError):
                    pass

    if not result["originalPrice"]:
        price_meta = soup.find("meta", {"property": "product:price:amount"})
        if price_meta and price_meta.get("content"):
            result["originalPrice"] = _parse_price(price_meta["content"])

    if not result["originalPrice"]:
        price_tag = soup.find(attrs={"itemprop": "price"})
        if price_tag:
            price_val = price_tag.get("content") or price_tag.get_text()
            result["originalPrice"] = _parse_price(price_val)

    if not result["originalPrice"]:
        price_candidates = soup.find_all(class_=re.compile(r"price", re.IGNORECASE))
        for candidate in price_candidates[:5]:
            text = candidate.get_text(strip=True)
            parsed = _parse_price(text)
            if parsed and 100 <= parsed <= 100_000_000:
                result["originalPrice"] = parsed
                break

    # mainImage — JSON-LD > product image selectors > og:image
    if json_ld and json_ld.get("image"):
        img = json_ld["image"]
        if isinstance(img, list):
            img = img[0] if img else None
        result["mainImage"] = _normalize_image(str(img)) if img else None

    if not result["mainImage"]:
        # Try common product image selectors
        for sel in [
            "[class*=product-image] img", "[class*=product_image] img",
            "[class*=goods-image] img", "[class*=goods_image] img",
            "[class*=item-image] img", "[class*=item_image] img",
            "[class*=prd-image] img", "[class*=prd_image] img",
            "[class*=thumb-image] img", "[class*=main-image] img",
            "[itemprop=image]",
            "div.product img", "div.goods img",
        ]:
            tag = soup.select_one(sel)
            if tag:
                src = tag.get("src") or tag.get("data-src") or tag.get("content")
                normalized = _normalize_image(src)
                if normalized and "logo" not in normalized.lower():
                    result["mainImage"] = normalized
                    break

    if not result["mainImage"]:
        og_image = soup.find("meta", property="og:image")
        if og_image and og_image.get("content"):
            img_url = _normalize_image(og_image["content"].strip())
            # Skip obvious logos/icons
            if img_url and "logo" not in img_url.lower() and "icon" not in img_url.lower():
                result["mainImage"] = img_url

    # description
    og_desc = soup.find("meta", property="og:description")
    if og_desc and og_desc.get("content"):
        result["description"] = og_desc["content"].strip()
    else:
        meta_desc = soup.find("meta", {"name": "description"})
        if meta_desc and meta_desc.get("content"):
            result["description"] = meta_desc["content"].strip()

    # galleryImages from JSON-LD
    if json_ld and json_ld.get("image"):
        imgs = json_ld["image"]
        if isinstance(imgs, list):
            for img in imgs:
                normalized = _normalize_image(str(img))
                if normalized and normalized not in result["galleryImages"]:
                    result["galleryImages"].append(normalized)

    # detailImages — comprehensive selectors for food brand sites
    detail_selectors = [
        # Common e-commerce detail containers
        "#prdDetail img",
        "div.detail_wrap img",
        "div.detail_area img",
        "div.product-detail img",
        "div.goods_description img",
        "div.item_detail_cont img",
        # Korean platforms (Cafe24, Godomall, Makeshop)
        "div.detail_cont img",
        "div#goods_description img",
        "div.goods-body img",
        "div.txt-manual img",
        "div.product_detail_desc img",
        # Generic fallback
        "main img",
        "article img",
    ]

    main_content = (
        soup.find("main")
        or soup.find("article")
        or soup.find(id=re.compile(r"(content|detail|product|prdDetail)", re.IGNORECASE))
        or soup.find(class_=re.compile(r"(content|detail|product|goods)", re.IGNORECASE))
    )

    # Try specific detail selectors first
    for selector in detail_selectors:
        try:
            imgs = soup.select(selector)
            if imgs and len(imgs) >= 2:
                seen = set()
                for img in imgs:
                    src = _normalize_image(
                        img.get("src") or img.get("data-src") or img.get("data-lazy-src") or img.get("data-original")
                    )
                    if src and src not in seen and not src.endswith((".svg", ".gif", ".ico")):
                        seen.add(src)
                        result["detailImages"].append(src)
                if result["detailImages"]:
                    break
        except Exception:
            continue

    # Fallback to main content area
    if not result["detailImages"] and main_content:
        seen = set()
        for img in main_content.select("img"):
            src = _normalize_image(
                img.get("src") or img.get("data-src") or img.get("data-lazy-src")
            )
            if src and src not in seen and not src.endswith((".svg", ".gif", ".ico")):
                seen.add(src)
                result["detailImages"].append(src)

    return result


async def _fetch_with_httpx(url: str) -> str | None:
    """Fetch page with httpx. Returns HTML or None if blocked."""
    try:
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            response = await client.get(url, headers=HEADERS)
            if response.status_code == 403:
                return None
            response.raise_for_status()
            html = response.text
            if _is_blocked(html):
                return None
            if len(html) < 500:
                return None
            return html
    except Exception:
        return None


async def _fetch_with_curl(url: str) -> str | None:
    """Fetch page with curl_cffi (TLS fingerprint impersonation)."""
    try:
        from parsers.http_client import fetch_with_curl
        return await fetch_with_curl(url)
    except Exception as e:
        print(f"[generic] curl_cffi failed: {e}")
        return None


async def _fetch_with_nodriver(url: str) -> str | None:
    """Fetch page with nodriver (real Chrome, anti-detection). Scrolls for lazy loading."""
    try:
        from parsers.browser import fetch_with_nodriver
        html = await fetch_with_nodriver(url, wait_seconds=7)
        return html
    except Exception as e:
        print(f"[generic] nodriver failed: {e}")
        return None


async def _fetch_with_playwright(url: str) -> str | None:
    """Fetch page with Playwright headless."""
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
                user_agent=HEADERS["User-Agent"],
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
                # Scroll progressively to trigger lazy loading
                for scroll_pct in [0.3, 0.5, 0.7, 1.0]:
                    await page.evaluate(
                        f"window.scrollTo(0, document.body.scrollHeight * {scroll_pct})"
                    )
                    await page.wait_for_timeout(800)
                # Scroll back to top for main content
                await page.evaluate("window.scrollTo(0, 0)")
                await page.wait_for_timeout(500)
                html = await page.content()
            finally:
                await browser.close()

            if _is_blocked(html):
                return None
            if len(html) < 500:
                return None
            return html
    except Exception:
        return None


def _has_meaningful_data(result: dict) -> bool:
    """Check if extracted data has meaningful product info (not just site titles)."""
    name = result.get("productName")
    price = result.get("originalPrice")
    image = result.get("mainImage")
    detail_images = result.get("detailImages", [])

    if not name:
        return False

    # Reject obvious site titles (short generic names ending with 몰/샵/마켓 etc.)
    name_lower = name.lower().strip()
    site_title_indicators = ["몰", "샵", "마켓", "스토어", "공식몰", "공식 몰", "official"]
    is_likely_site_title = (
        len(name_lower) < 15
        and any(name_lower.endswith(ind) for ind in site_title_indicators)
    )
    if is_likely_site_title and not price and not detail_images:
        return False

    return bool(price or image or detail_images)


async def parse_generic(url: str) -> dict:
    """
    Parse any product page using a layered approach:
    1. httpx (fastest, works for most food brand sites)
    2. curl_cffi (TLS impersonation, for sites with basic WAF)
    3. Playwright (JS rendering for SPAs)
    4. nodriver (real Chrome, for heavily protected sites)
    """
    # Layer 1: httpx (fastest)
    html = await _fetch_with_httpx(url)
    if html:
        soup = BeautifulSoup(html, "lxml")
        result = _extract_from_soup(soup, url)
        if _has_meaningful_data(result):
            print(f"[generic] httpx succeeded for {url}")
            return result
        print("[generic] httpx got HTML but no meaningful data, escalating...")

    # Layer 2: curl_cffi (TLS fingerprint bypass)
    print(f"[generic] Trying curl_cffi for {url}...")
    html = await _fetch_with_curl(url)
    if html:
        soup = BeautifulSoup(html, "lxml")
        result = _extract_from_soup(soup, url)
        if _has_meaningful_data(result):
            print(f"[generic] curl_cffi succeeded for {url}")
            return result
        print("[generic] curl_cffi got HTML but no meaningful data, escalating...")

    # Layer 3: Playwright (JS rendering)
    print(f"[generic] Trying Playwright for {url}...")
    playwright_result = None
    html = await _fetch_with_playwright(url)
    if html:
        soup = BeautifulSoup(html, "lxml")
        playwright_result = _extract_from_soup(soup, url)
        if _has_meaningful_data(playwright_result):
            # Check if we got actual product data (not just site title + logo)
            has_real_image = bool(
                playwright_result.get("mainImage")
                and "logo" not in (playwright_result["mainImage"] or "").lower()
            )
            has_detail = bool(playwright_result.get("detailImages"))
            if has_real_image or has_detail:
                print(f"[generic] Playwright succeeded for {url}")
                return playwright_result
            print("[generic] Playwright got partial data, trying nodriver for better results...")
        else:
            print("[generic] Playwright got HTML but no meaningful data, escalating...")

    # Layer 4: nodriver (real Chrome, anti-detection)
    print(f"[generic] Trying nodriver for {url}...")
    html = await _fetch_with_nodriver(url)
    if html:
        soup = BeautifulSoup(html, "lxml")
        result = _extract_from_soup(soup, url)
        if _has_meaningful_data(result):
            print(f"[generic] nodriver succeeded for {url}")
            return result
        print("[generic] nodriver got HTML but limited data")
        # Return whichever result has more data
        if playwright_result and _has_meaningful_data(playwright_result):
            return playwright_result
        return result

    # Return Playwright result if available (even partial)
    if playwright_result:
        return playwright_result

    raise RuntimeError(
        "이 사이트에서 상품 정보를 가져올 수 없습니다. "
        "상품 정보를 직접 입력해 주세요."
    )
