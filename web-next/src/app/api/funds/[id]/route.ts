import { NextRequest, NextResponse } from 'next/server';
import { getMockFundDetail } from '@/lib/mock-data';
import { createClient } from '@/lib/supabase/server';
import type { FundDetailData } from '@/types/fund';
import { calculateCurrentPrice, getNextTier, getDiscountPercent } from '@/lib/utils';

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;

  try {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from('funds')
      .select(
        `
        id,
        status,
        start_at,
        end_at,
        min_participants,
        max_participants,
        current_participants,
        final_price,
        products (
          id,
          name,
          description,
          detail_html,
          images,
          category,
          nutrition_info,
          options,
          sellers (
            name,
            brand_name
          )
        ),
        price_tiers (
          id,
          min_quantity,
          price,
          sort_order
        )
      `
      )
      .eq('id', id)
      .single();

    if (error) throw error;
    if (!data) throw new Error('Not found');

    const r = data as unknown as {
      id: string;
      status: string;
      start_at: string;
      end_at: string;
      min_participants: number;
      max_participants: number | null;
      current_participants: number;
      final_price: number | null;
      products: {
        id: string;
        name: string;
        description: string;
        detail_html: string | null;
        images: string[];
        category: string;
        nutrition_info: Record<string, unknown> | null;
        options: { name: string; values: string[] }[] | null;
        sellers: { name: string; brand_name: string } | null;
      } | null;
      price_tiers: { id: string; min_quantity: number; price: number; sort_order: number }[];
    };

    if (!r.products) {
      return NextResponse.json({ error: 'Fund not found' }, { status: 404 });
    }

    const tiers = [...r.price_tiers]
      .sort((a, b) => a.sort_order - b.sort_order)
      .map((t) => ({ minQuantity: t.min_quantity, price: t.price }));

    if (tiers.length === 0) {
      return NextResponse.json({ error: 'Fund not found' }, { status: 404 });
    }

    const startPrice = tiers[0].price;
    const currentPrice = calculateCurrentPrice(tiers, r.current_participants);
    const discountPercent = getDiscountPercent(startPrice, currentPrice);
    const targetPrice = tiers[tiers.length - 1].price;
    const nextTier = getNextTier(tiers, r.current_participants);

    const detail: FundDetailData = {
      id: r.id,
      productName: r.products.name,
      brandName: r.products.sellers?.brand_name ?? '',
      category: r.products.category,
      imageUrl: r.products.images[0] ?? '',
      startPrice,
      currentPrice,
      targetPrice,
      discountPercent,
      currentParticipants: r.current_participants,
      maxParticipants: r.max_participants,
      endAt: r.end_at,
      status: r.status as FundDetailData['status'],
      freeShipping: false,
      nextTier,
      description: r.products.description,
      detailHtml: r.products.detail_html,
      images: r.products.images,
      nutritionInfo: r.products.nutrition_info as FundDetailData['nutritionInfo'],
      options: r.products.options as FundDetailData['options'],
      tiers,
      sellerName: r.products.sellers?.name ?? r.products.sellers?.brand_name ?? '',
      minParticipants: r.min_participants,
    };

    return NextResponse.json({ data: detail });
  } catch {
    // Supabase not configured or query failed — fall back to mock data
    const mockDetail = getMockFundDetail(id);

    if (!mockDetail) {
      return NextResponse.json({ error: 'Fund not found' }, { status: 404 });
    }

    return NextResponse.json({ data: mockDetail });
  }
}
