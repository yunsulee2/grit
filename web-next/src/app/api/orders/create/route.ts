import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { createAdminClient } from '@/lib/supabase/admin';
import type { CreateOrderRequest, CreateOrderResponse } from '@/types/order';
import type { FundRow, PriceTierRow } from '@/types/database';
import { MAX_QUANTITY } from '@/lib/constants';

// ---------------------------------------------------------------------------
// POST /api/orders/create
// Creates a PENDING order and returns data needed for TossPayments client SDK.
// ---------------------------------------------------------------------------

export async function POST(request: Request) {
  try {
    // --- Auth ---
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // --- Parse & validate body ---
    const body = (await request.json()) as CreateOrderRequest;
    const { fundId, quantity, optionValue, address, addressDetail, zipcode, phone } = body;

    if (!fundId || !quantity || quantity < 1) {
      return NextResponse.json(
        { error: 'fundId and quantity (>= 1) are required' },
        { status: 400 },
      );
    }
    if (!address || !zipcode || !phone) {
      return NextResponse.json(
        { error: 'address, zipcode, and phone are required' },
        { status: 400 },
      );
    }

    // --- Format & validate individual fields ---
    const phoneNormalized = phone.replace(/[\s-]/g, '');
    if (!/^01[016789]\d{7,8}$/.test(phoneNormalized)) {
      return NextResponse.json(
        { error: 'phone must be a valid Korean mobile number (e.g. 010-1234-5678)' },
        { status: 400 },
      );
    }
    if (!/^\d{5}$/.test(zipcode)) {
      return NextResponse.json({ error: 'zipcode must be 5 digits' }, { status: 400 });
    }
    if (address.length > 200) {
      return NextResponse.json({ error: 'address must be 200 characters or fewer' }, { status: 400 });
    }
    if (addressDetail !== undefined && addressDetail !== null && addressDetail.length > 200) {
      return NextResponse.json(
        { error: 'addressDetail must be 200 characters or fewer' },
        { status: 400 },
      );
    }
    if (quantity > MAX_QUANTITY) {
      return NextResponse.json(
        { error: `quantity cannot exceed ${MAX_QUANTITY}` },
        { status: 400 },
      );
    }
    if (optionValue !== undefined && optionValue !== null && optionValue.length > 100) {
      return NextResponse.json(
        { error: 'optionValue must be 100 characters or fewer' },
        { status: 400 },
      );
    }

    // --- Use admin client for trusted server-side queries ---
    const admin = createAdminClient();

    // --- Fetch fund ---
    const { data: fund, error: fundError } = await admin
      .from('funds')
      .select('*')
      .eq('id', fundId)
      .single<FundRow>();

    if (fundError || !fund) {
      return NextResponse.json({ error: 'Fund not found' }, { status: 404 });
    }

    // --- Validate fund state ---
    if (fund.status !== 'OPEN') {
      return NextResponse.json({ error: 'Fund is not open for participation' }, { status: 409 });
    }

    if (new Date(fund.end_at) <= new Date()) {
      return NextResponse.json({ error: 'Fund has ended' }, { status: 409 });
    }

    if (
      fund.max_participants !== null &&
      fund.current_participants + quantity > fund.max_participants
    ) {
      return NextResponse.json({ error: 'Fund has reached maximum participants' }, { status: 409 });
    }

    // --- Fetch price tiers ---
    const { data: tiers, error: tiersError } = await admin
      .from('price_tiers')
      .select('*')
      .eq('fund_id', fundId)
      .order('min_quantity', { ascending: false }) as { data: PriceTierRow[] | null; error: unknown };

    if (tiersError || !tiers || tiers.length === 0) {
      return NextResponse.json({ error: 'No price tiers configured for this fund' }, { status: 500 });
    }

    // --- Calculate current price ---
    const currentParticipants = fund.current_participants;
    const matchedTier = tiers.find((t) => t.min_quantity <= currentParticipants);
    const unitPrice = matchedTier?.price ?? tiers[tiers.length - 1].price;
    const totalAmount = unitPrice * quantity;

    // --- Fetch product name for orderName ---
    const { data: product } = await admin
      .from('products')
      .select('name')
      .eq('id', fund.product_id)
      .single<{ name: string }>();

    const orderName = product?.name
      ? `${product.name}${quantity > 1 ? ` x${quantity}` : ''}`
      : `공동구매 주문`;

    // --- Create order record (PENDING) ---
    const { data: order, error: orderError } = await admin
      .from('orders')
      .insert({
        fund_id: fundId,
        user_id: user.id,
        quantity,
        option_value: optionValue ?? null,
        paid_price: unitPrice,
        final_price: null,
        refund_amount: null,
        status: 'PENDING',
        payment_key: null,
        address,
        address_detail: addressDetail ?? null,
        zipcode,
        phone,
        tracking_number: null,
      })
      .select('id')
      .single<{ id: string }>();

    if (orderError || !order) {
      console.error('Order creation failed:', orderError);
      return NextResponse.json({ error: 'Failed to create order' }, { status: 500 });
    }

    // --- Return data for TossPayments client SDK ---
    const response: CreateOrderResponse = {
      orderId: order.id,
      orderName,
      amount: totalAmount,
      customerKey: user.id,
    };

    return NextResponse.json(response, { status: 201 });
  } catch (err) {
    console.error('POST /api/orders/create error:', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
