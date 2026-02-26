import time
import httpx
from urllib.parse import urlparse

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel

from parsers.coupang import parse_coupang
from parsers.generic import parse_generic

app = FastAPI(title="Grit Scraping Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple in-memory image cache: url -> (bytes, content_type, timestamp)
_image_cache: dict[str, tuple[bytes, str, float]] = {}
_IMAGE_CACHE_TTL = 300  # 5 minutes

HTTP_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0.0.0 Safari/537.36"
    ),
    "Accept-Language": "ko-KR,ko;q=0.9",
}

# Sites known to have aggressive bot protection
BLOCKED_SITES = {
    "coupang": "쿠팡",
    "naver": "네이버",
}


class ScrapeRequest(BaseModel):
    url: str


def _detect_site(url: str) -> str:
    try:
        hostname = urlparse(url).hostname or ""
        if "coupang.com" in hostname:
            return "coupang"
        if "naver.com" in hostname or "smartstore.naver.com" in hostname:
            return "naver"
        if "kakao.com" in hostname or "kakaopage.com" in hostname:
            return "kakao"
        return "other"
    except Exception:
        return "other"


def _site_display_name(site: str) -> str:
    names = {
        "coupang": "쿠팡",
        "naver": "네이버",
        "kakao": "카카오",
    }
    return names.get(site, "기타")


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/api/scrape")
async def scrape(request: ScrapeRequest):
    url = request.url.strip()
    if not url:
        return {"success": False, "error": "URL is required", "errorCode": "MISSING_URL"}

    site = _detect_site(url)

    try:
        if site == "coupang":
            data = await parse_coupang(url)
        else:
            # All other sites use the generic parser (layered httpx → Playwright)
            data = await parse_generic(url)
            data["detectedSite"] = _site_display_name(site)

        # Check if we got meaningful data
        has_data = bool(data.get("productName") or data.get("mainImage"))
        if not has_data:
            return {
                "success": False,
                "error": "상품 정보를 찾을 수 없습니다. URL을 확인해 주세요.",
                "errorCode": "NO_DATA",
                "data": data,  # Return partial data anyway
            }

        return {"success": True, "data": data}

    except RuntimeError as e:
        return {
            "success": False,
            "error": str(e),
            "errorCode": "BLOCKED",
        }
    except Exception as e:
        print(f"[scrape] Unexpected error for {url}: {e}")
        return {
            "success": False,
            "error": f"스크래핑 중 오류가 발생했습니다: {e}",
            "errorCode": "PARSE_ERROR",
        }


@app.get("/api/proxy/image")
async def proxy_image(url: str = Query(..., description="Original image URL to proxy")):
    if not url:
        raise HTTPException(status_code=400, detail="url query parameter is required")

    # Check cache
    now = time.time()
    if url in _image_cache:
        data, content_type, cached_at = _image_cache[url]
        if now - cached_at < _IMAGE_CACHE_TTL:
            return Response(content=data, media_type=content_type)
        else:
            del _image_cache[url]

    # Determine referer from image URL domain
    parsed = urlparse(url)
    referer = f"{parsed.scheme}://{parsed.hostname}/"

    headers = {
        **HTTP_HEADERS,
        "Referer": referer,
    }

    try:
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            response = await client.get(url, headers=headers)
            response.raise_for_status()
            image_bytes = response.content
            content_type = response.headers.get("content-type", "image/jpeg")
    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=e.response.status_code,
            detail=f"Failed to fetch image: {e}",
        )
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Image proxy error: {e}")

    # Store in cache
    _image_cache[url] = (image_bytes, content_type, now)

    return Response(content=image_bytes, media_type=content_type)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
