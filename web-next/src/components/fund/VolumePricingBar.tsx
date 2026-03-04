import { cn } from '@/lib/utils';
import { formatNumber, formatPrice } from '@/lib/utils';
import type { PriceTier } from '@/types/fund';

type VolumePricingBarVariant = 'sm' | 'lg';

interface VolumePricingBarProps {
  tiers: PriceTier[];
  currentParticipants: number;
  maxParticipants: number;
  variant?: VolumePricingBarVariant;
  className?: string;
}

function VolumePricingBar({
  tiers,
  currentParticipants,
  maxParticipants,
  variant = 'sm',
  className,
}: VolumePricingBarProps) {
  const progress = Math.min(currentParticipants / maxParticipants, 1);

  if (variant === 'sm') {
    return (
      <SmallBar
        currentParticipants={currentParticipants}
        maxParticipants={maxParticipants}
        progress={progress}
        className={className}
      />
    );
  }

  return (
    <LargeBar
      tiers={tiers}
      currentParticipants={currentParticipants}
      maxParticipants={maxParticipants}
      progress={progress}
      className={className}
    />
  );
}

/* ── Small variant ─────────────────────────────────────────────────────────── */

function SmallBar({
  currentParticipants,
  maxParticipants,
  progress,
  className,
}: {
  currentParticipants: number;
  maxParticipants: number;
  progress: number;
  className?: string;
}) {
  return (
    <div className={cn('w-full', className)}>
      <div className="flex justify-between mb-xs">
        <span className="text-[13px] font-bold text-primary">
          {formatNumber(currentParticipants)}개
        </span>
        <span className="text-[13px] text-text-secondary">
          목표 {formatNumber(maxParticipants)}개
        </span>
      </div>
      <ProgressTrack height={4} progress={progress} useGradient={false} />
    </div>
  );
}

/* ── Large variant ─────────────────────────────────────────────────────────── */

function LargeBar({
  tiers,
  currentParticipants,
  maxParticipants,
  progress,
  className,
}: {
  tiers: PriceTier[];
  currentParticipants: number;
  maxParticipants: number;
  progress: number;
  className?: string;
}) {
  const badgeLeftPercent = Math.min(progress * 100, 100);

  return (
    <div className={cn('w-full', className)}>
      {/* Floating participant badge */}
      <div className="relative h-[36px] mb-sm">
        <div
          className="absolute bottom-0 -translate-x-1/2"
          style={{ left: `${badgeLeftPercent}%` }}
        >
          <div className="relative">
            <div className="bg-primary text-text-inverse px-sm py-xs rounded-xs text-[13px] font-bold whitespace-nowrap">
              {formatNumber(currentParticipants)}개 돌파!
            </div>
            {/* Triangle pointer */}
            <div className="absolute left-1/2 -translate-x-1/2 top-full w-0 h-0 border-l-[4px] border-l-transparent border-r-[4px] border-r-transparent border-t-[6px] border-t-primary" />
          </div>
        </div>
      </div>

      {/* Progress bar with tier markers */}
      <div className="relative h-[12px]">
        <div className="absolute inset-y-[2px] inset-x-0">
          <ProgressTrack height={8} progress={progress} useGradient />
        </div>

        {/* Tier marker circles */}
        {tiers.map((tier, i) => {
          const tierPos = Math.min(tier.minQuantity / maxParticipants, 1) * 100;
          const achieved = currentParticipants >= tier.minQuantity;
          return (
            <div
              key={i}
              className={cn(
                'absolute top-0 w-[12px] h-[12px] rounded-full border-2 border-white -translate-x-1/2',
                achieved ? 'bg-primary' : 'bg-border'
              )}
              style={{ left: `${tierPos}%` }}
            />
          );
        })}

        {/* Current progress dot */}
        <div
          className="absolute top-0 w-[12px] h-[12px] rounded-full bg-primary -translate-x-1/2 shadow-[0_0_4px_1px_rgba(198,241,53,0.25)]"
          style={{ left: `${Math.min(progress * 100, 100)}%` }}
        />
      </div>

      {/* Tier labels */}
      <div className="flex justify-between mt-sm">
        {tiers.map((tier, i) => {
          const achieved = currentParticipants >= tier.minQuantity;
          return (
            <div key={i} className="text-center">
              <p
                className={cn(
                  'text-[11px]',
                  achieved ? 'text-primary font-bold' : 'text-text-secondary'
                )}
              >
                {i === 0 ? '시작가' : `${formatNumber(tier.minQuantity)}개 달성 시`}
              </p>
              <p
                className={cn(
                  'text-[13px] font-bold',
                  achieved ? 'text-primary' : 'text-text-secondary'
                )}
              >
                {formatPrice(tier.price)}
              </p>
            </div>
          );
        })}
      </div>
    </div>
  );
}

/* ── Shared progress track ─────────────────────────────────────────────────── */

function ProgressTrack({
  height,
  progress,
  useGradient,
}: {
  height: number;
  progress: number;
  useGradient: boolean;
}) {
  return (
    <div
      className="w-full bg-border overflow-hidden"
      style={{ height: `${height}px`, borderRadius: `${height / 2}px` }}
    >
      <div
        className={cn(
          'h-full transition-[width] duration-300',
          useGradient ? 'bg-gradient-to-r from-primary to-semantic-error' : 'bg-primary'
        )}
        style={{
          width: `${Math.min(progress * 100, 100)}%`,
          borderRadius: `${height / 2}px`,
        }}
      />
    </div>
  );
}

export { VolumePricingBar };
export type { VolumePricingBarProps, VolumePricingBarVariant };
