import type { FundCardData, FundDetailData, PriceTier } from '@/types/fund';

function daysFromNow(days: number, hours = 0, minutes = 0): string {
  const d = new Date();
  d.setDate(d.getDate() + days);
  d.setHours(d.getHours() + hours, d.getMinutes() + minutes);
  return d.toISOString();
}

function calcCurrentPrice(tiers: PriceTier[], participants: number): number {
  const sorted = [...tiers].sort((a, b) => b.minQuantity - a.minQuantity);
  return sorted.find((t) => t.minQuantity <= participants)?.price ?? tiers[0].price;
}

function calcDiscount(start: number, current: number): number {
  return Math.round(((start - current) / start) * 100);
}

function calcNextTier(tiers: PriceTier[], participants: number) {
  const sorted = [...tiers].sort((a, b) => a.minQuantity - b.minQuantity);
  const next = sorted.find((t) => t.minQuantity > participants);
  if (!next) return null;
  return { price: next.price, needed: next.minQuantity - participants };
}

interface MockFundInput {
  id: string;
  productName: string;
  brandName: string;
  category: string;
  imageUrl: string;
  description: string;
  startPrice: number;
  targetPrice: number;
  tiers: PriceTier[];
  currentParticipants: number;
  maxParticipants: number | null;
  endAt: string;
  freeShipping: boolean;
}

const rawFunds: MockFundInput[] = [
  {
    id: 'fund-001',
    productName: '퍼포먼스 닭가슴살 스팀 오리지널 1kg',
    brandName: '잇메이트',
    category: '닭가슴살',
    imageUrl: '/images/chicken1.jpg',
    description: '부드럽고 촉촉한 스팀 닭가슴살. 고단백 저지방으로 운동 후 단백질 보충에 최적.',
    startPrice: 12900,
    targetPrice: 9900,
    tiers: [
      { minQuantity: 1, price: 12900 },
      { minQuantity: 100, price: 11900 },
      { minQuantity: 500, price: 9900 },
    ],
    currentParticipants: 327,
    maxParticipants: 500,
    endAt: daysFromNow(2, 7, 15),
    freeShipping: true,
  },
  {
    id: 'fund-002',
    productName: '프로틴 바 초코 크런치 12개입',
    brandName: '머슬팜',
    category: '프로틴',
    imageUrl: '/images/protein_bar.jpg',
    description: '한 개당 단백질 20g, 식사 대용 또는 간식으로 완벽한 프로틴 바.',
    startPrice: 24000,
    targetPrice: 18000,
    tiers: [
      { minQuantity: 1, price: 24000 },
      { minQuantity: 50, price: 21000 },
      { minQuantity: 200, price: 18000 },
    ],
    currentParticipants: 89,
    maxParticipants: 200,
    endAt: daysFromNow(1, 3, 42),
    freeShipping: false,
  },
  {
    id: 'fund-003',
    productName: '곤약젤리 복숭아맛 150ml x 10팩',
    brandName: '로칼',
    category: '간식/간편식',
    imageUrl: '/images/jelly.jpg',
    description: '칼로리 걱정 없는 저칼로리 간식. 복숭아 과즙의 상큼한 맛.',
    startPrice: 15000,
    targetPrice: 10500,
    tiers: [
      { minQuantity: 1, price: 15000 },
      { minQuantity: 100, price: 12000 },
      { minQuantity: 300, price: 10500 },
    ],
    currentParticipants: 256,
    maxParticipants: 300,
    endAt: daysFromNow(0, 5, 37),
    freeShipping: true,
  },
  {
    id: 'fund-004',
    productName: '하이 프로틴 쉐이크 바나나 350ml x 6팩',
    brandName: '셀렉스',
    category: '음료',
    imageUrl: '/images/shake.jpg',
    description: '바나나맛 고단백 쉐이크. 한 병당 단백질 30g, 운동 후 바로 마시기 좋은 음료.',
    startPrice: 18000,
    targetPrice: 13500,
    tiers: [
      { minQuantity: 1, price: 18000 },
      { minQuantity: 80, price: 15000 },
      { minQuantity: 250, price: 13500 },
    ],
    currentParticipants: 142,
    maxParticipants: 250,
    endAt: daysFromNow(3, 12),
    freeShipping: true,
  },
  {
    id: 'fund-005',
    productName: '닭가슴살 소시지 매콤훈제 120g x 10팩',
    brandName: '허닭',
    category: '닭가슴살',
    imageUrl: '/images/sausage.jpg',
    description: '매콤한 훈제 닭가슴살 소시지. 간편하게 단백질 충전.',
    startPrice: 19900,
    targetPrice: 14900,
    tiers: [
      { minQuantity: 1, price: 19900 },
      { minQuantity: 100, price: 17900 },
      { minQuantity: 400, price: 14900 },
    ],
    currentParticipants: 203,
    maxParticipants: 400,
    endAt: daysFromNow(4, 8),
    freeShipping: false,
  },
  {
    id: 'fund-006',
    productName: '다이어트 도시락 닭볶음밥 250g x 6팩',
    brandName: '바르닭',
    category: '도시락',
    imageUrl: '/images/lunchbox.jpg',
    description: '칼로리 컨트롤 도시락. 닭볶음밥 한 끼 350kcal.',
    startPrice: 22000,
    targetPrice: 16500,
    tiers: [
      { minQuantity: 1, price: 22000 },
      { minQuantity: 50, price: 19000 },
      { minQuantity: 150, price: 16500 },
    ],
    currentParticipants: 67,
    maxParticipants: 150,
    endAt: daysFromNow(5, 2),
    freeShipping: true,
  },
  {
    id: 'fund-007',
    productName: '프로틴 칩 바베큐맛 40g x 8봉',
    brandName: '노브랜드',
    category: '간식/간편식',
    imageUrl: '/images/chips.jpg',
    description: '단백질이 풍부한 바베큐맛 칩. 죄책감 없는 간식.',
    startPrice: 16000,
    targetPrice: 11200,
    tiers: [
      { minQuantity: 1, price: 16000 },
      { minQuantity: 70, price: 13500 },
      { minQuantity: 200, price: 11200 },
    ],
    currentParticipants: 45,
    maxParticipants: 200,
    endAt: daysFromNow(6),
    freeShipping: false,
  },
  {
    id: 'fund-008',
    productName: '그릭요거트 플레인 500g x 4팩',
    brandName: '풀무원',
    category: '간식/간편식',
    imageUrl: '/images/yogurt.jpg',
    description: '진한 그릭요거트. 단백질 풍부, 아침 식사 대용으로 추천.',
    startPrice: 14000,
    targetPrice: 10000,
    tiers: [
      { minQuantity: 1, price: 14000 },
      { minQuantity: 60, price: 12000 },
      { minQuantity: 180, price: 10000 },
    ],
    currentParticipants: 112,
    maxParticipants: 180,
    endAt: daysFromNow(1, 18),
    freeShipping: true,
  },
  {
    id: 'fund-009',
    productName: 'BCAA 아미노산 음료 500ml x 12병',
    brandName: '셀렉스',
    category: '음료',
    imageUrl: '/images/bcaa.jpg',
    description: '운동 중 수분 보충과 함께 BCAA 섭취. 상큼한 레몬라임맛.',
    startPrice: 28000,
    targetPrice: 21000,
    tiers: [
      { minQuantity: 1, price: 28000 },
      { minQuantity: 80, price: 24000 },
      { minQuantity: 200, price: 21000 },
    ],
    currentParticipants: 156,
    maxParticipants: 200,
    endAt: daysFromNow(8),
    freeShipping: true,
  },
  {
    id: 'fund-010',
    productName: '저칼로리 샐러드 키트 5팩',
    brandName: '프레시지',
    category: '샐러드',
    imageUrl: '/images/salad.jpg',
    description: '신선한 채소와 닭가슴살이 들어간 고단백 샐러드 키트.',
    startPrice: 25000,
    targetPrice: 18000,
    tiers: [
      { minQuantity: 1, price: 25000 },
      { minQuantity: 60, price: 21000 },
      { minQuantity: 150, price: 18000 },
    ],
    currentParticipants: 42,
    maxParticipants: 150,
    endAt: daysFromNow(10),
    freeShipping: true,
  },
  {
    id: 'fund-011',
    productName: '닭가슴살 큐브 훈제 2kg',
    brandName: '아임닭',
    category: '닭가슴살',
    imageUrl: '/images/chicken2.jpg',
    description: '대용량 훈제 닭가슴살 큐브. 샐러드, 볶음밥 등 다양한 요리에 활용.',
    startPrice: 32000,
    targetPrice: 24000,
    tiers: [
      { minQuantity: 1, price: 32000 },
      { minQuantity: 100, price: 28000 },
      { minQuantity: 300, price: 24000 },
    ],
    currentParticipants: 289,
    maxParticipants: 300,
    endAt: daysFromNow(0, 12),
    freeShipping: true,
  },
  {
    id: 'fund-012',
    productName: '프로틴 쿠키 초코칩 12개입',
    brandName: '머슬비치',
    category: '프로틴',
    imageUrl: '/images/cookies.jpg',
    description: '한 개당 단백질 15g의 초코칩 쿠키. 맛있게 단백질 보충.',
    startPrice: 20000,
    targetPrice: 15000,
    tiers: [
      { minQuantity: 1, price: 20000 },
      { minQuantity: 50, price: 17000 },
      { minQuantity: 120, price: 15000 },
    ],
    currentParticipants: 34,
    maxParticipants: 120,
    endAt: daysFromNow(7),
    freeShipping: false,
  },
];

