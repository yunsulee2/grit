"""
Naver SmartStore / Brand Store product page parser.

Strategy:
1. curl_cffi with Chrome TLS impersonation → parse __NEXT_DATA__ or OG tags
2. nodriver (real Chrome) fallback for heavily protected pages

Handles:
- smartstore.naver.com/{store}/products/{id}
- brand.naver.com/{brand}/products/{id}
- shopping.naver.com product pages
"""

import json
import re
from bs4 import BeautifulSoup


def _ensure_https(url: str) -> str:
    if not url:
        return ""
    if url.startswith("//"):
        return "https:" + url
    return url


def _parse_price(val) -> int | None:
    if val is None:
        return None
    if isinstance(val, (int, float)):
        return int(val)
    cleaned = re.sub(r"[^\d]", "", str(val))
    return int(cleaned) if cleaned else None


def _deep_get(data: dict, *keys, default=None):
    """Safely traverse nested dict keys."""
    current = data
    for key in keys:
        if isinstance(current, dict):
            current = current.get(key)
        else:
            return default
        if current is None:
            return default
    return current


def _extract_next_data(html: str) -> dict:
    """Extract __NEXT_DATA__ JSON from Next.js SSR page."""
    pattern = re.compile(
        r'<script\s+id="__NEXT_DATA__"[^>]*>(.*?)</script>',
        re.DOTALL,
    )
    match = pattern.search(html)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass
    return {}


def _extract_preloaded_state(html: str) -> dict:
    """Extract window.__PRELOADED_STATE__ from script tags."""
    pattern = re.compile(
        r"window\.__PRELOADED_STATE__\s*=\s*(\{.*?\})(?:\s*;|\s*</script>)",
        re.DOTALL,
    )
    match = pattern.search(html)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass
    return {}


def _extract_json_ld(soup: BeautifulSoup) -> dict:
    """Extract JSON-LD product data."""
    for tag in soup.find_all("script", type="application/ld+json"):
        try:
            data = json.loads(tag.string or "")
            if isinstance(data, list):
                for item in data:
                    if isinstance(item, dict) and item.get("@type") == "Product":
                        return item
                data = data[0] if data else {}
            if isinstance(data, dict):
                return data
        except (json.JSONDecodeError, IndexError):
            continue
    return {}


def _extract_meta(soup: BeautifulSoup, prop: str) -> str | None:
    tag = soup.find("meta", property=prop) or soup.find("meta", attrs={"name": prop})
    return (tag.get("content") or None) if tag else None


