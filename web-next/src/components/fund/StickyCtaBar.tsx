'use client';

import { cn } from '@/lib/utils';
import { formatPrice } from '@/lib/utils';

interface StickyCtaBarProps {
  currentPrice: number;
  onParticipate: () => void;
  onShare: () => void;
  className?: string;
}

function StickyCtaBar({ currentPrice, onParticipate, onShare, className }: StickyCtaBarProps) {
  return (
    <div
      className={cn(
        'fixed bottom-0 left-0 right-0 z-50 bg-surface-elevated border-t border-border-subtle',
        className
      )}
    >
      <div className="h-[72px] flex items-center px-lg pb-[env(safe-area-inset-bottom)] max-w-content mx-auto">
        {/* Share icon button */}
        <button
          type="button"
          onClick={onShare}
          className="shrink-0 w-[48px] h-[48px] flex items-center justify-center rounded-sm border border-border hover:bg-surface transition-colors active:scale-95 cursor-pointer"
          aria-label="공유하기"
        >
          <svg
            width="22"
            height="22"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            className="text-text-primary"
          >
            <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8" />
            <polyline points="16 6 12 2 8 6" />
            <line x1="12" y1="2" x2="12" y2="15" />
          </svg>
        </button>

        <div className="w-md" />

        {/* Participate button */}
        <button
          type="button"
          onClick={onParticipate}
          className="flex-1 h-[48px] flex items-center justify-center bg-primary text-onPrimary rounded-sm font-bold text-[15px] hover:bg-primary/90 active:bg-primary/80 active:scale-[0.98] transition-colors transition-transform cursor-pointer"
        >
          공동구매 참여하기
          <span className="mx-[6px] opacity-40">|</span>
          {formatPrice(currentPrice)}
        </button>
      </div>
    </div>
  );
}

export { StickyCtaBar };
export type { StickyCtaBarProps };
