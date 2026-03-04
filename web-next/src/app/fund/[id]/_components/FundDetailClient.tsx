'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { useUser } from '@/components/auth/UserContext';
import { useToast } from '@/components/ui/Toast';
import { trackEvent } from '@/lib/analytics';
import LoginModal from '@/components/auth/LoginModal';
import { ShareButtons } from '@/components/fund/ShareButtons';
import { StickyCtaBar } from '@/components/fund/StickyCtaBar';
import { PriceTierTable } from '@/components/fund/PriceTierTable';
import { POLLING_INTERVAL } from '@/lib/constants';
import { calculateCurrentPrice, getNextTier, getDiscountPercent } from '@/lib/utils';
import type { FundDetailData } from '@/types/fund';

import { ProductImageGallery } from './ProductImageGallery';
import { PriceSection } from './PriceSection';
import { FundProgressSection } from './FundProgressSection';
import { RealTimeInfo } from './RealTimeInfo';
import { ProductDetails } from './ProductDetails';
import { OptionBottomSheet } from './OptionBottomSheet';
import { PaymentFlow } from './PaymentFlow';

interface FundDetailClientProps {
  initialData: FundDetailData;
}

function FundDetailClient({ initialData }: FundDetailClientProps) {
  return (
    <FundDetailInner initialData={initialData} />
  );
}

/* -- Inner component with access to UserContext ---------------------------- */

