import { cn, formatPrice, formatNumber } from '@/lib/utils';
import { VolumePricingBar } from '@/components/fund/VolumePricingBar';
import type { PriceTier } from '@/types/fund';

interface FundProgressSectionProps {
  tiers: PriceTier[];
  currentParticipants: number;
  maxParticipants: number | null;
  nextTier: { price: number; needed: number } | null;
  className?: string;
}

function FundProgressSection({
  tiers,
  currentParticipants,
  maxParticipants,
  nextTier,
  className,
}: FundProgressSectionProps) {
  const effectiveMax = maxParticipants ?? tiers[tiers.length - 1]?.minQuantity ?? 100;

  return (
    <div className={cn('px-lg py-xl', className)}>
      {/* Volume pricing bar — large variant */}
      <VolumePricingBar
        tiers={tiers}
        currentParticipants={currentParticipants}
        maxParticipants={effectiveMax}
        variant="lg"
      />

      {/* "N명만 더 모이면" message */}
      {nextTier && (
        <p className="mt-lg text-center text-[15px] font-bold text-semantic-error">
          {formatNumber(nextTier.needed)}명만 더 모이면{' '}
          <span className="text-primary">{formatPrice(nextTier.price)}</span>!
        </p>
      )}
    </div>
  );
}

export { FundProgressSection };
export type { FundProgressSectionProps };
