'use client';

import { useState, useEffect } from 'react';

export function ScrollToTop() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    let ticking = false;
    const onScroll = () => {
      if (!ticking) {
        requestAnimationFrame(() => {
          setShow(window.scrollY > 400);
          ticking = false;
        });
        ticking = true;
      }
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  if (!show) return null;

  return (
    <button
      type="button"
      onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
      className="fixed bottom-[96px] right-lg z-40 w-[40px] h-[40px] rounded-full bg-surface-elevated shadow-elevated border border-border-subtle flex items-center justify-center transition-opacity hover:bg-surface active:scale-95 animate-fade-in"
      aria-label="맨 위로 스크롤"
    >
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M8 12V4M4 7l4-3 4 3" />
      </svg>
    </button>
  );
}
