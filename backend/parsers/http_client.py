"""
Shared HTTP client using curl_cffi for anti-detection requests.

curl_cffi impersonates real browser TLS fingerprints (JA3/JA4),
bypassing Akamai, Cloudflare, and similar WAF systems that check
TLS handshake characteristics to detect bots.
"""

from curl_cffi.requests import AsyncSession

CHROME_HEADERS = {
    "Accept": (
        "text/html,application/xhtml+xml,application/xml;"
        "q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8"
    ),
    "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7",
    "Accept-Encoding": "gzip, deflate, br",
    "Cache-Control": "max-age=0",
    "Sec-Ch-Ua": '"Chromium";v="131", "Not_A Brand";v="24"',
    "Sec-Ch-Ua-Mobile": "?0",
    "Sec-Ch-Ua-Platform": '"macOS"',
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1",
}

_BLOCK_INDICATORS = [
    "Access Denied",
    "보안 확인을 완료해 주세요",
    "captcha",
    "에러페이지",
    "bot detection",
    "Just a moment",
    "Checking your browser",
]


async def fetch_with_curl(
    url: str,
    *,
    warmup_url: str | None = None,
    referer: str | None = None,
    extra_headers: dict | None = None,
    timeout: int = 20,
    impersonate: str = "chrome",
) -> str:
    """
    Fetch a page using curl_cffi with browser TLS impersonation.

    Args:
        url: Target URL
        warmup_url: Optional homepage to visit first (builds cookies)
        referer: Optional Referer header
        extra_headers: Additional headers to merge
        timeout: Request timeout in seconds
        impersonate: Browser to impersonate

    Returns:
        HTML string

    Raises:
        RuntimeError: If request fails or page is blocked
    """
    headers = {**CHROME_HEADERS}
    if referer:
        headers["Referer"] = referer
    if extra_headers:
        headers.update(extra_headers)

    async with AsyncSession(impersonate=impersonate, timeout=timeout) as session:
        # Warmup request to build cookies
        if warmup_url:
            try:
                await session.get(warmup_url, headers=headers)
            except Exception:
                pass  # Warmup failure is non-critical

        response = await session.get(url, headers=headers)

        if response.status_code == 403:
            raise RuntimeError("403 Forbidden — bot protection active")
        if response.status_code == 503:
            raise RuntimeError("503 Service Unavailable — challenge page")

        response.raise_for_status()
        html = response.text

        # Check for block indicators
        lower_prefix = html[:3000].lower()
        for indicator in _BLOCK_INDICATORS:
            if indicator.lower() in lower_prefix:
                raise RuntimeError(f"Blocked: '{indicator}' detected in response")

        if len(html) < 500:
            raise RuntimeError(f"Response too small ({len(html)} bytes)")

        return html


async def fetch_image_with_curl(
    url: str,
    *,
    referer: str | None = None,
    timeout: int = 15,
) -> tuple[bytes, str]:
    """
    Fetch an image using curl_cffi with TLS impersonation.

    Returns:
        Tuple of (image_bytes, content_type)
    """
    headers = {
        "Accept": "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
        "Accept-Language": "ko-KR,ko;q=0.9",
        "Sec-Ch-Ua": '"Chromium";v="131"',
        "Sec-Fetch-Dest": "image",
        "Sec-Fetch-Mode": "no-cors",
        "Sec-Fetch-Site": "cross-site",
    }
    if referer:
        headers["Referer"] = referer

    async with AsyncSession(impersonate="chrome", timeout=timeout) as session:
        response = await session.get(url, headers=headers)
        response.raise_for_status()
        content_type = response.headers.get("content-type", "image/jpeg")
        return response.content, content_type
