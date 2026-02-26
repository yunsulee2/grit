"""
Kakao Commerce product page parser.
"""

import json
import re
import httpx
from bs4 import BeautifulSoup


HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    ),
    "Referer": "https://store.kakao.com/",
}


def _ensure_https(url: str) -> str:
    """Convert protocol-relative URLs to https."""
    if not url:
        return url
    if url.startswith("//"):
        return "https:" + url
    return url


def _extract_json_ld(soup: BeautifulSoup) -> dict:
    """Extract the first JSON-LD script block as a dict, or empty dict on failure."""
    for tag in soup.find_all("script", type="application/ld+json"):
        try:
            data = json.loads(tag.string or "")
            if isinstance(data, list):
                data = data[0]
            return data
        except (json.JSONDecodeError, IndexError):
            continue
    return {}


def _extract_meta(soup: BeautifulSoup, property_name: str) -> str | None:
    """Extract content from an og: or name= meta tag."""
    tag = soup.find("meta", property=property_name) or soup.find(
        "meta", attrs={"name": property_name}
    )
    if tag:
        return tag.get("content") or None
    return None


def _extract_json_from_script(soup: BeautifulSoup, pattern: re.Pattern) -> dict:
    """Search all script tags for a regex pattern capturing a JSON object."""
    for tag in soup.find_all("script"):
        text = tag.string or ""
        match = pattern.search(text)
        if match:
            try:
                return json.loads(match.group(1))
            except json.JSONDecodeError:
                pass
    return {}


