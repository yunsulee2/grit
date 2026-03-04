'use client';

import { useCallback, useState } from 'react';
import { useRouter } from 'next/navigation';
import type { CreateOrderRequest, CreateOrderResponse } from '@/types/order';
import { trackEvent } from '@/lib/analytics';

interface PaymentFlowProps {
  fundId: string;
  currentPrice: number;
  children: (props: {
    startPayment: (data: {
      quantity: number;
      optionValue: string | null;
      address: string;
      addressDetail: string;
      zipcode: string;
      phone: string;
    }) => void;
    isProcessing: boolean;
    error: string | null;
  }) => React.ReactNode;
}

function PaymentFlow({ fundId, currentPrice, children }: PaymentFlowProps) {
  const router = useRouter();
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const startPayment = useCallback(
    async (data: {
      quantity: number;
      optionValue: string | null;
      address: string;
      addressDetail: string;
      zipcode: string;
      phone: string;
    }) => {
      setIsProcessing(true);
      setError(null);

      try {
        trackEvent('payment_start', { fund_id: fundId, amount: currentPrice * data.quantity });

        const orderReq: CreateOrderRequest = {
          fundId,
          quantity: data.quantity,
          optionValue: data.optionValue ?? undefined,
          address: data.address,
          addressDetail: data.addressDetail || undefined,
          zipcode: data.zipcode,
          phone: data.phone,
        };

        const res = await fetch('/api/orders/create', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(orderReq),
        });

        if (!res.ok) {
          const body = await res.json().catch(() => null);
          throw new Error(body?.error ?? '주문 생성에 실패했습니다');
        }

        const orderData: CreateOrderResponse = await res.json();

        // Attempt TossPayments widget
        // If tossPayments SDK is loaded, use it; otherwise mock flow
        if (typeof window !== 'undefined' && (window as TossWindow).TossPayments) {
          const tossPayments = (window as TossWindow).TossPayments!(
            process.env.NEXT_PUBLIC_TOSS_CLIENT_KEY ?? 'test_ck_placeholder'
          );

          await tossPayments.requestPayment('카드', {
            amount: orderData.amount,
            orderId: orderData.orderId,
            orderName: orderData.orderName,
            customerKey: orderData.customerKey,
            successUrl: `${window.location.origin}/api/payments/confirm?fundId=${fundId}`,
            failUrl: `${window.location.origin}/fund/${fundId}?payment=failed`,
          });
        } else {
          // Mock payment flow — redirect directly to complete page
          router.push(`/fund/${fundId}/complete?orderId=${orderData.orderId}`);
        }
      } catch (err) {
        const message = err instanceof Error ? err.message : '결제 중 오류가 발생했습니다';
        setError(message);
        console.error('[PaymentFlow] Error:', err);
      } finally {
        setIsProcessing(false);
      }
    },
    [fundId, router]
  );

  return <>{children({ startPayment, isProcessing, error })}</>;
}

/* -- TossPayments type augmentation --------------------------------------- */

interface TossPaymentsInstance {
  requestPayment: (
    method: string,
    options: {
      amount: number;
      orderId: string;
      orderName: string;
      customerKey: string;
      successUrl: string;
      failUrl: string;
    }
  ) => Promise<void>;
}

interface TossWindow extends Window {
  TossPayments?: (clientKey: string) => TossPaymentsInstance;
}

export { PaymentFlow };
export type { PaymentFlowProps };
