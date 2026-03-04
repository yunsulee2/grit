import { cn, formatPrice } from '@/lib/utils';

interface PriceSectionProps {
  brandName: string;
  productName: string;
  currentPrice: number;
  startPrice: number;
  discountPercent: number;
  freeShipping: boolean;
  className?: string;
}

function PriceSection({
  brandName,
  productName,
  currentPrice,
  startPrice,
  discountPercent,
  freeShipping,
  className,
}: PriceSectionProps) {
  const hasDiscount = discountPercent > 0;

  return (
    <div className={cn('px-lg py-xl', className)}>
      {/* Brand name */}
      <p className="text-[13px] text-text-secondary mb-xs">{brandName}</p>

      {/* Product name */}
      <h1 className="text-[18px] font-bold text-text-primary leading-snug mb-md">
        {productName}
      </h1>

      {/* Price row */}
      <div className="flex items-baseline gap-sm flex-wrap">
        {hasDiscount && (
          <span className="inline-flex items-center px-sm py-[2px] rounded-xs bg-semantic-error text-white text-[13px] font-bold leading-tight">
            {discountPercent}%
          </span>
        )}
        <span className="text-2xl font-extrabold text-text-primary">
          {formatPrice(currentPrice)}
        </span>
        {hasDiscount && (
          <span className="text-[14px] text-text-tertiary line-through">
            {formatPrice(startPrice)}
          </span>
        )}
      </div>

      {/* Free shipping badge */}
      {freeShipping && (
        <span className="inline-block mt-sm text-[12px] font-semibold text-semantic-info bg-semantic-info-muted px-sm py-[2px] rounded-xs">
          무료배송
        </span>
      )}
    </div>
  );
}

export { PriceSection };
export type { PriceSectionProps };
