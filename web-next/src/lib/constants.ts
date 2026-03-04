export const FUND_STATUSES = {
  DRAFT: 'DRAFT',
  OPEN: 'OPEN',
  CLOSED_SUCCESS: 'CLOSED_SUCCESS',
  CLOSED_FAIL: 'CLOSED_FAIL',
  SHIPPING: 'SHIPPING',
  COMPLETED: 'COMPLETED',
} as const;

export const ORDER_STATUSES = {
  PENDING: 'PENDING',
  PAID: 'PAID',
  REFUNDED_PARTIAL: 'REFUNDED_PARTIAL',
  REFUNDED_FULL: 'REFUNDED_FULL',
  SHIPPING: 'SHIPPING',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
} as const;

export const CATEGORIES = [
  '전체',
  '닭가슴살',
  '프로틴',
  '간식/간편식',
  '음료',
  '도시락',
  '샐러드',
  '소스/시즌닝',
] as const;

export const FILTERS = [
  '마감임박',
  '인기순',
  '최저가순',
  '최신순',
  '무료배송',
] as const;

export const POLLING_INTERVAL = 30_000; // 30초

export const MAX_IMAGES = 5;
export const MAX_QUANTITY = 5;
