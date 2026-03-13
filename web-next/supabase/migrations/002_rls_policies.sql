-- Row Level Security 정책

-- Users: 본인 데이터만 읽기/수정
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- Products: 누구나 읽기 가능
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Products are public" ON products FOR SELECT USING (true);

-- Sellers: 누구나 읽기 가능
ALTER TABLE sellers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Sellers are public" ON sellers FOR SELECT USING (true);

-- Funds: 누구나 읽기 가능
ALTER TABLE funds ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Funds are public" ON funds FOR SELECT USING (true);

-- Price Tiers: 누구나 읽기 가능
ALTER TABLE price_tiers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Price tiers are public" ON price_tiers FOR SELECT USING (true);

-- Orders: 본인 주문만 읽기
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Shares: 누구나 생성 가능, 읽기는 본인만
ALTER TABLE shares ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can create shares" ON shares FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can read own shares" ON shares FOR SELECT USING (auth.uid() = user_id);
