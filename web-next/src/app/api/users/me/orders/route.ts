import { createClient } from '@/lib/supabase/server';
import { NextResponse } from 'next/server';
import type { OrderSummary } from '@/types/order';
import type { OrderStatus } from '@/types/database';

export async function GET(request: Request) {
  const isConfigured =
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!isConfigured) {
    return NextResponse.json({ data: [], error: null });
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const statusFilter = searchParams.get('status') as OrderStatus | null;

  // Valid order statuses
  const validStatuses: OrderStatus[] = [
    'PENDING',
    'PAID',
    'REFUNDED_PARTIAL',
    'REFUNDED_FULL',
    'SHIPPING',
    'COMPLETED',
    'CANCELLED',
  ];

  if (statusFilter && !validStatuses.includes(statusFilter)) {
    return NextResponse.json(
      { error: `Invalid status. Must be one of: ${validStatuses.join(', ')}` },
      { status: 400 }
    );
  }

  // Build query: join orders → funds → products
  let query = supabase
    .from('orders')
    .select(
      `
      id,
      fund_id,
      quantity,
      option_value,
      paid_price,
      final_price,
      refund_amount,
      status,
      tracking_number,
      created_at,
      funds (
        end_at,
        status,
        final_price,
        products (
          name,
          images
        )
      )
    `
    )
    .eq('user_id', user.id)
    .order('created_at', { ascending: false });

  if (statusFilter) {
    query = query.eq('status', statusFilter);
  }

  const { data, error } = await query;

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const orders: OrderSummary[] = (data ?? []).map((row) => {
    // Supabase returns joined tables as nested objects
    const fund = Array.isArray(row.funds) ? row.funds[0] : row.funds;
    const product = fund
      ? Array.isArray(fund.products)
        ? fund.products[0]
        : fund.products
      : null;

    return {
      id: row.id,
      fundId: row.fund_id,
      productName: product?.name ?? '',
      productImage: product?.images?.[0] ?? '',
      quantity: row.quantity,
      optionValue: row.option_value,
      paidPrice: row.paid_price,
      finalPrice: row.final_price,
      refundAmount: row.refund_amount,
      status: row.status,
      trackingNumber: row.tracking_number,
      createdAt: row.created_at,
      fundEndAt: fund?.end_at ?? '',
      fundStatus: fund?.status ?? '',
      currentPrice: fund?.final_price ?? row.paid_price,
    };
  });

  return NextResponse.json({ data: orders, error: null });
}
