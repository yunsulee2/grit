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

# Track which domains have passed CAPTCHA in this session
_captcha_cleared: set[str] = set()


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


def _get_html_value(html) -> str:
    """Normalize nodriver's evaluate result to a string."""
    if isinstance(html, dict):
        return html.get("value", "")
    if not isinstance(html, str):
        return str(html)
    return html


def _is_captcha_page(html: str) -> bool:
    """Check if the current page is a CAPTCHA challenge."""
    check = html[:3000]
    return (
        "보안 확인을 완료해 주세요" in check
        or "captcha" in check.lower()
        or "ncpt.naver.com" in check
        or "wtm_captcha" in check
    )


def _is_blocked_page(html: str) -> bool:
    """Check if the page is blocked (non-CAPTCHA)."""
    check = html[:1000]
    return "Access Denied" in check


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
        html = _get_html_value(await page.evaluate("document.documentElement.outerHTML"))

        # Check for blocks
        if _is_blocked_page(html):
            raise RuntimeError("Access Denied by bot protection")
        if _is_captcha_page(html):
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


class CaptchaRequiredError(RuntimeError):
    """Raised when CAPTCHA is detected and user needs to solve it in Chrome."""
    pass


async def fetch_with_nodriver_captcha(
    url: str,
    warmup_url: str | None = None,
    wait_seconds: int = 6,
    captcha_timeout: int = 60,
) -> str:
    """
    Fetch a page using nodriver with CAPTCHA detection and two-phase flow.

    Phase 1 (first call): Opens Chrome, navigates to the page.
      - If CAPTCHA detected → raises CaptchaRequiredError immediately
        (user sees Chrome and can solve CAPTCHA while looking at the error)
      - If no CAPTCHA → extracts and returns HTML

    Phase 2 (retry after user solves CAPTCHA): Browser session is alive,
      CAPTCHA already solved → navigates to page and extracts data.

    Args:
        url: The page URL to fetch
        warmup_url: Optional URL to visit first (e.g., store page for cookie warmup)
        wait_seconds: Seconds to wait after page load for JS rendering
        captcha_timeout: Max seconds to wait for CAPTCHA auto-resolution

    Returns:
        Full page HTML string

    Raises:
        CaptchaRequiredError: If CAPTCHA detected (user should solve and retry)
        RuntimeError: If page is blocked or content is too small
    """
    global _browser

    try:
        browser = await get_browser()
    except Exception as e:
        _browser = None
        raise RuntimeError(f"Failed to start browser: {e}")

    try:
        # Warm up with another page first (builds cookies, may help avoid CAPTCHA)
        if warmup_url:
            page = await browser.get(warmup_url)
            await page.sleep(3)

        # Navigate to target
        page = await browser.get(url)
        await page.sleep(wait_seconds)

        # Get initial HTML
        html = _get_html_value(await page.evaluate("document.documentElement.outerHTML"))

        # Check for Access Denied (non-CAPTCHA block, cannot recover)
        if _is_blocked_page(html):
            raise RuntimeError("Access Denied by bot protection")

        # Check for CAPTCHA
        if _is_captcha_page(html):
            print(f"[browser] CAPTCHA detected on {url}.")

            # Wait a short time — CAPTCHA might auto-resolve or user might
            # already be solving it from a previous attempt
            elapsed = 0
            poll_interval = 3
            while elapsed < captcha_timeout:
                await page.sleep(poll_interval)
                elapsed += poll_interval

                try:
                    html = _get_html_value(
                        await page.evaluate("document.documentElement.outerHTML")
                    )
                except Exception:
                    continue

                if not _is_captcha_page(html):
                    print(f"[browser] CAPTCHA solved after {elapsed}s!")
                    await page.sleep(3)
                    # Reload target page for clean content
                    page = await browser.get(url)
                    await page.sleep(wait_seconds)
                    html = _get_html_value(
                        await page.evaluate("document.documentElement.outerHTML")
                    )
                    break
            else:
                # CAPTCHA not solved within timeout — tell user to solve and retry
                raise CaptchaRequiredError(
                    "네이버 보안 확인(CAPTCHA)이 필요합니다.\n"
                    "Chrome 브라우저에서 보안 확인을 완료한 후 '다시 시도'를 눌러주세요.\n"
                    "한 번 풀면 이후 자동으로 접속됩니다."
                )

        # Still CAPTCHA after solving?
        if _is_captcha_page(html):
            raise CaptchaRequiredError(
                "CAPTCHA가 아직 해결되지 않았습니다.\n"
                "Chrome 브라우저에서 보안 확인을 완료한 후 다시 시도해 주세요."
            )

        # Scroll to trigger lazy loading
        try:
            await page.evaluate("window.scrollTo(0, document.body.scrollHeight / 2)")
            await page.sleep(1)
            await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
            await page.sleep(1)
        except Exception:
            pass

        # Get final HTML
        html = _get_html_value(await page.evaluate("document.documentElement.outerHTML"))

        if len(html) < 1000:
            raise RuntimeError(f"Page content too small ({len(html)} bytes)")

        # Mark domain as CAPTCHA-cleared for this session
        from urllib.parse import urlparse
        domain = urlparse(url).hostname or ""
        _captcha_cleared.add(domain)
        print(f"[browser] Successfully fetched {url} ({len(html)} bytes)")

        return html

    except (RuntimeError, CaptchaRequiredError):
        raise
    except Exception as e:
        _browser = None
        raise RuntimeError(f"Browser fetch failed: {e}")
