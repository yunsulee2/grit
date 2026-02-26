"""
Naver SmartStore product page parser.
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
    "Referer": "https://smartstore.naver.com/",
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
            # Some pages wrap it in a list
            if isinstance(data, list):
                data = data[0]
            return data
        except (json.JSONDecodeError, IndexError):
            continue
    return {}


def _extract_preloaded_state(soup: BeautifulSoup) -> dict:
    """Extract window.__PRELOADED_STATE__ JSON from script tags."""
    pattern = re.compile(r"window\.__PRELOADED_STATE__\s*=\s*(\{.*?\});", re.DOTALL)
    for tag in soup.find_all("script"):
        text = tag.string or ""
        match = pattern.search(text)
        if match:
            try:
                return json.loads(match.group(1))
            except json.JSONDecodeError:
                pass
    return {}


def _extract_meta(soup: BeautifulSoup, property_name: str) -> str | None:
    """Extract content from an og: or name= meta tag."""
    tag = soup.find("meta", property=property_name) or soup.find(
        "meta", attrs={"name": property_name}
    )
    if tag:
        return tag.get("content") or None
    return None


async def parse_naver(url: str) -> dict:
    """
    Fetch and parse a Naver SmartStore product page.

    Returns a dict with:
        productName, brandName, originalPrice, description,
        mainImage, galleryImages, detailImages, category
    """
    result = {
        "productName": None,
        "brandName": None,
        "originalPrice": None,
        "description": None,
        "mainImage": None,
        "galleryImages": [],
        "detailImages": [],
        "category": None,
    }

    async with httpx.AsyncClient(follow_redirects=True, timeout=20.0) as client:
        try:
            response = await client.get(url, headers=HEADERS)
            response.raise_for_status()
            html = response.text
        except httpx.HTTPError as exc:
            print(f"[naver] HTTP error fetching {url}: {exc}")
            return result

    soup = BeautifulSoup(html, "lxml")
    json_ld = _extract_json_ld(soup)

    # ── productName ──────────────────────────────────────────────────────────
    try:
        result["productName"] = (
            json_ld.get("name")
            or _extract_meta(soup, "og:title")
            or (soup.find("title").get_text(strip=True) if soup.find("title") else None)
        )
    except Exception as exc:
        print(f"[naver] productName extraction failed: {exc}")

    # ── brandName ─────────────────────────────────────────────────────────────
    try:
        brand = json_ld.get("brand")
        if isinstance(brand, dict):
            result["brandName"] = brand.get("name")
        elif isinstance(brand, str):
            result["brandName"] = brand
        if not result["brandName"]:
            # Fallback: seller info often sits in a specific element
            seller_tag = soup.find("span", class_=re.compile(r"_?sellerName|storeName", re.I))
            if seller_tag:
                result["brandName"] = seller_tag.get_text(strip=True)
    except Exception as exc:
        print(f"[naver] brandName extraction failed: {exc}")

    # ── originalPrice ─────────────────────────────────────────────────────────
    try:
        offers = json_ld.get("offers") or {}
        if isinstance(offers, list):
            offers = offers[0]
        price = offers.get("price") if isinstance(offers, dict) else None
        if price is None:
            price = _extract_meta(soup, "og:price:amount") or _extract_meta(soup, "product:price:amount")
        if price is None:
            # Try __PRELOADED_STATE__
            state = _extract_preloaded_state(soup)
            price = (
                state.get("product", {})
                .get("A", {})
                .get("productInfo", {})
                .get("salePrice")
            )
        result["originalPrice"] = price
    except Exception as exc:
        print(f"[naver] originalPrice extraction failed: {exc}")

    # ── description ───────────────────────────────────────────────────────────
    try:
        result["description"] = (
            json_ld.get("description")
            or _extract_meta(soup, "og:description")
            or _extract_meta(soup, "description")
        )
    except Exception as exc:
        print(f"[naver] description extraction failed: {exc}")

    # ── mainImage ─────────────────────────────────────────────────────────────
    try:
        image = json_ld.get("image")
        if isinstance(image, list) and image:
            image = image[0]
        if not image:
            image = _extract_meta(soup, "og:image")
        result["mainImage"] = _ensure_https(image) if image else None
    except Exception as exc:
        print(f"[naver] mainImage extraction failed: {exc}")

    # ── galleryImages ─────────────────────────────────────────────────────────
    try:
        image_field = json_ld.get("image")
        if isinstance(image_field, list):
            result["galleryImages"] = [_ensure_https(u) for u in image_field if u]
        else:
            # Fall back to thumbnail elements common in SmartStore layouts
            thumbs = soup.select(
                "ul._2QSxj li img, "
                "div.thumbnail_wrap img, "
                "div._1Bp8S img"
            )
            result["galleryImages"] = [
                _ensure_https(img["src"])
                for img in thumbs
                if img.get("src")
            ]
    except Exception as exc:
        print(f"[naver] galleryImages extraction failed: {exc}")

    # ── detailImages ──────────────────────────────────────────────────────────
    try:
        detail_selectors = [
            "div.se-main-container img",
            "div._3FiSx img",
            "div.product-detail img",
            "div[class*='detail'] img",
        ]
        detail_imgs = []
        for selector in detail_selectors:
            tags = soup.select(selector)
            if tags:
                detail_imgs = tags
                break
        result["detailImages"] = [
            _ensure_https(img.get("src") or img.get("data-src") or "")
            for img in detail_imgs
            if img.get("src") or img.get("data-src")
        ]
    except Exception as exc:
        print(f"[naver] detailImages extraction failed: {exc}")

    # ── category ──────────────────────────────────────────────────────────────
    try:
        result["category"] = json_ld.get("category") or None
        if not result["category"]:
            # Try breadcrumb
            breadcrumb = soup.select(
                "ol.breadcrumb li, "
                "div._3rLEW li, "
                "nav[aria-label*='breadcrumb'] li"
            )
            if breadcrumb:
                result["category"] = " > ".join(
                    li.get_text(strip=True) for li in breadcrumb if li.get_text(strip=True)
                )
    except Exception as exc:
        print(f"[naver] category extraction failed: {exc}")

    return result
