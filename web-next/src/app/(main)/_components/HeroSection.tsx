'use client';

import Link from 'next/link';
import Image from 'next/image';
import { CountdownTimer } from '@/components/fund/CountdownTimer';
import { formatPrice, formatNumber } from '@/lib/utils';
import type { FundCardData } from '@/types/fund';

interface HeroSectionProps {
  fund: FundCardData;
}

function HeroSection({ fund }: HeroSectionProps) {
  const progressPercent = fund.maxParticipants
    ? Math.min(100, Math.round((fund.currentParticipants / fund.maxParticipants) * 100))
    : 0;

  return (
    <section className="w-full bg-primary">
      <div className="max-w-content mx-auto">
        <div className="flex flex-col tablet:flex-row">
          {/* Image */}
          <div className="relative w-full tablet:w-[480px] tablet:flex-shrink-0 aspect-[4/3] tablet:aspect-auto overflow-hidden">
            <Image
              src={fund.imageUrl}
              alt={fund.productName}
              fill
              className="object-cover"
              sizes="(max-width: 960px) 100vw, 480px"
              priority={true}
            />
            {/* Gradient overlay at bottom */}
            <div className="absolute inset-x-0 bottom-0 h-1/3 bg-gradient-to-t from-primary/80 to-transparent tablet:hidden" />
          </div>

          {/* Info panel */}
          <div className="flex-1 px-lg tablet:px-3xl py-2xl tablet:py-4xl flex flex-col justify-center gap-lg">
            {/* Badge */}
            <div
              className="flex items-center gap-sm animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
              style={{ animationDelay: '100ms' }}
            >
              <span className="inline-flex items-center px-sm py-xs rounded-xs bg-accent text-onAccent text-[11px] font-bold uppercase tracking-wide">
                HOT DEAL
              </span>
              <span className="text-[12px] text-text-tertiary">{fund.category}</span>
            </div>

            {/* Product name */}
            <h2
              className="text-[20px] tablet:text-[24px] font-bold text-text-inverse leading-[1.35] line-clamp-3 animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
              style={{ animationDelay: '200ms' }}
            >
              {fund.productName}
            </h2>

            {/* Price block */}
            <div
              className="flex flex-col gap-xs animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
              style={{ animationDelay: '300ms' }}
            >
              <div className="flex items-baseline gap-sm flex-wrap">
                <span className="text-[28px] tablet:text-[32px] font-extrabold text-accent leading-none">
                  {formatPrice(fund.currentPrice)}
                </span>
                <span className="text-[14px] text-text-tertiary line-through">
                  {formatPrice(fund.startPrice)}
                </span>
                <span className="text-[13px] font-bold text-price-red">
                  {fund.discountPercent}% 할인
                </span>
              </div>
              <p className="text-[13px] text-text-secondary">
                최대혜택가{' '}
                <span className="font-bold text-accent">{formatPrice(fund.targetPrice)}</span>
              </p>
            </div>

            {/* Stats row */}
            <div
              className="flex items-center gap-lg text-[13px] text-text-secondary animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
              style={{ animationDelay: '400ms' }}
            >
              <span>
                <span className="font-semibold text-text-inverse">
                  {formatNumber(fund.currentParticipants)}명
                </span>{' '}
                참여 중
              </span>
              <span className="w-px h-[14px] bg-border" />
              <CountdownTimer endAt={fund.endAt} variant="inline" className="text-[13px]" />
            </div>

            {/* Progress bar */}
            {fund.maxParticipants && (
              <div
                className="flex flex-col gap-xs animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
                style={{ animationDelay: '500ms' }}
              >
                <div className="h-[6px] bg-white/20 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-accent rounded-full transition-all duration-500"
                    style={{ width: `${progressPercent}%` }}
                  />
                </div>
                <p className="text-[12px] text-text-secondary">
                  목표 달성률{' '}
                  <span className="font-bold text-accent">{progressPercent}%</span>
                  {fund.nextTier && (
                    <span>
                      {' '}· {formatNumber(fund.nextTier.needed)}명만 더 모이면{' '}
                      <span className="font-bold text-text-inverse">
                        {formatPrice(fund.nextTier.price)}
                      </span>
                      !
                    </span>
                  )}
                </p>
              </div>
            )}

            {/* CTA */}
            <Link
              href={`/fund/${fund.id}`}
              className="inline-flex items-center justify-center h-[52px] px-3xl rounded-md bg-accent text-onAccent text-[15px] font-bold hover:bg-accent-dark transition-colors self-start animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
              style={{ animationDelay: '600ms' }}
            >
              지금 참여하기
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

export { HeroSection };
