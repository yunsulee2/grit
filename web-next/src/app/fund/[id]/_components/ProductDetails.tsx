'use client';

import { useState } from 'react';
import { cn } from '@/lib/utils';
import { sanitizeHtml } from '@/lib/sanitize';
import type { NutritionInfo } from '@/types/database';

interface ProductDetailsProps {
  description: string;
  detailHtml: string | null;
  nutritionInfo: NutritionInfo | null;
  minParticipants: number;
  freeShipping: boolean;
  className?: string;
}

function ProductDetails({
  description,
  detailHtml,
  nutritionInfo,
  minParticipants,
  freeShipping,
  className,
}: ProductDetailsProps) {
  return (
    <div className={cn('border-t border-border-subtle', className)}>
      {/* Product description */}
      <CollapsibleSection title="상품 설명" defaultOpen>
        <p className="text-[14px] text-text-primary leading-relaxed whitespace-pre-line">
          {description}
        </p>
        {detailHtml && (
          <div
            className="mt-lg text-[14px] text-text-primary leading-relaxed prose prose-sm max-w-none"
            dangerouslySetInnerHTML={{ __html: sanitizeHtml(detailHtml) }}
          />
        )}
      </CollapsibleSection>

      {/* Nutrition info */}
      {nutritionInfo && (
        <CollapsibleSection title="영양정보">
          <NutritionTable info={nutritionInfo} />
        </CollapsibleSection>
      )}

      {/* Shipping info */}
      <CollapsibleSection title="배송 안내">
        <ul className="text-[14px] text-text-primary leading-relaxed space-y-sm list-disc pl-lg">
          <li>{freeShipping ? '무료배송' : '배송비 별도 (상품에 따라 상이)'}</li>
          <li>펀드 성사 후 셀러에서 직접 배송합니다</li>
          <li>펀드 종료 후 3~5일 이내 출고 예정</li>
          <li>도서·산간 지역은 추가 배송비가 발생할 수 있습니다</li>
        </ul>
      </CollapsibleSection>

      {/* Group buy rules */}
      <CollapsibleSection title="공동구매 규칙">
        <ul className="text-[14px] text-text-primary leading-relaxed space-y-sm list-disc pl-lg">
          <li>
            최소 <strong>{minParticipants}명</strong> 이상 참여 시 펀드가 성사됩니다
          </li>
          <li>참여 인원이 늘수록 가격이 단계적으로 낮아집니다</li>
          <li>결제 시점의 가격으로 결제되며, 최종 가격이 더 낮으면 차액을 환불해 드립니다</li>
          <li>최소 인원 미달 시 전액 환불됩니다</li>
          <li>펀드 종료 후에는 참여 취소가 불가합니다</li>
        </ul>
      </CollapsibleSection>
    </div>
  );
}

/* -- Collapsible section --------------------------------------------------- */

function CollapsibleSection({
  title,
  defaultOpen = false,
  children,
}: {
  title: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(defaultOpen);

  return (
    <div className="border-b border-border-subtle">
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between px-lg py-lg cursor-pointer"
      >
        <span className="text-[15px] font-bold text-text-primary">{title}</span>
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className={cn(
            'text-text-tertiary transition-transform duration-200',
            open && 'rotate-180'
          )}
        >
          <polyline points="6 9 12 15 18 9" />
        </svg>
      </button>
      <div
        className={cn(
          'grid transition-[grid-template-rows] duration-300 ease-out',
          open ? 'grid-rows-[1fr]' : 'grid-rows-[0fr]'
        )}
      >
        <div className="overflow-hidden min-h-0">
          <div className="px-lg pb-xl">{children}</div>
        </div>
      </div>
    </div>
  );
}

/* -- Nutrition table ------------------------------------------------------- */

function NutritionTable({ info }: { info: NutritionInfo }) {
  const rows: { label: string; value: string }[] = [];

  if (info.serving_size) rows.push({ label: '1회 제공량', value: info.serving_size });
  if (info.calories != null) rows.push({ label: '칼로리', value: `${info.calories}kcal` });
  if (info.protein != null) rows.push({ label: '단백질', value: `${info.protein}g` });
  if (info.fat != null) rows.push({ label: '지방', value: `${info.fat}g` });
  if (info.carbs != null) rows.push({ label: '탄수화물', value: `${info.carbs}g` });
  if (info.sodium != null) rows.push({ label: '나트륨', value: `${info.sodium}mg` });

  if (rows.length === 0) return null;

  return (
    <table className="w-full text-[13px]">
      <tbody>
        {rows.map((row) => (
          <tr key={row.label} className="border-b border-border-subtle last:border-0">
            <td className="py-sm text-text-secondary w-[100px]">{row.label}</td>
            <td className="py-sm text-text-primary font-medium">{row.value}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export { ProductDetails };
export type { ProductDetailsProps };