async def parse_kakao(url: str) -> dict:
    """
    Fetch and parse a Kakao Commerce product page.

    Returns a dict with:
        productName, brandName, originalPrice, description,
        mainImage, galleryImages, detailImages
    """
    result = {
        "productName": None,
        "brandName": None,
        "originalPrice": None,
        "description": None,
        "mainImage": None,
        "galleryImages": [],
        "detailImages": [],
    }

    async with httpx.AsyncClient(follow_redirects=True, timeout=20.0) as client:
        try:
            response = await client.get(url, headers=HEADERS)
            response.raise_for_status()
            html = response.text
        except httpx.HTTPError as exc:
            print(f"[kakao] HTTP error fetching {url}: {exc}")
            return result

    soup = BeautifulSoup(html, "lxml")
    json_ld = _extract_json_ld(soup)

    # Some Kakao pages embed state as __NEXT_DATA__ (Next.js) or similar
    next_data_pattern = re.compile(r'<script id="__NEXT_DATA__"[^>]*>(\{.*?\})</script>', re.DOTALL)
    next_data: dict = {}
    try:
        match = next_data_pattern.search(html)
        if match:
            next_data = json.loads(match.group(1))
    except (json.JSONDecodeError, AttributeError) as exc:
        print(f"[kakao] __NEXT_DATA__ parse failed: {exc}")

    # ── productName ──────────────────────────────────────────────────────────
    try:
        result["productName"] = (
            json_ld.get("name")
            or _extract_meta(soup, "og:title")
            or (soup.find("title").get_text(strip=True) if soup.find("title") else None)
        )
    except Exception as exc:
        print(f"[kakao] productName extraction failed: {exc}")

    # ── brandName ─────────────────────────────────────────────────────────────
    try:
        brand = json_ld.get("brand")
        if isinstance(brand, dict):
            result["brandName"] = brand.get("name")
        elif isinstance(brand, str):
            result["brandName"] = brand

        if not result["brandName"]:
            # Kakao store page often has the shop/brand name in a dedicated element
            for selector in [
                "span.store_name",
                "a.shop_name",
                "div.seller_name",
                "p[class*='storeName']",
                "span[class*='shopName']",
            ]:
                tag = soup.select_one(selector)
                if tag:
                    result["brandName"] = tag.get_text(strip=True)
                    break

        # Fallback: __NEXT_DATA__ store name
        if not result["brandName"] and next_data:
            try:
                result["brandName"] = (
                    next_data.get("props", {})
                    .get("pageProps", {})
                    .get("product", {})
                    .get("storeName")
                )
            except (AttributeError, KeyError):
                pass
    except Exception as exc:
        print(f"[kakao] brandName extraction failed: {exc}")

    # ── originalPrice ─────────────────────────────────────────────────────────
    try:
        offers = json_ld.get("offers") or {}
        if isinstance(offers, list):
            offers = offers[0]
        price = offers.get("price") if isinstance(offers, dict) else None

        if price is None:
            price = (
                _extract_meta(soup, "og:price:amount")
                or _extract_meta(soup, "product:price:amount")
            )

        if price is None and next_data:
            try:
                price = (
                    next_data.get("props", {})
                    .get("pageProps", {})
                    .get("product", {})
                    .get("price")
                )
            except (AttributeError, KeyError):
                pass

        if price is None:
            # Last resort: look for a price element in DOM
            for selector in [
                "span.price",
                "strong.price",
                "div[class*='price'] strong",
                "em[class*='price']",
            ]:
                tag = soup.select_one(selector)
                if tag:
                    text = re.sub(r"[^\d]", "", tag.get_text())
                    price = int(text) if text else None
                    break

        result["originalPrice"] = price
    except Exception as exc:
        print(f"[kakao] originalPrice extraction failed: {exc}")

    # ── description ───────────────────────────────────────────────────────────
    try:
        result["description"] = (
            json_ld.get("description")
            or _extract_meta(soup, "og:description")
            or _extract_meta(soup, "description")
        )
    except Exception as exc:
        print(f"[kakao] description extraction failed: {exc}")

    # ── mainImage ─────────────────────────────────────────────────────────────
    try:
        image = json_ld.get("image")
        if isinstance(image, list) and image:
            image = image[0]
        if not image:
            image = _extract_meta(soup, "og:image")
        result["mainImage"] = _ensure_https(image) if image else None
    except Exception as exc:
        print(f"[kakao] mainImage extraction failed: {exc}")

    # ── galleryImages ─────────────────────────────────────────────────────────
    try:
        image_field = json_ld.get("image")
        if isinstance(image_field, list) and len(image_field) > 1:
            result["galleryImages"] = [_ensure_https(u) for u in image_field if u]
        else:
            # Carousel / thumbnail selectors common in Kakao commerce layouts
            carousel_selectors = [
                "ul.product_thumb li img",
                "div.swiper-wrapper img",
                "div[class*='carousel'] img",
                "div[class*='slider'] img",
                "div[class*='gallery'] img",
                "div[class*='thumbnail'] img",
            ]
            for selector in carousel_selectors:
                imgs = soup.select(selector)
                if imgs:
                    result["galleryImages"] = [
                        _ensure_https(img.get("src") or img.get("data-src") or "")
                        for img in imgs
                        if img.get("src") or img.get("data-src")
                    ]
                    break

        # Also try __NEXT_DATA__ images array
        if not result["galleryImages"] and next_data:
            try:
                images = (
                    next_data.get("props", {})
                    .get("pageProps", {})
                    .get("product", {})
                    .get("images", [])
                )
                result["galleryImages"] = [_ensure_https(u) for u in images if u]
            except (AttributeError, KeyError, TypeError):
                pass
    except Exception as exc:
        print(f"[kakao] galleryImages extraction failed: {exc}")

    # ── detailImages ──────────────────────────────────────────────────────────
    try:
        detail_selectors = [
            "div.product_detail img",
            "div[class*='detail_content'] img",
            "div[class*='productDetail'] img",
            "section[class*='detail'] img",
            "div.detail_area img",
        ]
        for selector in detail_selectors:
            imgs = soup.select(selector)
            if imgs:
                result["detailImages"] = [
                    _ensure_https(img.get("src") or img.get("data-src") or "")
                    for img in imgs
                    if img.get("src") or img.get("data-src")
                ]
                break
    except Exception as exc:
        print(f"[kakao] detailImages extraction failed: {exc}")

    return result