function FundDetailInner({ initialData }: FundDetailClientProps) {
  const { user, isLoading: isAuthLoading } = useUser();
  const { toast } = useToast();
  const [fund, setFund] = useState<FundDetailData>(initialData);
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [showOptionSheet, setShowOptionSheet] = useState(false);
  const [paymentError, setPaymentError] = useState<string | null>(null);
  const pendingParticipate = useRef(false);

  // Derive computed values from live fund data
  const currentPrice = calculateCurrentPrice(fund.tiers, fund.currentParticipants);
  const nextTier = getNextTier(fund.tiers, fund.currentParticipants);
  const discountPercent = getDiscountPercent(fund.startPrice, currentPrice);

  // Track fund view on mount
  useEffect(() => {
    trackEvent('fund_view', { fund_id: fund.id, product_name: fund.productName });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // 30-second polling for real-time participant count updates
  useEffect(() => {
    const interval = setInterval(async () => {
      try {
        const res = await fetch(`/api/funds/${fund.id}`);
        if (res.ok) {
          const json = await res.json();
          const updated = json.data;
          if (updated) {
            setFund((prev) => ({
              ...prev,
              currentParticipants: updated.currentParticipants ?? prev.currentParticipants,
              currentPrice: updated.currentPrice ?? prev.currentPrice,
              nextTier: updated.nextTier ?? prev.nextTier,
            }));
          }
        }
      } catch {
        // Silently ignore polling errors
      }
    }, POLLING_INTERVAL);

    return () => clearInterval(interval);
  }, [fund.id]);

  // After login completes, if user was trying to participate, open option sheet
  useEffect(() => {
    if (pendingParticipate.current && user && !isAuthLoading) {
      pendingParticipate.current = false;
      setShowLoginModal(false);
      setShowOptionSheet(true);
    }
  }, [user, isAuthLoading]);

  // "참여하기" button handler
  const handleParticipate = useCallback(() => {
    trackEvent('participate_click', { fund_id: fund.id });
    if (!user) {
      pendingParticipate.current = true;
      setShowLoginModal(true);
      return;
    }
    setShowOptionSheet(true);
  }, [user, fund.id]);

  // Share handler — scroll to share section or trigger native share
  const handleShare = useCallback(() => {
    const shareSection = document.getElementById('share-section');
    if (shareSection) {
      shareSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, []);

  const shareUrl = typeof window !== 'undefined' ? window.location.href : '';

  return (
    <PaymentFlow fundId={fund.id} currentPrice={currentPrice}>
      {({ startPayment, isProcessing, error: flowError }) => (
        <div className="bg-bg pb-[88px]">
          <ErrorToastEffect paymentError={paymentError} flowError={flowError} />
          {/* Desktop: side-by-side / Mobile: stacked */}
          <div className="max-w-detail mx-auto tablet:flex tablet:gap-xl tablet:px-xl tablet:pt-xl">
            {/* Left: Image — constrained on desktop */}
            <div className="tablet:w-[480px] tablet:shrink-0">
              <ProductImageGallery
                images={fund.images}
                productName={fund.productName}
                className="tablet:rounded-lg tablet:overflow-hidden"
              />
            </div>

            {/* Right: Info */}
            <div className="flex-1 min-w-0">
              {/* Price section */}
              <PriceSection
                brandName={fund.brandName}
                productName={fund.productName}
                currentPrice={currentPrice}
                startPrice={fund.startPrice}
                discountPercent={discountPercent}
                freeShipping={fund.freeShipping}
              />

              {/* Divider */}
              <div className="h-[8px] bg-surface tablet:h-0 tablet:border-b tablet:border-border-subtle" />

              {/* Fund progress */}
              <FundProgressSection
                tiers={fund.tiers}
                currentParticipants={fund.currentParticipants}
                maxParticipants={fund.maxParticipants}
                nextTier={nextTier}
              />

              {/* Divider */}
              <div className="h-[8px] bg-surface tablet:h-0 tablet:border-b tablet:border-border-subtle" />

              {/* Real-time info */}
              <RealTimeInfo
                currentParticipants={fund.currentParticipants}
                maxParticipants={fund.maxParticipants}
                endAt={fund.endAt}
              />

              {/* Share buttons */}
              <div id="share-section" className="py-xl">
                <p className="text-center text-[13px] text-text-secondary mb-md">
                  공유하면 가격이 더 떨어집니다
                </p>
                <ShareButtons
                  shareUrl={shareUrl}
                  productName={fund.productName}
                  imageUrl={fund.images[0]}
                  description={fund.description}
                  participantCount={fund.currentParticipants}
                  userId={user?.id}
                />
              </div>
            </div>
          </div>

          {/* Below: Full-width sections */}
          <div className="max-w-detail mx-auto">
            {/* Divider */}
            <div className="h-[8px] bg-surface" />

            {/* Product details */}
            <ProductDetails
              description={fund.description}
              detailHtml={fund.detailHtml}
              nutritionInfo={fund.nutritionInfo}
              minParticipants={fund.minParticipants}
              freeShipping={fund.freeShipping}
            />

            {/* Price tier table */}
            <div className="px-lg py-xl">
              <h2 className="text-[15px] font-bold text-text-primary mb-md">
                가격 단계
              </h2>
              <PriceTierTable
                tiers={fund.tiers}
                currentParticipants={fund.currentParticipants}
              />
            </div>
          </div>

          {/* Sticky CTA bar */}
          <StickyCtaBar
            currentPrice={currentPrice}
            onParticipate={handleParticipate}
            onShare={handleShare}
          />

          {/* Login modal */}
          <LoginModal
            isOpen={showLoginModal}
            onClose={() => {
              setShowLoginModal(false);
              pendingParticipate.current = false;
            }}
          />

          {/* Option bottom sheet */}
          <OptionBottomSheet
            isOpen={showOptionSheet}
            onClose={() => setShowOptionSheet(false)}
            productName={fund.productName}
            currentPrice={currentPrice}
            options={fund.options}
            user={user}
            onSubmit={(data) => {
              setShowOptionSheet(false);
              startPayment(data);
            }}
            isSubmitting={isProcessing}
          />
        </div>
      )}
    </PaymentFlow>
  );
}

/* -- Toast bridge for errors inside PaymentFlow render prop ---------------- */

function ErrorToastEffect({ paymentError, flowError }: { paymentError: string | null; flowError: string | null | undefined }) {
  const { toast } = useToast();

  useEffect(() => {
    const msg = paymentError || flowError;
    if (msg) toast({ variant: 'error', message: msg });
  }, [paymentError, flowError, toast]);

  return null;
}

export { FundDetailClient };
export type { FundDetailClientProps };
