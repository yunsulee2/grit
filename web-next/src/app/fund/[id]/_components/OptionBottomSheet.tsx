'use client';

import { useState, useEffect, useCallback } from 'react';
import { cn } from '@/lib/utils';
import { formatPrice } from '@/lib/utils';
import { MAX_QUANTITY } from '@/lib/constants';
import type { ProductOption } from '@/types/database';
import type { UserProfile } from '@/types/user';

interface OptionBottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  productName: string;
  currentPrice: number;
  options: ProductOption[] | null;
  user: UserProfile | null;
  onSubmit: (data: {
    quantity: number;
    optionValue: string | null;
    address: string;
    addressDetail: string;
    zipcode: string;
    phone: string;
  }) => void;
  isSubmitting: boolean;
}

function OptionBottomSheet({
  isOpen,
  onClose,
  productName,
  currentPrice,
  options,
  user,
  onSubmit,
  isSubmitting,
}: OptionBottomSheetProps) {
  const [quantity, setQuantity] = useState(1);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [useSavedAddress, setUseSavedAddress] = useState(!!user?.address);
  const [address, setAddress] = useState(user?.address ?? '');
  const [addressDetail, setAddressDetail] = useState(user?.addressDetail ?? '');
  const [zipcode, setZipcode] = useState(user?.zipcode ?? '');
  const [phone, setPhone] = useState(user?.phone ?? '');

  // Reset state when opened
  useEffect(() => {
    if (isOpen) {
      setQuantity(1);
      setSelectedOption(options?.[0]?.values[0] ?? null);
      const hasSaved = !!(user?.address && user?.zipcode && user?.phone);
      setUseSavedAddress(hasSaved);
      setAddress(user?.address ?? '');
      setAddressDetail(user?.addressDetail ?? '');
      setZipcode(user?.zipcode ?? '');
      setPhone(user?.phone ?? '');
    }
  }, [isOpen, user, options]);

  // Prevent body scroll
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  // Close on Escape
  useEffect(() => {
    if (!isOpen) return;
    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  const totalPrice = currentPrice * quantity;

  const hasSavedAddress = !!(user?.address && user?.zipcode && user?.phone);

  const canSubmit =
    !isSubmitting &&
    quantity >= 1 &&
    quantity <= MAX_QUANTITY &&
    address.trim() !== '' &&
    zipcode.trim() !== '' &&
    phone.trim() !== '';

  const handleSubmit = useCallback(() => {
    if (!canSubmit) return;
    onSubmit({
      quantity,
      optionValue: selectedOption,
      address: address.trim(),
      addressDetail: addressDetail.trim(),
      zipcode: zipcode.trim(),
      phone: phone.trim(),
    });
  }, [canSubmit, quantity, selectedOption, address, addressDetail, zipcode, phone, onSubmit]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-end tablet:items-center justify-center bg-black/50"
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
      role="dialog"
      aria-modal="true"
      aria-label="옵션 선택"
    >
      <div className="w-full max-w-content tablet:rounded-lg tablet:max-w-[560px] tablet:mx-auto bg-surface-elevated rounded-t-lg overflow-hidden animate-slide-up">
        {/* Handle bar */}
        <div className="flex justify-center pt-sm pb-xs tablet:hidden">
          <div className="w-[36px] h-[4px] rounded-full bg-border" />
        </div>

        <div className="max-h-[80vh] overflow-y-auto px-lg pb-lg">
          {/* Header */}
          <div className="py-lg border-b border-border-subtle mb-lg">
            <h3 className="text-[15px] font-bold text-text-primary">{productName}</h3>
            <p className="text-[14px] text-text-secondary mt-xs">
              현재가 {formatPrice(currentPrice)}
            </p>
          </div>

          {/* Option selector */}
          {options && options.length > 0 && (
            <div className="mb-xl">
              <label className="block text-[13px] font-semibold text-text-primary mb-sm">
                {options[0].name}
              </label>
              <select
                value={selectedOption ?? ''}
                onChange={(e) => setSelectedOption(e.target.value)}
                className="w-full h-[44px] px-md border border-border rounded-sm text-[14px] text-text-primary bg-bg focus:border-border-focus focus:outline-none"
              >
                {options[0].values.map((v) => (
                  <option key={v} value={v}>
                    {v}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Quantity stepper */}
          <div className="mb-xl">
            <label className="block text-[13px] font-semibold text-text-primary mb-sm">
              수량
            </label>
            <div className="inline-flex items-center border border-border rounded-sm">
              <button
                type="button"
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
                disabled={quantity <= 1}
                className="w-[44px] h-[44px] flex items-center justify-center text-text-primary disabled:text-text-tertiary cursor-pointer disabled:cursor-not-allowed"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
              </button>
              <span className="w-[48px] text-center text-[15px] font-bold text-text-primary border-x border-border">
                {quantity}
              </span>
              <button
                type="button"
                onClick={() => setQuantity(Math.min(MAX_QUANTITY, quantity + 1))}
                disabled={quantity >= MAX_QUANTITY}
                className="w-[44px] h-[44px] flex items-center justify-center text-text-primary disabled:text-text-tertiary cursor-pointer disabled:cursor-not-allowed"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <line x1="12" y1="5" x2="12" y2="19" />
                  <line x1="5" y1="12" x2="19" y2="12" />
                </svg>
              </button>
            </div>
          </div>

          {/* Delivery address */}
          <div className="mb-xl">
            <label className="block text-[13px] font-semibold text-text-primary mb-sm">
              배송지
            </label>

            {hasSavedAddress && (
              <label className="flex items-center gap-sm mb-md cursor-pointer">
                <input
                  type="checkbox"
                  checked={useSavedAddress}
                  onChange={(e) => {
                    setUseSavedAddress(e.target.checked);
                    if (e.target.checked) {
                      setAddress(user?.address ?? '');
                      setAddressDetail(user?.addressDetail ?? '');
                      setZipcode(user?.zipcode ?? '');
                      setPhone(user?.phone ?? '');
                    } else {
                      setAddress('');
                      setAddressDetail('');
                      setZipcode('');
                      setPhone('');
                    }
                  }}
                  className="w-[18px] h-[18px] accent-primary"
                />
                <span className="text-[13px] text-text-secondary">기본 배송지 사용</span>
              </label>
            )}

            <div className="space-y-sm">
              <input
                type="text"
                placeholder="우편번호"
                value={zipcode}
                onChange={(e) => setZipcode(e.target.value)}
                disabled={useSavedAddress && hasSavedAddress}
                className="w-full h-[44px] px-md border border-border rounded-sm text-[14px] text-text-primary bg-bg focus:border-border-focus focus:outline-none disabled:bg-surface disabled:text-text-secondary"
              />
              <input
                type="text"
                placeholder="주소"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                disabled={useSavedAddress && hasSavedAddress}
                className="w-full h-[44px] px-md border border-border rounded-sm text-[14px] text-text-primary bg-bg focus:border-border-focus focus:outline-none disabled:bg-surface disabled:text-text-secondary"
              />
              <input
                type="text"
                placeholder="상세주소"
                value={addressDetail}
                onChange={(e) => setAddressDetail(e.target.value)}
                disabled={useSavedAddress && hasSavedAddress}
                className="w-full h-[44px] px-md border border-border rounded-sm text-[14px] text-text-primary bg-bg focus:border-border-focus focus:outline-none disabled:bg-surface disabled:text-text-secondary"
              />
              <input
                type="tel"
                placeholder="연락처"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                disabled={useSavedAddress && hasSavedAddress}
                className="w-full h-[44px] px-md border border-border rounded-sm text-[14px] text-text-primary bg-bg focus:border-border-focus focus:outline-none disabled:bg-surface disabled:text-text-secondary"
              />
            </div>
          </div>

          {/* Refund notice */}
          <div className="mb-xl p-md bg-semantic-info-muted rounded-sm">
            <p className="text-[13px] text-semantic-info leading-relaxed">
              가격이 더 떨어지면 차액을 돌려드립니다
            </p>
          </div>

          {/* Total + submit */}
          <div className="border-t border-border-subtle pt-lg">
            <div className="flex items-center justify-between mb-lg">
              <span className="text-[14px] text-text-secondary">총 결제금액</span>
              <span className="text-[20px] font-extrabold text-text-primary">
                {formatPrice(totalPrice)}
              </span>
            </div>

            <button
              type="button"
              onClick={handleSubmit}
              disabled={!canSubmit}
              className="w-full h-[52px] flex items-center justify-center bg-primary text-onPrimary rounded-sm font-bold text-[15px] hover:bg-primary/90 active:bg-primary/80 transition-colors disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
            >
              {isSubmitting ? '처리 중...' : `결제하기 ${formatPrice(totalPrice)}`}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export { OptionBottomSheet };
export type { OptionBottomSheetProps };
