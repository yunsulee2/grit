'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { cn } from '@/lib/utils';
import { formatPrice } from '@/lib/utils';
import { CountdownTimer } from './CountdownTimer';
import { Skeleton } from '@/components/ui/Skeleton';
import type { FundCardData } from '@/types/fund';

interface FundCardProps {
  fund: FundCardData;
  className?: string;
}

function FundCard({ fund, className }: FundCardProps) {
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState(false);

  return (
    <Link
      href={`/fund/${fund.id}`}
      className={cn(
        'group block bg-surface-elevated rounded-md overflow-hidden shadow-card',
        'transition-all duration-200 ease-out',
        'hover:-translate-y-[2px] hover:shadow-elevated',
        className
      )}
    >
      {/* Image area */}
      <div className="relative aspect-[85/100] overflow-hidden bg-surface">
        {/* Loading skeleton shown until image loads */}
        {!loaded && !error && (
          <Skeleton variant="image" className="absolute inset-0 rounded-none aspect-auto h-full" />
        )}

        {/* Error fallback */}
        {error && (
          <div className="absolute inset-0 flex items-center justify-center bg-surface">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="w-10 h-10 text-text-tertiary"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              aria-hidden="true"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
          </div>
        )}

        {!error && (
          <Image
            src={fund.imageUrl}
            alt={fund.productName}
            fill
            className={cn('object-cover transition-opacity duration-300', loaded ? 'opacity-100' : 'opacity-0')}
            sizes="(max-width: 600px) 50vw, (max-width: 960px) 33vw, 240px"
            onLoad={() => setLoaded(true)}
            onError={() => setError(true)}
          />
        )}

        {/* Countdown badge - top left */}
        <div className="absolute top-sm left-sm">
          <CountdownTimer endAt={fund.endAt} variant="badge" />
        </div>
      </div>

      {/* Text area */}
      <div className="px-md pt-sm pb-md">
        {/* Free shipping tag */}
        {fund.freeShipping && (
          <div className="mb-sm">
            <span className="inline-block px-sm py-[2px] border border-border rounded-xs text-[11px] text-text-secondary">
              무료배송
            </span>
          </div>
        )}

        {/* Product name */}
        <p className="text-[14px] leading-[1.4] text-text-primary line-clamp-2">
          {fund.productName}
        </p>

        <div className="mt-sm">
          {/* Price row */}
          <div className="flex items-baseline gap-xs flex-wrap">
            <span className="text-[11px] font-bold text-price-red">
              공구가
            </span>
            <span className="text-[16px] font-extrabold text-text-primary">
              {formatPrice(fund.currentPrice)}
            </span>
            <span className="text-[12px] text-text-tertiary line-through">
              {formatPrice(fund.startPrice)}
            </span>
          </div>

          {/* Max benefit price */}
          <p className="mt-[2px] text-[13px] font-bold text-price-red">
            최대혜택가 {formatPrice(fund.targetPrice)}
          </p>
        </div>
      </div>
    </Link>
  );
}

export { FundCard };
export type { FundCardProps };
