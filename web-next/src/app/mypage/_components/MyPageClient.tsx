'use client';

import { useEffect, useState } from 'react';
import { useUser } from '@/components/auth/UserContext';
import { Button } from '@/components/ui/Button';
import { ProfileSection } from './ProfileSection';
import { OrderTabs } from './OrderTabs';
import { MenuSection } from './MenuSection';
import type { OrderSummary } from '@/types/order';

// Mock orders for fallback / dev
const MOCK_ORDERS: OrderSummary[] = [
  {
    id: 'order-1',
    fundId: 'fund-1',
    productName: '프리미엄 닭가슴살 1kg (훈제맛)',
    productImage: '',
    quantity: 2,
    optionValue: '훈제맛',
    paidPrice: 6500,
    finalPrice: null,
    refundAmount: null,
    status: 'PAID',
    trackingNumber: null,
    createdAt: new Date().toISOString(),
    fundEndAt: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
    fundStatus: 'OPEN',
    currentPrice: 5800,
  },
  {
    id: 'order-2',
    fundId: 'fund-2',
    productName: '웨이 프로틴 2kg 초코맛',
    productImage: '',
    quantity: 1,
    optionValue: '초코맛',
    paidPrice: 48000,
    finalPrice: 42000,
    refundAmount: 6000,
    status: 'REFUNDED_PARTIAL',
    trackingNumber: null,
    createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    fundEndAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
    fundStatus: 'CLOSED_SUCCESS',
    currentPrice: 42000,
  },
  {
    id: 'order-3',
    fundId: 'fund-3',
    productName: '단백질 그래놀라 500g',
    productImage: '',
    quantity: 1,
    optionValue: null,
    paidPrice: 12000,
    finalPrice: 10500,
    refundAmount: 1500,
    status: 'SHIPPING',
    trackingNumber: '1234567890',
    createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
    fundEndAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
    fundStatus: 'SHIPPING',
    currentPrice: 10500,
  },
];

function LoadingSpinner() {
  return (
    <div className="flex items-center justify-center py-3xl">
      <svg
        className="animate-spin h-6 w-6 text-text-tertiary"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
        <path
          className="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
        />
      </svg>
    </div>
  );
}

function LoginPrompt({ onLogin }: { onLogin: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center py-[80px] px-lg text-center">
      <div className="w-[64px] h-[64px] rounded-full bg-surface-tinted flex items-center justify-center mb-xl">
        <svg className="w-8 h-8 text-text-tertiary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={1.5}
            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
          />
        </svg>
      </div>
      <p className="text-[16px] font-semibold text-text-primary mb-sm">
        로그인이 필요합니다
      </p>
      <p className="text-[14px] text-text-secondary mb-xl">
        참여 내역과 배송 현황을 확인하려면 로그인해 주세요.
      </p>
      <Button
        onClick={onLogin}
        variant="accent"
        size="lg"
        fullWidth
        className="max-w-[280px]"
      >
        <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 3C7.03 3 3 6.36 3 10.5c0 2.67 1.65 5.01 4.15 6.4L6.1 21l4.5-2.25c.46.07.93.1 1.4.1 4.97 0 9-3.36 9-7.5S16.97 3 12 3z" />
        </svg>
        카카오로 로그인
      </Button>
    </div>
  );
}

function MyPageClient() {
  const { user, isLoading, signInWithKakao } = useUser();
  const [orders, setOrders] = useState<OrderSummary[]>([]);
  const [ordersLoading, setOrdersLoading] = useState(false);

  useEffect(() => {
    if (!user) return;

    setOrdersLoading(true);
    fetch('/api/users/me/orders')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to fetch orders');
        return res.json();
      })
      .then((json) => setOrders(json.data ?? []))
      .catch(() => {
        // Fall back to mock data when API is unavailable
        setOrders(MOCK_ORDERS);
      })
      .finally(() => setOrdersLoading(false));
  }, [user]);

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (!user) {
    return <LoginPrompt onLogin={signInWithKakao} />;
  }

  return (
    <div>
      <ProfileSection user={user} />

      <div className="px-lg py-lg">
        {ordersLoading ? (
          <LoadingSpinner />
        ) : (
          <OrderTabs orders={orders} />
        )}

        <MenuSection />
      </div>
    </div>
  );
}

export { MyPageClient };
