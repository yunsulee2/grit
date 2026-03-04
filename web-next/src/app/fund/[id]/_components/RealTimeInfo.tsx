'use client';

import { cn, formatNumber } from '@/lib/utils';
import { CountdownTimer } from '@/components/fund/CountdownTimer';
import { ParticipantBadge } from '@/components/fund/ParticipantBadge';

interface RealTimeInfoProps {
  currentParticipants: number;
  maxParticipants: number | null;
  endAt: string;
  className?: string;
}

function RealTimeInfo({
  currentParticipants,
  maxParticipants,
  endAt,
  className,
}: RealTimeInfoProps) {
  const progressPercent = maxParticipants
    ? Math.min(Math.round((currentParticipants / maxParticipants) * 100), 100)
    : null;

  return (
    <div className={cn('px-lg py-lg', className)}>
      <div className="flex items-center justify-between gap-md">
        {/* Left: participants */}
        <div className="flex items-center gap-sm">
          <ParticipantBadge count={currentParticipants} />
          {progressPercent !== null && (
            <span className="text-[13px] text-text-secondary">
              ({progressPercent}%{maxParticipants ? ` / ${formatNumber(maxParticipants)}명` : ''})
            </span>
          )}
        </div>

        {/* Right: countdown */}
        <CountdownTimer endAt={endAt} variant="inline" />
      </div>
    </div>
  );
}

export { RealTimeInfo };
export type { RealTimeInfoProps };
