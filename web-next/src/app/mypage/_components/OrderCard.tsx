'use client';

import Link from 'next/link';
import Image from 'next/image';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/components/ui/Toast';
import { formatPrice } from '@/lib/utils';
import type { OrderSummary } from '@/types/order';
import type { BadgeVariant } from '@/components/ui/Badge';
import type { OrderStatus } from '@/types/database';

const STATUS_LABEL: Record<OrderStatus, string> = {
  PENDING: '결제대기',
  PAID: '결제완료',
  REFUNDED_PARTIAL: '부분환불',
  REFUNDED_FULL: '전액환불',
  SHIPPING: '배송중',
  COMPLETED: '배송완료',
  CANCELLED: '취소됨',
};

const STATUS_VARIANT: Record<OrderStatus, BadgeVariant> = {
  PENDING: 'default',
  PAID: 'info',
  REFUNDED_PARTIAL: 'warning',
  REFUNDED_FULL: 'warning',
  SHIPPING: 'accent',
  COMPLETED: 'success',
  CANCELLED: 'error',
};

interface OrderCardProps {
  order: OrderSummary;
}

function OrderCard({ order }: OrderCardProps) {
  const { toast } = useToast();
  const totalPaid = order.paidPrice * order.quantity;
  const potentialRefund =
    order.status === 'PAID' && order.currentPrice < order.paidPrice
      ? (order.paidPrice - order.currentPrice) * order.quantity
      : null;

  function handleCopyTracking(e: React.MouseEvent, trackingNumber: string) {
    e.preventDefault();
    e.stopPropagation();
    navigator.clipboard.writeText(trackingNumber).then(() => {
      toast({ variant: 'success', message: '운송장번호가 복사되었습니다' });
    }).catch(() => {
      toast({ variant: 'error', message: '복사에 실패했습니다' });
    });
  }

  function handleOpenTracking(e: React.MouseEvent, trackingNumber: string) {
    e.preventDefault();
    e.stopPropagation();
    window.open(
      `https://trace.cjlogistics.com/next/tracking.html?wblNo=${trackingNumber}`,
      '_blank',
      'noopener,noreferrer'
    );
  }

  return (
    <Link
      href={`/fund/${order.fundId}`}
      className="block bg-bg border-b border-border-subtle last:border-b-0 px-lg py-md hover:bg-surface transition-colors"
    >
      <div className="flex gap-md items-start">
        {/* Product image */}
        <div className="flex-shrink-0 w-[64px] h-[64px] rounded-xs overflow-hidden bg-surface">
          {order.productImage ? (
            <Image
              src={order.productImage}
              alt={order.productName}
              width={64}
              height={64}
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-surface-tinted">
              <svg
                className="w-6 h-6 text-text-tertiary"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
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
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          {/* Name + badge */}
          <div className="flex items-start justify-between gap-sm mb-[4px]">
            <p className="text-[14px] font-medium text-text-primary leading-snug line-clamp-2 flex-1">
              {order.productName}
            </p>
            <Badge variant={STATUS_VARIANT[order.status]} className="flex-shrink-0 mt-[1px]">
              {STATUS_LABEL[order.status]}
            </Badge>
          </div>

          {/* Option */}
          {order.optionValue && (
            <p className="text-[12px] text-text-secondary mb-[4px]">{order.optionValue}</p>
          )}

          {/* Price × quantity */}
          <p className="text-[14px] font-semibold text-text-primary">
            {formatPrice(order.paidPrice)} × {order.quantity}개
            <span className="ml-sm text-[13px] font-normal text-text-secondary">
              = {formatPrice(totalPaid)}
            </span>
          </p>

          {/* PAID: current price info + potential refund */}
          {order.status === 'PAID' && (
            <div className="mt-[6px] text-[12px] text-text-secondary">
              <span>현재 가격: {formatPrice(order.currentPrice)}</span>
              {potentialRefund !== null && potentialRefund > 0 && (
                <span className="ml-sm text-semantic-info font-medium">
                  (차액 환불 예정: {formatPrice(potentialRefund)})
                </span>
              )}
            </div>
          )}

          {/* REFUNDED_PARTIAL */}
          {order.status === 'REFUNDED_PARTIAL' && order.refundAmount !== null && (
            <p className="mt-[6px] text-[12px] text-semantic-warning font-medium">
              차액 환불 완료: {formatPrice(order.refundAmount)}
            </p>
          )}

          {/* SHIPPING: tracking number with copy + CJ Logistics link */}
          {order.status === 'SHIPPING' && order.trackingNumber && (
            <div className="mt-[6px] flex items-center gap-[6px]">
              <span className="text-[12px] text-text-secondary">송장번호:</span>
              <button
                type="button"
                onClick={(e) => handleCopyTracking(e, order.trackingNumber!)}
                className="flex items-center gap-[4px] text-[12px] font-medium text-text-primary hover:text-primary transition-colors group"
                aria-label="운송장번호 복사"
              >
                <span>{order.trackingNumber}</span>
                {/* Clipboard icon */}
                <svg
                  className="w-[13px] h-[13px] text-text-tertiary group-hover:text-primary transition-colors"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"
                  />
                </svg>
              </button>
              {/* CJ Logistics external link */}
              <button
                type="button"
                onClick={(e) => handleOpenTracking(e, order.trackingNumber!)}
                className="flex items-center text-text-tertiary hover:text-primary transition-colors"
                aria-label="배송 조회 페이지 열기"
              >
                <svg
                  className="w-[13px] h-[13px]"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                  />
                </svg>
              </button>
            </div>
          )}
        </div>

        {/* Chevron */}
        <svg
          className="flex-shrink-0 w-4 h-4 text-text-tertiary self-center"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
        </svg>
      </div>
    </Link>
  );
}

export { OrderCard };
