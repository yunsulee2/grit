import { cn } from '@/lib/utils';
import { formatPrice, formatNumber } from '@/lib/utils';
import type { PriceTier } from '@/types/fund';

interface PriceTierTableProps {
  tiers: PriceTier[];
  currentParticipants: number;
  className?: string;
}

function PriceTierTable({ tiers, currentParticipants, className }: PriceTierTableProps) {
  const sortedTiers = [...tiers].sort((a, b) => a.minQuantity - b.minQuantity);

  // Find the current tier index (the highest achieved tier)
  let currentTierIndex = -1;
  for (let i = sortedTiers.length - 1; i >= 0; i--) {
    if (currentParticipants >= sortedTiers[i].minQuantity) {
      currentTierIndex = i;
      break;
    }
  }

  // Find next tier for "N명 남음" display
  const nextTier = sortedTiers.find((t) => t.minQuantity > currentParticipants);
  const neededForNext = nextTier
    ? nextTier.minQuantity - currentParticipants
    : null;

  return (
    <div className={cn('w-full overflow-hidden rounded-md border border-border', className)}>
      <table className="w-full text-[13px]">
        <thead>
          <tr className="bg-surface text-text-secondary">
            <th className="py-sm px-md text-left font-medium">구간</th>
            <th className="py-sm px-md text-right font-medium">단가</th>
            <th className="py-sm px-md text-center font-medium">상태</th>
          </tr>
        </thead>
        <tbody>
          {sortedTiers.map((tier, i) => {
            const achieved = currentParticipants >= tier.minQuantity;
            const isCurrent = i === currentTierIndex;
            const isFuture = !achieved;
            const isNextTier = nextTier && tier.minQuantity === nextTier.minQuantity;

            return (
              <tr
                key={i}
                className={cn(
                  'border-t border-border-subtle transition-colors',
                  isCurrent && 'bg-accent-muted',
                  isFuture && 'opacity-50'
                )}
              >
                <td className="py-sm px-md text-left">
                  <span className={cn(isCurrent && 'font-bold text-primary')}>
                    {formatNumber(tier.minQuantity)}개 이상
                  </span>
                </td>
                <td className="py-sm px-md text-right">
                  <span
                    className={cn(
                      'font-bold',
                      isCurrent ? 'text-primary' : 'text-text-primary'
                    )}
                  >
                    {formatPrice(tier.price)}
                  </span>
                </td>
                <td className="py-sm px-md text-center">
                  {achieved ? (
                    <span className="inline-flex items-center gap-[2px] text-semantic-success font-semibold">
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.5"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      달성
                    </span>
                  ) : isNextTier && neededForNext !== null ? (
                    <span className="text-semantic-error font-semibold">
                      {formatNumber(neededForNext)}명 남음
                    </span>
                  ) : (
                    <span className="text-text-tertiary">-</span>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

export { PriceTierTable };
export type { PriceTierTableProps };
