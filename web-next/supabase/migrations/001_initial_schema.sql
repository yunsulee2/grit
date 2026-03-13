-- GRIT 초기 스키마 — PRD Section 4

-- Users (구매자)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kakao_id TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  address_detail TEXT,
  zipcode TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Sellers (셀러) — MVP에서는 직접 DB 입력
CREATE TABLE sellers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  brand_name TEXT NOT NULL,
  contact_name TEXT NOT NULL,
  contact_phone TEXT NOT NULL,
  instagram TEXT,
  smartstore_url TEXT,
  commission_rate DECIMAL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Products (상품)
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID NOT NULL REFERENCES sellers(id),
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  detail_html TEXT,
  nutrition_info JSONB,
  images TEXT[] DEFAULT '{}',
  category TEXT NOT NULL,
  options JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Funds (펀드)
CREATE TABLE funds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id),
  status TEXT NOT NULL DEFAULT 'DRAFT'
    CHECK (status IN ('DRAFT','OPEN','CLOSED_SUCCESS','CLOSED_FAIL','SHIPPING','COMPLETED')),
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  min_participants INTEGER NOT NULL DEFAULT 1,
  max_participants INTEGER,
  current_participants INTEGER NOT NULL DEFAULT 0,
  final_price INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Price Tiers (가격 단계)
CREATE TABLE price_tiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fund_id UUID NOT NULL REFERENCES funds(id) ON DELETE CASCADE,
  min_quantity INTEGER NOT NULL,
  price INTEGER NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
);

-- Orders (주문)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fund_id UUID NOT NULL REFERENCES funds(id),
  user_id UUID NOT NULL REFERENCES users(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  option_value TEXT,
  paid_price INTEGER NOT NULL,
  final_price INTEGER,
  refund_amount INTEGER,
  status TEXT NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','PAID','REFUNDED_PARTIAL','REFUNDED_FULL','SHIPPING','COMPLETED','CANCELLED')),
  payment_key TEXT,
  address TEXT NOT NULL,
  address_detail TEXT,
  zipcode TEXT NOT NULL,
  phone TEXT NOT NULL,
  tracking_number TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Shares (공유 추적)
CREATE TABLE shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fund_id UUID NOT NULL REFERENCES funds(id),
  user_id UUID REFERENCES users(id),
  channel TEXT NOT NULL CHECK (channel IN ('kakao','link_copy','instagram')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_funds_status ON funds(status);
CREATE INDEX idx_funds_product ON funds(product_id);
CREATE INDEX idx_orders_fund ON orders(fund_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_price_tiers_fund ON price_tiers(fund_id);
CREATE INDEX idx_shares_fund ON shares(fund_id);
