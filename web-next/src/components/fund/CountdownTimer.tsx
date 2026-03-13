'use client';

import { useState, useEffect } from 'react';
import { cn } from '@/lib/utils';
import { formatCountdown, isEndingSoon } from '@/lib/utils';

type CountdownVariant = 'badge' | 'inline';

interface CountdownTimerProps {
  endAt: string;
  variant?: CountdownVariant;
  className?: string;
}

function CountdownTimer({ endAt, variant = 'badge', className }: CountdownTimerProps) {
  const [timeText, setTimeText] = useState(() => formatCountdown(endAt));
  const [ending, setEnding] = useState(() => isEndingSoon(endAt));

  useEffect(() => {
    setTimeText(formatCountdown(endAt));
    setEnding(isEndingSoon(endAt));

    const interval = setInterval(() => {
      setTimeText(formatCountdown(endAt));
      setEnding(isEndingSoon(endAt));
    }, 1000);

    return () => clearInterval(interval);
  }, [endAt]);

  const isEnded = timeText === '\ub9c8\uac10';

  if (variant === 'badge') {
    return (
      <span
        className={cn(
          'inline-flex items-center px-sm py-[2px] rounded-xs text-[11px] font-semibold leading-[1.4] text-text-inverse',
          isEnded ? 'bg-text-secondary' : 'bg-black/80',
          className
        )}
      >
        {timeText}
      </span>
    );
  }

  // inline variant
  return (
    <span
      className={cn(
        'text-[16px] font-semibold',
        isEnded
          ? 'text-text-secondary'
          : ending
            ? 'text-semantic-error'
            : 'text-text-primary',
        className
      )}
    >
      {timeText}
    </span>
  );
}

export { CountdownTimer };
export type { CountdownTimerProps, CountdownVariant };
