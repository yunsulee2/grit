/**
 * Detect if the current browser is the KakaoTalk in-app browser.
 * KakaoTalk in-app browser UA includes "KAKAOTALK" string.
 */
export function isKakaoInAppBrowser(): boolean {
  if (typeof window === 'undefined') return false;
  return /KAKAOTALK/i.test(navigator.userAgent);
}

/**
 * Check if localStorage is available (it may be restricted in some in-app browsers).
 */
export function hasLocalStorage(): boolean {
  try {
    const key = '__ls_test__';
    localStorage.setItem(key, '1');
    localStorage.removeItem(key);
    return true;
  } catch {
    return false;
  }
}

/**
 * Safe storage wrapper that falls back to in-memory Map when localStorage is unavailable.
 */
const memoryStore = new Map<string, string>();

export function safeSetItem(key: string, value: string): void {
  if (hasLocalStorage()) {
    localStorage.setItem(key, value);
  } else {
    memoryStore.set(key, value);
  }
}

export function safeGetItem(key: string): string | null {
  if (hasLocalStorage()) {
    return localStorage.getItem(key);
  }
  return memoryStore.get(key) ?? null;
}

export function safeRemoveItem(key: string): void {
  if (hasLocalStorage()) {
    localStorage.removeItem(key);
  } else {
    memoryStore.delete(key);
  }
}
