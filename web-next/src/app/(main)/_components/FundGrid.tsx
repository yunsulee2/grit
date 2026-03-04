'use client';

import { FundCard } from '@/components/fund/FundCard';
import type { FundCardData } from '@/types/fund';

interface FundGridProps {
  funds: FundCardData[];
}

function FundGrid({ funds }: FundGridProps) {
  if (funds.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-[80px] gap-md">
        <span className="text-[40px]" aria-hidden="true">🔍</span>
        <p className="text-[15px] font-semibold text-text-primary">
          진행 중인 공동구매가 없습니다
        </p>
        <p className="text-[13px] text-text-secondary">
          다른 카테고리나 필터를 선택해보세요
        </p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-2 tablet:grid-cols-3 gap-md">
      {funds.map((fund, index) => (
        <div
          key={fund.id}
          className="animate-fade-in-up opacity-0 [animation-fill-mode:forwards]"
          style={{ animationDelay: `${index * 50}ms` }}
        >
          <FundCard fund={fund} />
        </div>
      ))}
    </div>
  );
}

export { FundGrid };
