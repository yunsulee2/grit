"""
Shared browser module using nodriver for anti-detection scraping.

nodriver (successor to undetected-chromedriver) uses real Chrome via CDP
without chromedriver, making it undetectable by Akamai WAF and similar
bot protection systems.

Uses a singleton browser instance that persists across requests within
a server session, keeping cookies and session data alive.
"""

import asyncio
import nodriver as uc

# Singleton browser instance for reuse across requests
_browser = None
_browser_lock = asyncio.Lock()


async def get_browser():
    """Get or create a shared browser instance."""
    global _browser
    async with _browser_lock:
        if _browser is None:
            _browser = await uc.start(
                headless=False,
                lang="ko-KR",
                browser_args=[
                    "--disable-blink-features=AutomationControlled",
                    "--window-size=1920,1080",
                    "--no-first-run",
                    "--no-default-browser-check",
                    "--no-sandbox",
                ],
            )
        return _browser


async def close_browser():
    """Close the shared browser instance."""
    global _browser
    async with _browser_lock:
        if _browser is not None:
            try:
                _browser.stop()
            except Exception:
                pass
            _browser = None


async def fetch_with_nodriver(url: str, warmup_url: str | None = None, wait_seconds: int = 5) -> str:
    """
    Fetch a page using nodriver (real Chrome, anti-detection).

    The singleton browser keeps cookies across requests, so warming up
    with homepage once is sufficient for the entire server session.

    Args:
        url: The page URL to fetch
        warmup_url: Optional URL to visit first (e.g., homepage for cookie warmup)
        wait_seconds: Seconds to wait after page load for JS rendering

    Returns:
        Full page HTML string

    Raises:
        RuntimeError: If page is blocked or content is too small
    """
    global _browser

    try:
        browser = await get_browser()
    except Exception as e:
        # Reset singleton on connection failure
        _browser = None
        raise RuntimeError(f"Failed to start browser: {e}")

    try:
        # Warm up with homepage if specified (builds cookies)
        if warmup_url:
            page = await browser.get(warmup_url)
            await page.sleep(3)

        # Navigate to target
        page = await browser.get(url)
        await page.sleep(wait_seconds)

        # Scroll to trigger lazy loading
        await page.evaluate("window.scrollTo(0, document.body.scrollHeight / 2)")
        await page.sleep(1)
        await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
        await page.sleep(1)

        # Get HTML
        html = await page.evaluate("document.documentElement.outerHTML")

        # nodriver may return structured result
        if isinstance(html, dict):
            html = html.get("value", "")
        elif not isinstance(html, str):
            html = str(html)

        # Check for blocks
        if "Access Denied" in html[:500]:
            raise RuntimeError("Access Denied by bot protection")
        if "보안 확인을 완료해 주세요" in html[:2000]:
            raise RuntimeError(
                "네이버 보안 확인(CAPTCHA)이 필요합니다. "
                "열린 Chrome 브라우저에서 CAPTCHA를 직접 풀어주세요. "
                "한 번 풀면 이후 자동으로 접속됩니다."
            )
        if len(html) < 1000:
            raise RuntimeError(f"Page content too small ({len(html)} bytes)")

        return html

    except RuntimeError:
        raise
    except Exception as e:
        # Reset browser on unexpected errors
        _browser = None
        raise RuntimeError(f"Browser fetch failed: {e}")
