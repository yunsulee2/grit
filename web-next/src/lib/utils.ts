import type { PriceTier } from '@/types/fund';

export function formatPrice(price: number): string {
  return price.toLocaleString('ko-KR') + '원';
}

export function formatNumber(n: number): string {
  return n.toLocaleString('ko-KR');
}

export function calculateCurrentPrice(
  tiers: PriceTier[],
  currentParticipants: number
): number {
  const sorted = [...tiers].sort((a, b) => b.minQuantity - a.minQuantity);
  const matched = sorted.find((t) => t.minQuantity <= currentParticipants);
  return matched?.price ?? tiers[0]?.price ?? 0;
}

export function getNextTier(
  tiers: PriceTier[],
  currentParticipants: number
): { price: number; needed: number } | null {
  const sorted = [...tiers].sort((a, b) => a.minQuantity - b.minQuantity);
  const next = sorted.find((t) => t.minQuantity > currentParticipants);
  if (!next) return null;
  return {
    price: next.price,
    needed: next.minQuantity - currentParticipants,
  };
}

export function getDiscountPercent(startPrice: number, currentPrice: number): number {
  if (startPrice <= 0) return 0;
  return Math.round(((startPrice - currentPrice) / startPrice) * 100);
}

export function formatCountdown(endAt: string | Date): string {
  const end = typeof endAt === 'string' ? new Date(endAt) : endAt;
  const now = new Date();
  const diff = end.getTime() - now.getTime();

  if (diff <= 0) return '마감';

  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
  const seconds = Math.floor((diff % (1000 * 60)) / 1000);

  const pad = (n: number) => n.toString().padStart(2, '0');

  if (days >= 1) {
    return `${days}일 ${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
  }
  return `${pad(hours)}:${pad(minutes)}:${pad(seconds)} 남음`;
}

export function isEndingSoon(endAt: string | Date): boolean {
  const end = typeof endAt === 'string' ? new Date(endAt) : endAt;
  const diff = end.getTime() - Date.now();
  return diff > 0 && diff < 24 * 60 * 60 * 1000; // 24시간 이내
}

export function cn(...classes: (string | false | null | undefined)[]): string {
  return classes.filter(Boolean).join(' ');
}
