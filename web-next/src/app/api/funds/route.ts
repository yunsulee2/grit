import { NextRequest, NextResponse } from 'next/server';
import { getMockFundCards } from '@/lib/mock-data';
import { createClient } from '@/lib/supabase/server';
import type { FundCardData } from '@/types/fund';
import { calculateCurrentPrice, getNextTier, getDiscountPercent } from '@/lib/utils';

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const category = searchParams.get('category') ?? undefined;

  try {
    const supabase = await createClient();

    const query = supabase
      .from('funds')
      .select(
        `
        id,
        status,
        end_at,
        min_participants,
        max_participants,
        current_participants,
        products (
          name,
          images,
          category,
          seller_id,
          sellers (
            brand_name
          )
        ),
        price_tiers (
          min_quantity,
          price,
          sort_order
        )
      `
      )
      .eq('status', 'OPEN')
      .order('created_at', { ascending: false });

    const { data, error } = await query;

    if (error) throw error;
    if (!data) throw new Error('No data returned');

    const funds: FundCardData[] = (data as unknown[]).flatMap((row) => {
      const r = row as {
        id: string;
        status: string;
        end_at: string;
        min_participants: number;
        max_participants: number | null;
        current_participants: number;
        products: {
          name: string;
          images: string[];
          category: string;
          sellers: { brand_name: string } | null;
        } | null;
        price_tiers: { min_quantity: number; price: number; sort_order: number }[];
      };

      if (!r.products) return [];

      const tiers = [...r.price_tiers]
        .sort((a, b) => a.sort_order - b.sort_order)
        .map((t) => ({ minQuantity: t.min_quantity, price: t.price }));

      if (tiers.length === 0) return [];

      const startPrice = tiers[0].price;
      const currentPrice = calculateCurrentPrice(tiers, r.current_participants);
      const discountPercent = getDiscountPercent(startPrice, currentPrice);
      const targetPrice = tiers[tiers.length - 1].price;
      const nextTier = getNextTier(tiers, r.current_participants);

      const productCategory: string = r.products.category;
      if (category && category !== '전체' && productCategory !== category) return [];

      const card: FundCardData = {
        id: r.id,
        productName: r.products.name,
        brandName: r.products.sellers?.brand_name ?? '',
        category: productCategory,
        imageUrl: r.products.images[0] ?? '',
        startPrice,
        currentPrice,
        targetPrice,
        discountPercent,
        currentParticipants: r.current_participants,
        maxParticipants: r.max_participants,
        endAt: r.end_at,
        status: 'OPEN',
        freeShipping: false,
        nextTier,
      };

      return [card];
    });

    return NextResponse.json(
      { data: funds },
      {
        headers: {
          'Cache-Control': 's-maxage=10, stale-while-revalidate=30',
        },
      }
    );
  } catch {
    // Supabase not configured or query failed — fall back to mock data
    const mockData = getMockFundCards(category);
    return NextResponse.json(
      { data: mockData },
      {
        headers: {
          'Cache-Control': 's-maxage=10, stale-while-revalidate=30',
        },
      }
    );
  }
}