function toFundCard(f: MockFundInput): FundCardData {
  const currentPrice = calcCurrentPrice(f.tiers, f.currentParticipants);
  return {
    id: f.id,
    productName: f.productName,
    brandName: f.brandName,
    category: f.category,
    imageUrl: f.imageUrl,
    startPrice: f.startPrice,
    currentPrice,
    targetPrice: f.targetPrice,
    discountPercent: calcDiscount(f.startPrice, currentPrice),
    currentParticipants: f.currentParticipants,
    maxParticipants: f.maxParticipants,
    endAt: f.endAt,
    status: 'OPEN',
    freeShipping: f.freeShipping,
    nextTier: calcNextTier(f.tiers, f.currentParticipants),
  };
}

function toFundDetail(f: MockFundInput): FundDetailData {
  const card = toFundCard(f);
  return {
    ...card,
    description: f.description,
    detailHtml: null,
    images: [f.imageUrl],
    nutritionInfo: { calories: 150, protein: 30, fat: 3, carbs: 2, serving_size: '100g' },
    options: null,
    tiers: f.tiers,
    sellerName: f.brandName,
    minParticipants: f.tiers[0]?.minQuantity ?? 1,
  };
}

export const mockFundCards: FundCardData[] = rawFunds.map(toFundCard);

export const mockFundDetails: Record<string, FundDetailData> = Object.fromEntries(
  rawFunds.map((f) => [f.id, toFundDetail(f)])
);

export function getMockFundCards(category?: string): FundCardData[] {
  if (!category || category === '전체') return mockFundCards;
  return mockFundCards.filter((f) => f.category === category);
}

export function getMockFundDetail(id: string): FundDetailData | null {
  return mockFundDetails[id] ?? null;
}