def _parse_html(html: str, url: str) -> dict:
    """Parse Naver product page HTML into structured data."""
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
        "detectedSite": "네이버",
    }

    soup = BeautifulSoup(html, "lxml")
    json_ld = _extract_json_ld(soup)
    next_data = _extract_next_data(html)
    preloaded = _extract_preloaded_state(html)

    # Try to find product data from embedded JSON (most complete source)
    product = (
        _deep_get(next_data, "props", "pageProps", "product")
        or _deep_get(next_data, "props", "pageProps", "productDetail")
        or _deep_get(next_data, "props", "pageProps", "data", "product")
        or _deep_get(next_data, "props", "initialState", "product")
        or {}
    )

    # __PRELOADED_STATE__ paths (older SmartStore pages)
    if not product:
        product = (
            _deep_get(preloaded, "product", "A", "productInfo")
            or _deep_get(preloaded, "product", "productInfo")
            or {}
        )

    # ── productName ──────────────────────────────────────────────
    result["productName"] = (
        product.get("name")
        or product.get("productName")
        or json_ld.get("name")
        or _extract_meta(soup, "og:title")
        or (soup.find("title").get_text(strip=True) if soup.find("title") else None)
    )

    # ── brandName ────────────────────────────────────────────────
    brand = (
        product.get("brandName")
        or product.get("storeName")
        or product.get("channelName")
    )
    if not brand:
        brand_ld = json_ld.get("brand")
        if isinstance(brand_ld, dict):
            brand = brand_ld.get("name")
        elif isinstance(brand_ld, str):
            brand = brand_ld
    if not brand:
        for sel in [
            "a._2bCBl", "span._2bCBl",
            "a[class*='seller']", "span[class*='store']",
            "span[class*='sellerName']", "a[class*='storeName']",
        ]:
            tag = soup.select_one(sel)
            if tag:
                brand = tag.get_text(strip=True)
                break
    result["brandName"] = brand

    # ── originalPrice ────────────────────────────────────────────
    price = (
        _parse_price(product.get("salePrice"))
        or _parse_price(product.get("price"))
        or _parse_price(product.get("discountedSalePrice"))
        or _parse_price(product.get("promotionPrice"))
    )
    if not price:
        offers = json_ld.get("offers", {})
        if isinstance(offers, list):
            offers = offers[0] if offers else {}
        if isinstance(offers, dict):
            price = _parse_price(offers.get("price") or offers.get("lowPrice"))
    if not price:
        price = _parse_price(
            _extract_meta(soup, "product:price:amount")
            or _extract_meta(soup, "og:price:amount")
        )
    result["originalPrice"] = price

    # ── description ──────────────────────────────────────────────
    result["description"] = (
        product.get("description")
        or product.get("simpleDescription")
        or json_ld.get("description")
        or _extract_meta(soup, "og:description")
        or _extract_meta(soup, "description")
    )

    # ── images ───────────────────────────────────────────────────
    images = product.get("images") or product.get("productImages") or []
    if isinstance(images, list) and images:
        for img in images:
            src = ""
            if isinstance(img, dict):
                src = _ensure_https(img.get("url") or img.get("src") or "")
            elif isinstance(img, str):
                src = _ensure_https(img)
            if src:
                result["galleryImages"].append(src)
        if result["galleryImages"]:
            result["mainImage"] = result["galleryImages"][0]

    # representImage (some SmartStore pages use this)
    if not result["mainImage"] and product.get("representImage"):
        rep = product["representImage"]
        if isinstance(rep, dict):
            result["mainImage"] = _ensure_https(rep.get("url") or rep.get("src") or "")
        elif isinstance(rep, str):
            result["mainImage"] = _ensure_https(rep)

    if not result["mainImage"]:
        img_ld = json_ld.get("image")
        if isinstance(img_ld, list) and img_ld:
            result["mainImage"] = _ensure_https(str(img_ld[0]))
            result["galleryImages"] = [_ensure_https(u) for u in img_ld if u]
        elif isinstance(img_ld, str):
            result["mainImage"] = _ensure_https(img_ld)

    if not result["mainImage"]:
        og_img = _extract_meta(soup, "og:image")
        if og_img:
            result["mainImage"] = _ensure_https(og_img)

    if not result["galleryImages"]:
        thumbs = soup.select(
            "ul._2QSxj li img, div.thumbnail_wrap img, "
            "div._1Bp8S img, img[class*='thumb']"
        )
        result["galleryImages"] = [
            _ensure_https(t.get("src") or t.get("data-src") or "")
            for t in thumbs
        ]
        result["galleryImages"] = [g for g in result["galleryImages"] if g]

    # ── detailImages ─────────────────────────────────────────────
    detail_imgs: list[str] = []

    # From product JSON
    for key in ["detailImages", "contentImages", "detailImageUrls"]:
        raw = product.get(key) or []
        if isinstance(raw, list):
            for img in raw:
                if isinstance(img, dict):
                    src = _ensure_https(img.get("url") or img.get("src") or "")
                elif isinstance(img, str):
                    src = _ensure_https(img)
                else:
                    continue
                if src and src not in detail_imgs:
                    detail_imgs.append(src)

    # From embedded detail HTML content (detailContent is HTML string)
    for key in ["detailContent", "detailContents", "contentHtml"]:
        content_html = product.get(key) or ""
        if isinstance(content_html, str) and "<img" in content_html:
            detail_soup = BeautifulSoup(content_html, "lxml")
            for img in detail_soup.find_all("img"):
                src = _ensure_https(img.get("src") or img.get("data-src") or "")
                if src and src not in detail_imgs and not src.endswith((".svg", ".gif", ".ico")):
                    detail_imgs.append(src)

    # From main page HTML (rendered detail section)
    if not detail_imgs:
        for selector in [
            "div.se-main-container img",
            "div._3FiSx img",
            "#INTRODUCE img",
            "div[class*='detail'] img",
            "div[class*='content'] img",
            "div.product-detail img",
        ]:
            tags = soup.select(selector)
            if tags:
                for img in tags:
                    src = _ensure_https(
                        img.get("src") or img.get("data-src") or img.get("data-lazy-src") or ""
                    )
                    if src and src not in detail_imgs and not src.endswith((".svg", ".gif", ".ico")):
                        detail_imgs.append(src)
                break
    result["detailImages"] = detail_imgs

    # ── category ─────────────────────────────────────────────────
    cat = product.get("category") or product.get("categoryName")
    if isinstance(cat, dict):
        whole = cat.get("wholeCategoryName")
        if whole:
            result["category"] = whole
        else:
            parts = []
            for k in ["category1Name", "category2Name", "category3Name", "category4Name"]:
                v = cat.get(k)
                if v:
                    parts.append(v)
            if parts:
                result["category"] = " > ".join(parts)
    elif isinstance(cat, str) and cat:
        result["category"] = cat

    if not result["category"]:
        result["category"] = json_ld.get("category")
    if not result["category"]:
        crumbs = soup.select("ol.breadcrumb li, nav[aria-label*='breadcrumb'] li")
        if crumbs:
            result["category"] = " > ".join(
                li.get_text(strip=True) for li in crumbs if li.get_text(strip=True)
            )

    # ── options ──────────────────────────────────────────────────
    raw_opts = (
        product.get("options")
        or product.get("optionCombinations")
        or product.get("optionGroups")
        or []
    )
    if isinstance(raw_opts, list):
        for opt in raw_opts[:20]:
            if isinstance(opt, dict):
                name = opt.get("name") or opt.get("optionName") or opt.get("groupName") or ""
                values = opt.get("values") or opt.get("optionValues") or opt.get("options") or []
                if isinstance(values, list):
                    str_vals = []
                    for v in values:
                        if isinstance(v, dict):
                            str_vals.append(v.get("name") or v.get("value") or str(v))
                        else:
                            str_vals.append(str(v))
                    if name or str_vals:
                        result["options"].append({"name": name, "values": str_vals})

    return result


