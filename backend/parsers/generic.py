"""
Generic product page parser.

Layered approach:
1. httpx with browser-like headers → extract OG meta + JSON-LD + structured data
2. If httpx blocked/fails → try Playwright headless
3. If both fail → return partial data with error info
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
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
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

    # Try JSON-LD first (richest data source)
    json_ld = _extract_json_ld(soup)

    # productName
    if json_ld and json_ld.get("name"):
        result["productName"] = json_ld["name"]
    else:
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
        elif isinstance(offers, list) and offers:
            price = offers[0].get("price")
            if price:
                try:
                    result["originalPrice"] = int(float(str(price)))
                except (ValueError, TypeError):
                    pass

    if not result["originalPrice"]:
        # Try product:price:amount meta
        price_meta = soup.find("meta", {"property": "product:price:amount"})
        if price_meta and price_meta.get("content"):
            result["originalPrice"] = _parse_price(price_meta["content"])

    if not result["originalPrice"]:
        # Try itemprop="price"
        price_tag = soup.find(attrs={"itemprop": "price"})
        if price_tag:
            price_val = price_tag.get("content") or price_tag.get_text()
            result["originalPrice"] = _parse_price(price_val)

    if not result["originalPrice"]:
        # Fallback: class containing "price"
        price_candidates = soup.find_all(class_=re.compile(r"price", re.IGNORECASE))
        for candidate in price_candidates[:5]:
            text = candidate.get_text(strip=True)
            parsed = _parse_price(text)
            if parsed and 100 <= parsed <= 100_000_000:
                result["originalPrice"] = parsed
                break

    # mainImage
    if json_ld and json_ld.get("image"):
        img = json_ld["image"]
        if isinstance(img, list):
            img = img[0] if img else None
        result["mainImage"] = _normalize_image(str(img)) if img else None

    if not result["mainImage"]:
        og_image = soup.find("meta", property="og:image")
        if og_image and og_image.get("content"):
            result["mainImage"] = _normalize_image(og_image["content"].strip())

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

    # detailImages from main content
    main_content = (
        soup.find("main")
        or soup.find("article")
        or soup.find(id=re.compile(r"(content|detail|product)", re.IGNORECASE))
        or soup.find(class_=re.compile(r"(content|detail|product)", re.IGNORECASE))
    )
    if main_content:
        imgs = main_content.select("img")
        seen = set()
        for img in imgs:
            src = _normalize_image(img.get("src") or img.get("data-src") or img.get("data-lazy-src"))
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


async def _fetch_with_playwright(url: str) -> str | None:
    """Fetch page with Playwright headless. Returns HTML or None if blocked."""
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

            # Block heavy resources
            await page.route("**/*.{mp4,webm,ogg,mp3,wav}", lambda route: route.abort())

            try:
                await page.goto(url, wait_until="domcontentloaded", timeout=20000)
                await page.wait_for_timeout(3000)

                # Scroll to trigger lazy loading
                await page.evaluate("window.scrollTo(0, document.body.scrollHeight / 2)")
                await page.wait_for_timeout(1000)

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


async def parse_generic(url: str) -> dict:
    """
    Parse any product page using a layered approach:
    1. httpx (fast, works for most sites)
    2. Playwright (for JS-rendered sites)
    3. Error with guidance if both fail
    """
    # Layer 1: Try httpx
    html = await _fetch_with_httpx(url)

    # Layer 2: Try Playwright if httpx failed
    if not html:
        print(f"[generic] httpx failed for {url}, trying Playwright...")
        html = await _fetch_with_playwright(url)

    # Both failed
    if not html:
        raise RuntimeError(
            "이 사이트는 자동 접근이 차단되어 있습니다. "
            "상품 정보를 직접 입력해 주세요."
        )

    soup = BeautifulSoup(html, "lxml")
    return _extract_from_soup(soup, url)
