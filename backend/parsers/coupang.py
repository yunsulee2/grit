"""
Coupang product parser.

Strategy:
1. curl_cffi with Chrome TLS impersonation (bypasses Akamai TLS fingerprinting)
2. nodriver (real Chrome via CDP) fallback for full JS rendering

Akamai WAF checks:
- TLS fingerprint (JA3/JA4) → curl_cffi handles this
- HTTP/2 fingerprint → curl_cffi handles this
- JavaScript challenges → nodriver handles this
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

    # productName — JSON-LD > new Tailwind h1 > old selectors > og:title
    if json_ld and json_ld.get("name"):
        result["productName"] = json_ld["name"]
    else:
        for sel in [
            "h1.product-title",
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
                title = og_title["content"].strip()
                title = re.sub(r"\s*[-|].*?쿠팡.*$", "", title)
                result["productName"] = title

    # brandName — JSON-LD > new brand-info > old selector
    if json_ld and json_ld.get("brand"):
        brand = json_ld["brand"]
        result["brandName"] = brand.get("name", brand) if isinstance(brand, dict) else str(brand)
    else:
        brand_tag = soup.select_one("a.prod-brand-name")
        if not brand_tag:
            # New Tailwind layout: div.brand-info contains the brand name
            brand_info = soup.select_one("div.brand-info")
            if brand_info:
                # Inner div has the clean name without "브랜드샵" suffix
                inner = brand_info.select_one("div.twc-font-bold")
                brand_tag = inner if inner else brand_info
        if brand_tag:
            result["brandName"] = brand_tag.get_text(strip=True)

    # originalPrice — JSON-LD > new Tailwind price > old selectors
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
        # New Tailwind layout: div.price-amount.final-price-amount or div.final-price
        for sel in [
            "div.price-amount.final-price-amount",
            "div.final-price",
            "div.price-container",
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

    # mainImage — JSON-LD > new Product image alt > og:image > old selectors
    if json_ld and json_ld.get("image"):
        img_ld = json_ld["image"]
        if isinstance(img_ld, list) and img_ld:
            result["mainImage"] = _normalize_image(str(img_ld[0]))
        elif isinstance(img_ld, str):
            result["mainImage"] = _normalize_image(img_ld)
    if not result["mainImage"]:
        # New Tailwind layout: main product image has alt="Product image"
        main_img = soup.select_one('img[alt="Product image"]')
        if main_img:
            src = main_img.get("src") or main_img.get("data-src")
            result["mainImage"] = _normalize_image(src)
    if not result["mainImage"]:
        og_image = soup.find("meta", property="og:image")
        if og_image and og_image.get("content"):
            result["mainImage"] = _normalize_image(og_image["content"])
    if not result["mainImage"]:
        for sel in ["div.prod-image img", "#repImageContainer img", "img.prod-image__detail"]:
            tag = soup.select_one(sel)
            if tag:
                src = tag.get("src") or tag.get("data-src")
                result["mainImage"] = _normalize_image(src)
                if result["mainImage"]:
                    break

    # galleryImages — new Tailwind layout + old selectors
    gallery_imgs = (
        soup.select("div.product-image img")
        or soup.select("div.prod-image__items img")
        or soup.select("ul.prod-thumbnail__list img")
        or soup.select("li.prod-image__item img")
    )
    gallery = []
    for img in gallery_imgs:
        src = _normalize_image(img.get("src") or img.get("data-src"))
        if src and src not in gallery:
            # Upscale thumbnails (48x48 or any size) to 492x492
            full = re.sub(r"/thumbnails/remote/\d+x\d+ex/", "/thumbnails/remote/492x492ex/", src)
            gallery.append(full)
    result["galleryImages"] = gallery
    # If JSON-LD has images and gallery is empty, use those
    if not gallery and json_ld and json_ld.get("image"):
        img_ld = json_ld["image"]
        if isinstance(img_ld, list):
            result["galleryImages"] = [_normalize_image(u) for u in img_ld if u]

    # detailImages — multiple container selectors (new + old)
    detail_container = (
        soup.select_one("div.product-detail-content-inside")
        or soup.select_one("#productDetail")
        or soup.select_one("div.product-detail__content")
        or soup.select_one("#btfContent")
    )
    if detail_container:
        details = []
        for img in detail_container.select("img"):
            src = _normalize_image(
                img.get("src") or img.get("data-src") or img.get("data-img")
            )
            if src and src not in details and not src.endswith((".svg", ".gif", ".ico")):
                details.append(src)
        result["detailImages"] = details

    # category
    breadcrumbs = soup.select("ul.breadcrumb li a")
    if breadcrumbs:
        result["category"] = " > ".join(a.get_text(strip=True) for a in breadcrumbs)

    # origin & weight
    attr_rows = soup.select(
        "table.prod-attr-table tr, div.prod-attr-item, li.prod-attr-item"
    )
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

    # options — new Tailwind select-item (structured) + old selectors (flat)
    select_items = soup.select("div.select-item")
    if select_items:
        opts = []
        for item in select_items:
            # Extract clean variant name from bold div
            name_tag = item.select_one("div.twc-font-bold")
            name = name_tag.get_text(strip=True) if name_tag else ""
            # Extract price from strong.price-text
            price_tag = item.select_one("strong.price-text")
            price_text = price_tag.get_text(strip=True) if price_tag else ""
            if name:
                entry = name
                if price_text:
                    entry += f" ({price_text})"
                opts.append(entry)
        if opts:
            result["options"] = opts
    else:
        option_items = soup.select("ul.prod-option__item li")
        if option_items:
            result["options"] = [
                item.get_text(strip=True)
                for item in option_items
                if item.get_text(strip=True)
            ]

    return result


async def parse_coupang(url: str) -> dict:
    """
    Parse a Coupang product page.

    Layer 1: curl_cffi with Chrome TLS impersonation (bypasses Akamai TLS check)
    Layer 2: nodriver (real Chrome via CDP, bypasses JS challenges)
    """
    # Layer 1: curl_cffi
    try:
        from parsers.http_client import fetch_with_curl

        print(f"[coupang] Fetching with curl_cffi: {url}")
        html = await fetch_with_curl(
            url,
            warmup_url="https://www.coupang.com/",
            referer="https://www.coupang.com/",
        )
        print(f"[coupang] curl_cffi got {len(html)} bytes")

        result = _parse_html(html, url)
        if result.get("productName") or result.get("mainImage"):
            print(f"[coupang] curl_cffi success: {result.get('productName', '(no name)')}")
            return result
        print("[coupang] curl_cffi got HTML but no product data, escalating...")
    except Exception as e:
        print(f"[coupang] curl_cffi failed: {e}")

    # Layer 2: nodriver (real Chrome, anti-detection)
    try:
        from parsers.browser import fetch_with_nodriver

        print(f"[coupang] Fetching with nodriver: {url}")
        html = await fetch_with_nodriver(
            url,
            warmup_url="https://www.coupang.com/",
            wait_seconds=5,
        )
        print(f"[coupang] nodriver got {len(html)} bytes")

        result = _parse_html(html, url)
        if result.get("productName") or result.get("mainImage"):
            print("[coupang] nodriver extraction successful")
            return result
        # Return partial data
        return result
    except ImportError:
        print("[coupang] nodriver not available")
    except Exception as e:
        print(f"[coupang] nodriver failed: {e}")
        raise RuntimeError(
            "쿠팡의 보안 시스템에 의해 자동 접근이 차단되었습니다. "
            "상품 정보를 직접 입력해 주세요."
        )

    raise RuntimeError(
        "쿠팡 상품 페이지에 접근할 수 없습니다. "
        "URL을 확인하거나 상품 정보를 직접 입력해 주세요."
    )
