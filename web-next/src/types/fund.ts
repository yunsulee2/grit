import type { FundRow, PriceTierRow, ProductRow, SellerRow, FundStatus } from './database';

export interface PriceTier {
  minQuantity: number;
  price: number;
}

export interface FundWithProduct {
  fund: FundRow;
  product: ProductRow;
  seller: SellerRow;
  tiers: PriceTierRow[];
}

export interface FundCardData {
  id: string;
  productName: string;
  brandName: string;
  category: string;
  imageUrl: string;
  startPrice: number;
  currentPrice: number;
  targetPrice: number;
  discountPercent: number;
  currentParticipants: number;
  maxParticipants: number | null;
  endAt: string;
  status: FundStatus;
  freeShipping: boolean;
  nextTier: { price: number; needed: number } | null;
}

export interface FundDetailData extends FundCardData {
  description: string;
  detailHtml: string | null;
  images: string[];
  nutritionInfo: ProductRow['nutrition_info'];
  options: ProductRow['options'];
  tiers: PriceTier[];
  sellerName: string;
  minParticipants: number;
}
