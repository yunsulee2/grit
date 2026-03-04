type EventParams = Record<string, string | number | boolean>;

export function trackEvent(name: string, params?: EventParams) {
  if (typeof window === 'undefined') return;

  // Google Analytics 4
  if (typeof window.gtag === 'function') {
    window.gtag('event', name, params);
  }

  // Development logging
  if (process.env.NODE_ENV === 'development') {
    console.debug('[Analytics]', name, params);
  }
}

// Type augmentation for gtag
declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
  }
}
