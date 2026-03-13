import { cn } from '@/lib/utils';
import { formatNumber } from '@/lib/utils';

interface ParticipantBadgeProps {
  count: number;
  showIcon?: boolean;
  className?: string;
}

function ParticipantBadge({ count, showIcon = true, className }: ParticipantBadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-[4px] px-sm py-xs bg-primary text-text-inverse rounded-xs text-[13px] font-bold leading-tight',
        className
      )}
    >
      {showIcon && (
        <svg
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="shrink-0"
        >
          <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
          <circle cx="9" cy="7" r="4" />
          <path d="M22 21v-2a4 4 0 0 0-3-3.87" />
          <path d="M16 3.13a4 4 0 0 1 0 7.75" />
        </svg>
      )}
      {formatNumber(count)}명 참여 중
    </span>
  );
}

export { ParticipantBadge };
export type { ParticipantBadgeProps };
