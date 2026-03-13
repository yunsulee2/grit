-- 현재 가격 계산 함수
CREATE OR REPLACE FUNCTION get_current_price(p_fund_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_participants INTEGER;
  v_price INTEGER;
BEGIN
  SELECT current_participants INTO v_participants FROM funds WHERE id = p_fund_id;

  SELECT price INTO v_price
  FROM price_tiers
  WHERE fund_id = p_fund_id AND min_quantity <= v_participants
  ORDER BY min_quantity DESC
  LIMIT 1;

  RETURN COALESCE(v_price, 0);
END;
$$ LANGUAGE plpgsql STABLE;

-- 참여 인원 원자적 증가 + 현재가 반환
CREATE OR REPLACE FUNCTION increment_participants(p_fund_id UUID, p_quantity INTEGER)
RETURNS TABLE(new_count INTEGER, new_price INTEGER) AS $$
DECLARE
  v_new_count INTEGER;
  v_max INTEGER;
  v_status TEXT;
BEGIN
  -- 펀드 상태/최대인원 확인 (FOR UPDATE로 락)
  SELECT f.status, f.max_participants, f.current_participants + p_quantity
  INTO v_status, v_max, v_new_count
  FROM funds f WHERE f.id = p_fund_id FOR UPDATE;

  IF v_status != 'OPEN' THEN
    RAISE EXCEPTION 'Fund is not open';
  END IF;

  IF v_max IS NOT NULL AND v_new_count > v_max THEN
    RAISE EXCEPTION 'Exceeds max participants';
  END IF;

  -- 원자적 업데이트
  UPDATE funds SET current_participants = v_new_count WHERE id = p_fund_id;

  -- 새 가격 계산
  RETURN QUERY
  SELECT v_new_count, get_current_price(p_fund_id);
END;
$$ LANGUAGE plpgsql;
