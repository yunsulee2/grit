// Supabase DB row types — PRD Section 4

export type FundStatus =
  | 'DRAFT'
  | 'OPEN'
  | 'CLOSED_SUCCESS'
  | 'CLOSED_FAIL'
  | 'SHIPPING'
  | 'COMPLETED';

export type OrderStatus =
  | 'PENDING'
  | 'PAID'
  | 'REFUNDED_PARTIAL'
  | 'REFUNDED_FULL'
  | 'SHIPPING'
  | 'COMPLETED'
  | 'CANCELLED';

export type ShareChannel = 'kakao' | 'link_copy' | 'instagram';

export type ProductCategory =
  | '닭가슴살'
  | '프로틴'
  | '간식/간편식'
  | '음료'
  | '도시락'
  | '샐러드'
  | '소스/시즌닝';

export interface UserRow {
  id: string;
  kakao_id: string;
  name: string;
  phone: string | null;
  address: string | null;
  address_detail: string | null;
  zipcode: string | null;
  created_at: string;
}

export interface SellerRow {
  id: string;
  name: string;
  brand_name: string;
  contact_name: string;
  contact_phone: string;
  instagram: string | null;
  smartstore_url: string | null;
  commission_rate: number;
  created_at: string;
}

export interface ProductRow {
  id: string;
  seller_id: string;
  name: string;
  description: string;
  detail_html: string | null;
  nutrition_info: NutritionInfo | null;
  images: string[];
  category: ProductCategory;
  options: ProductOption[] | null;
  created_at: string;
}

export interface NutritionInfo {
  calories?: number;
  protein?: number;
  fat?: number;
  carbs?: number;
  sodium?: number;
  serving_size?: string;
}

export interface ProductOption {
  name: string;
  values: string[];
}

export interface FundRow {
  id: string;
  product_id: string;
  status: FundStatus;
  start_at: string;
  end_at: string;
  min_participants: number;
  max_participants: number | null;
  current_participants: number;
  final_price: number | null;
  created_at: string;
}

export interface PriceTierRow {
  id: string;
  fund_id: string;
  min_quantity: number;
  price: number;
  sort_order: number;
}

export interface OrderRow {
  id: string;
  fund_id: string;
  user_id: string;
  quantity: number;
  option_value: string | null;
  paid_price: number;
  final_price: number | null;
  refund_amount: number | null;
  status: OrderStatus;
  payment_key: string | null;
  address: string;
  address_detail: string | null;
  zipcode: string;
  phone: string;
  tracking_number: string | null;
  created_at: string;
}

export interface ShareRow {
  id: string;
  fund_id: string;
  user_id: string | null;
  channel: ShareChannel;
  created_at: string;
}
