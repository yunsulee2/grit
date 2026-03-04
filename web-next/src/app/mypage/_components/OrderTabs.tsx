'use client';

import { useState } from 'react';
import { cn } from '@/lib/utils';
import { OrderCard } from './OrderCard';
import type { OrderSummary } from '@/types/order';
import type { OrderStatus } from '@/types/database';

type TabKey = 'active' | 'shipping' | 'completed';

const ACTIVE_STATUSES: OrderStatus[] = ['PAID', 'PENDING'];
const SHIPPING_STATUSES: OrderStatus[] = ['SHIPPING'];
const COMPLETED_STATUSES: OrderStatus[] = ['COMPLETED', 'REFUNDED_PARTIAL', 'REFUNDED_FULL', 'CANCELLED'];

interface TabConfig {
  key: TabKey;
  label: string;
  statuses: OrderStatus[];
}

const TABS: TabConfig[] = [
  { key: 'active', label: '참여 중', statuses: ACTIVE_STATUSES },
  { key: 'shipping', label: '배송 중', statuses: SHIPPING_STATUSES },
  { key: 'completed', label: '완료', statuses: COMPLETED_STATUSES },
];

interface OrderTabsProps {
  orders: OrderSummary[];
}

function OrderTabs({ orders }: OrderTabsProps) {
  const [activeTab, setActiveTab] = useState<TabKey>('active');

  const countForTab = (statuses: OrderStatus[]) =>
    orders.filter((o) => statuses.includes(o.status)).length;

  const currentOrders = orders.filter((o) => {
    const tab = TABS.find((t) => t.key === activeTab);
    return tab ? tab.statuses.includes(o.status) : false;
  });

  return (
    <div>
      {/* Tab bar */}
      <div role="tablist" className="flex border-b border-border-subtle bg-bg">
        {TABS.map((tab) => {
          const count = countForTab(tab.statuses);
          const isActive = activeTab === tab.key;
          return (
            <button
              key={tab.key}
              role="tab"
              aria-selected={isActive}
              onClick={() => setActiveTab(tab.key)}
              className={cn(
                'flex-1 flex items-center justify-center gap-[4px] py-md text-[14px] transition-colors',
                isActive
                  ? 'border-b-2 border-primary font-semibold text-primary'
                  : 'text-text-secondary hover:text-text-primary'
              )}
            >
              {tab.label}
              {count > 0 && (
                <span
                  className={cn(
                    'inline-flex items-center justify-center min-w-[18px] h-[18px] rounded-full text-[11px] font-semibold px-[5px]',
                    isActive
                      ? 'bg-primary text-onPrimary'
                      : 'bg-surface-tinted text-text-secondary'
                  )}
                >
                  {count}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Order list */}
      <div className="mt-sm">
        {currentOrders.length === 0 ? (
          <div className="py-3xl text-center text-[14px] text-text-tertiary">
            주문 내역이 없습니다.
          </div>
        ) : (
          <div className="bg-bg rounded-sm overflow-hidden border border-border-subtle">
            {currentOrders.map((order) => (
              <OrderCard key={order.id} order={order} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export { OrderTabs };
