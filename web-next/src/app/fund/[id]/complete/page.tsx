import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getMockFundDetail } from '@/lib/mock-data';
import { formatPrice, formatNumber } from '@/lib/utils';
import { Header } from '@/components/layout/Header';
import { Footer } from '@/components/layout/Footer';
import { MobileLayout } from '@/components/layout/MobileLayout';
import { VolumePricingBar } from '@/components/fund/VolumePricingBar';
import { ShareButtons } from '@/components/fund/ShareButtons';

interface CompletePageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ orderId?: string; amount?: string; quantity?: string }>;
}

export default async function CompletePage({ params, searchParams }: CompletePageProps) {
  const { id } = await params;
  const { orderId, amount, quantity } = await searchParams;

  const fund = getMockFundDetail(id);
  if (!fund) return notFound();

  const paidAmount = amount ? parseInt(amount, 10) : fund.currentPrice;
  const qty = quantity ? parseInt(quantity, 10) : 1;
  const shareUrl = `${process.env.NEXT_PUBLIC_BASE_URL || 'https://grit.app'}/fund/${id}`;

  const nextTier = fund.nextTier;
  const maxParticipants = fund.maxParticipants ?? fund.tiers[fund.tiers.length - 1]?.minQuantity ?? 500;

  return (
    <div className="min-h-screen flex flex-col bg-bg">
      <Header />

      <main className="flex-1 py-3xl pb-4xl">
        <MobileLayout maxWidth="form">

          {/* ── 1. Success icon + title ──────────────────────────────────── */}
          <div className="flex flex-col items-center text-center mb-3xl">
            {/* Green checkmark circle */}
            <div className="animate-scale-bounce w-[80px] h-[80px] rounded-full bg-semantic-success flex items-center justify-center mb-xl shadow-elevated">
              <svg
                width="44"
                height="44"
                viewBox="0 0 44 44"
                fill="none"
                aria-hidden="true"
              >
                <path
                  d="M10 22L18 30L34 14"
                  stroke="#FFFFFF"
                  strokeWidth="3.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>

            <h1 className="animate-fade-in-up opacity-0 [animation-fill-mode:forwards] text-2xl font-bold text-text-primary mb-sm" style={{ animationDelay: '300ms' }}>
              참여 완료!
            </h1>
            <p className="text-[15px] text-text-secondary">
              공동구매에 참여해 주셔서 감사합니다
            </p>
            {orderId && (
              <p className="mt-xs text-[12px] text-text-tertiary">
                주문번호 {orderId}
              </p>
            )}
          </div>

          {/* ── 2. Order summary card ───────────────────────────────────── */}
          <div className="animate-fade-in-up opacity-0 [animation-fill-mode:forwards] bg-surface-elevated border border-border rounded-md p-lg mb-lg" style={{ animationDelay: '400ms' }}>
            {/* Product row */}
            <div className="flex items-center gap-md mb-lg">
              <div className="relative w-[64px] h-[64px] rounded-sm overflow-hidden flex-shrink-0 bg-surface">
                <Image
                  src={fund.imageUrl}
                  alt={fund.productName}
                  fill
                  className="object-cover"
                  sizes="64px"
                />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-[14px] font-semibold text-text-primary leading-snug line-clamp-2">
                  {fund.productName}
                </p>
                <p className="text-[13px] text-text-secondary mt-xs">
                  {fund.brandName}
                </p>
              </div>
            </div>

            <div className="border-t border-border-subtle pt-lg space-y-sm">
              {/* Paid amount */}
              <div className="flex justify-between items-center">
                <span className="text-[14px] text-text-secondary">결제 금액</span>
                <span className="text-[14px] font-semibold text-text-primary">
                  {formatPrice(paidAmount * qty)}
                  {qty > 1 && (
                    <span className="text-[12px] font-normal text-text-tertiary ml-xs">
                      ({qty}개)
                    </span>
                  )}
                </span>
              </div>

              {/* Participant count */}
              <div className="flex justify-between items-center">
                <span className="text-[14px] text-text-secondary">현재 참여 현황</span>
                <span className="text-[14px] font-semibold text-primary">
                  현재 {formatNumber(fund.currentParticipants)}명 참여 중
                </span>
              </div>

              {/* Shipping */}
              {fund.freeShipping && (
                <div className="flex justify-between items-center">
                  <span className="text-[14px] text-text-secondary">배송비</span>
                  <span className="text-[14px] font-semibold text-semantic-success">
                    무료배송
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* ── 3. Share promotion section (CORE — takes 40%+ of viewport) ─ */}
          <div className="animate-fade-in-up opacity-0 [animation-fill-mode:forwards] bg-accent-muted rounded-md p-xl mb-3xl" style={{ animationDelay: '500ms' }}>

            {/* Volume pricing bar */}
            <div className="mb-xl">
              <VolumePricingBar
                tiers={fund.tiers}
                currentParticipants={fund.currentParticipants}
                maxParticipants={maxParticipants}
                variant="sm"
              />
            </div>

            {/* Urgency headline */}
            <div className="text-center mb-xl">
              {nextTier ? (
                <>
                  <p className="text-[18px] font-bold text-semantic-error leading-tight mb-sm">
                    {formatNumber(nextTier.needed)}명만 더 모이면<br />
                    가격이 {formatPrice(nextTier.price)}으로!
                  </p>
                  <p className="text-[14px] text-text-secondary">
                    공유하면 가격이 더 떨어집니다
                  </p>
                </>
              ) : (
                <>
                  <p className="text-[18px] font-bold text-semantic-error leading-tight mb-sm">
                    최저가 달성!
                  </p>
                  <p className="text-[14px] text-text-secondary">
                    친구에게 공유해서 함께 혜택을 누려보세요
                  </p>
                </>
              )}
            </div>

            {/* Share buttons — large, prominent, centered */}
            <div className="py-xl px-md bg-surface-elevated rounded-sm">
              <p className="text-center text-[13px] font-semibold text-text-secondary mb-xl uppercase tracking-wide">
                지금 바로 공유하기
              </p>
              <ShareButtons
                shareUrl={shareUrl}
                productName={fund.productName}
                className="scale-125 origin-center"
              />
            </div>

            {/* Social proof nudge */}
            <p className="text-center text-[12px] text-text-tertiary mt-lg">
              공유 1회 = 가격 하락 가능성 UP
            </p>
          </div>

          {/* ── 4. Navigation buttons ───────────────────────────────────── */}
          <div className="animate-fade-in-up opacity-0 [animation-fill-mode:forwards] flex flex-col gap-md" style={{ animationDelay: '600ms' }}>
            <Link
              href="/mypage"
              className="w-full h-[48px] flex items-center justify-center border border-primary rounded-sm text-[15px] font-semibold text-primary hover:bg-surface transition-colors"
            >
              주문 내역 보기
            </Link>

            <Link
              href="/"
              className="w-full h-[44px] flex items-center justify-center text-[15px] text-text-secondary hover:text-text-primary transition-colors"
            >
              홈으로
            </Link>
          </div>

        </MobileLayout>
      </main>

      <Footer />
    </div>
  );
}