async def parse_naver(url: str) -> dict:
    """
    Parse a Naver product page.

    Layer 1: curl_cffi with Chrome TLS impersonation (fast, bypasses basic protection)
    Layer 2: nodriver with CAPTCHA waiting (real Chrome, user solves CAPTCHA once)
    """
    # Determine referer
    if "brand.naver.com" in url:
        referer = "https://brand.naver.com/"
    elif "shopping.naver.com" in url:
        referer = "https://shopping.naver.com/"
    else:
        referer = "https://smartstore.naver.com/"

    # Layer 1: curl_cffi
    try:
        from parsers.http_client import fetch_with_curl

        print(f"[naver] Fetching with curl_cffi: {url}")
        html = await fetch_with_curl(url, referer=referer, warmup_url=referer)
        print(f"[naver] curl_cffi got {len(html)} bytes")

        result = _parse_html(html, url)
        if result.get("productName") or result.get("mainImage"):
            print(f"[naver] curl_cffi success: {result.get('productName', '(no name)')}")
            return result
        print("[naver] curl_cffi got HTML but no meaningful data, escalating...")
    except Exception as e:
        print(f"[naver] curl_cffi failed: {e}")

    # Layer 2: nodriver with CAPTCHA waiting (real Chrome)
    # Opens Chrome window. If CAPTCHA appears, waits for user to solve it.
    # Once solved, the session remembers it — subsequent requests work automatically.
    #
    # Warmup strategy: naver.com → store main page → product page
    # The store page establishes session cookies that may help avoid CAPTCHA.
    import re as _re
    store_match = _re.search(
        r"(?:smartstore|brand)\.naver\.com/([^/]+)/products/", url
    )
    store_warmup = None
    if store_match:
        store_slug = store_match.group(1)
        domain = "brand.naver.com" if "brand.naver.com" in url else "smartstore.naver.com"
        store_warmup = f"https://{domain}/{store_slug}"

    try:
        from parsers.browser import fetch_with_nodriver_captcha

        print(f"[naver] Fetching with nodriver (CAPTCHA-aware): {url}")
        if store_warmup:
            print(f"[naver] Store warmup: {store_warmup}")
        html = await fetch_with_nodriver_captcha(
            url,
            warmup_url=store_warmup or "https://www.naver.com/",
            wait_seconds=6,
            captcha_timeout=120,
        )
        print(f"[naver] nodriver got {len(html)} bytes")

        result = _parse_html(html, url)
        if result.get("productName") or result.get("mainImage"):
            print("[naver] nodriver extraction successful")
            return result
        return result  # Return partial data
    except ImportError:
        print("[naver] nodriver not available")
    except Exception as e:
        # Let CaptchaRequiredError propagate to main.py for proper error code
        from parsers.browser import CaptchaRequiredError
        if isinstance(e, CaptchaRequiredError):
            raise
        print(f"[naver] nodriver failed: {e}")

    raise RuntimeError(
        "네이버 상품 페이지에 접근할 수 없습니다. "
        "Chrome 브라우저가 열리면 보안 확인(CAPTCHA)을 완료해 주세요. "
        "한 번 풀면 이후 자동으로 접속됩니다."
    )
