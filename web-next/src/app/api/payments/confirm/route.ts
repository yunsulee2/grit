import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { createAdminClient } from '@/lib/supabase/admin';
import { confirmPayment } from '@/lib/payments/toss';
import type { ConfirmPaymentRequest } from '@/types/order';
import type { OrderRow, FundRow } from '@/types/database';

// ---------------------------------------------------------------------------
// Shared confirmation logic used by both GET and POST handlers.
// ---------------------------------------------------------------------------

async function handleConfirm({
  orderId,
  paymentKey,
  amount,
  fundId,
  userId,
}: {
  orderId: string;
  paymentKey: string;
  amount: number;
  fundId: string | null;
  userId: string;
}): Promise<
  | { success: true; order: OrderRow; fund: FundRow | null; warning?: string }
  | { success: false; error: string; status: number }
> {
  const admin = createAdminClient();

  // --- Fetch order ---
  const { data: order, error: orderError } = await admin
    .from('orders')
    .select('*')
    .eq('id', orderId)
    .single<OrderRow>();

  if (orderError || !order) {
    return { success: false, error: 'Order not found', status: 404 };
  }

  // --- Ownership check ---
  if (order.user_id !== userId) {
    return { success: false, error: 'Forbidden', status: 403 };
  }

  // --- Idempotency: if already PAID with same paymentKey, return success ---
  if (order.status === 'PAID' && order.payment_key === paymentKey) {
    const { data: fund } = await admin
      .from('funds')
      .select('*')
      .eq('id', order.fund_id)
      .single<FundRow>();

    return { success: true, order, fund: fund ?? null };
  }

  // --- Reject if order is not PENDING ---
  if (order.status !== 'PENDING') {
    return {
      success: false,
      error: `Order status is ${order.status}, expected PENDING`,
      status: 409,
    };
  }

  // --- Verify amount matches ---
  const expectedAmount = order.paid_price * order.quantity;
  if (amount !== expectedAmount) {
    return {
      success: false,
      error: `Amount mismatch: expected ${expectedAmount}, got ${amount}`,
      status: 400,
    };
  }

  // --- Confirm payment with TossPayments ---
  try {
    await confirmPayment(paymentKey, orderId, amount);
  } catch (tossErr) {
    console.error('TossPayments confirm failed:', tossErr);
    return {
      success: false,
      error: 'Payment confirmation failed with payment provider',
      status: 502,
    };
  }

  // --- Update order to PAID ---
  const { data: updatedOrder, error: updateError } = await admin
    .from('orders')
    .update({
      status: 'PAID',
      payment_key: paymentKey,
    })
    .eq('id', orderId)
    .eq('status', 'PENDING') // optimistic lock: only update if still PENDING
    .select('*')
    .single<OrderRow>();

  if (updateError || !updatedOrder) {
    // Another request may have already confirmed this order
    console.error('Order update failed (possible race):', updateError);
    return {
      success: false,
      error: 'Failed to update order — possible duplicate confirmation',
      status: 409,
    };
  }

  // --- Atomically increment fund.current_participants ---
  // Uses Supabase RPC if available, otherwise manual update with optimistic lock.
  const { data: fund, error: fundFetchError } = await admin
    .from('funds')
    .select('*')
    .eq('id', order.fund_id)
    .single<FundRow>();

  if (fundFetchError || !fund) {
    console.error('Fund fetch failed after payment:', fundFetchError);
    return {
      success: true,
      order: updatedOrder,
      fund: null,
      warning: 'Payment confirmed but participant count update needs manual review',
    };
  }

  // Try RPC first (atomic increment), fall back to manual update
  const { error: rpcError } = await admin.rpc('increment_participants', {
    fund_id: order.fund_id,
    increment_by: order.quantity,
  });

  let updatedFund: FundRow | null = null;

  if (rpcError) {
    // RPC not available — fall back to manual increment
    console.warn('increment_participants RPC not found, using manual update:', rpcError.message);
    const newCount = fund.current_participants + order.quantity;
    const { data: manualFund, error: manualError } = await admin
      .from('funds')
      .update({ current_participants: newCount })
      .eq('id', order.fund_id)
      .eq('current_participants', fund.current_participants) // optimistic lock
      .select('*')
      .single<FundRow>();

    if (manualError || !manualFund) {
      console.error('Manual participant increment failed (race condition):', manualError);
      return {
        success: true,
        order: updatedOrder,
        fund,
        warning: 'Participant count may need reconciliation',
      };
    }
    updatedFund = manualFund;
  } else {
    // Re-fetch fund to get updated count
    const { data: refreshedFund } = await admin
      .from('funds')
      .select('*')
      .eq('id', order.fund_id)
      .single<FundRow>();
    updatedFund = refreshedFund;
  }

  return { success: true, order: updatedOrder, fund: updatedFund };
}

// ---------------------------------------------------------------------------
// GET /api/payments/confirm
// TossPayments redirects here after successful payment with query params:
// paymentKey, orderId, amount (and our custom fundId).
// ---------------------------------------------------------------------------

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const paymentKey = searchParams.get('paymentKey') ?? '';
  const orderId = searchParams.get('orderId') ?? '';
  const amountStr = searchParams.get('amount') ?? '';
  const fundId = searchParams.get('fundId') ?? '';

  if (!paymentKey || !orderId || !amountStr) {
    const redirectFundId = fundId || 'unknown';
    return NextResponse.redirect(
      new URL(
        `/fund/${redirectFundId}?payment=failed&error=${encodeURIComponent('필수 파라미터가 누락되었습니다')}`,
        request.nextUrl.origin,
      ),
    );
  }

  const amount = parseInt(amountStr, 10);

  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.redirect(
        new URL(
          `/fund/${fundId}?payment=failed&error=${encodeURIComponent('로그인이 필요합니다')}`,
          request.nextUrl.origin,
        ),
      );
    }

    const result = await handleConfirm({ orderId, paymentKey, amount, fundId, userId: user.id });

    if (!result.success) {
      return NextResponse.redirect(
        new URL(
          `/fund/${fundId}?payment=failed&error=${encodeURIComponent(result.error)}`,
          request.nextUrl.origin,
        ),
      );
    }

    return NextResponse.redirect(
      new URL(`/fund/${fundId}/complete?orderId=${orderId}`, request.nextUrl.origin),
    );
  } catch (err) {
    console.error('GET /api/payments/confirm error:', err);
    return NextResponse.redirect(
      new URL(
        `/fund/${fundId}?payment=failed&error=${encodeURIComponent('결제 확인 중 오류가 발생했습니다')}`,
        request.nextUrl.origin,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// POST /api/payments/confirm
// Called after TossPayments client-side success callback.
// Confirms payment with Toss, updates order to PAID, increments participants.
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

    // --- Parse body ---
    const body = (await request.json()) as ConfirmPaymentRequest & { fundId?: string };
    const { orderId, paymentKey, amount, fundId } = body;

    if (!orderId || !paymentKey || !amount) {
      return NextResponse.json(
        { error: 'orderId, paymentKey, and amount are required' },
        { status: 400 },
      );
    }

    const result = await handleConfirm({
      orderId,
      paymentKey,
      amount,
      fundId: fundId ?? null,
      userId: user.id,
    });

    if (!result.success) {
      return NextResponse.json({ error: result.error }, { status: result.status });
    }

    return NextResponse.json({
      order: result.order,
      fund: result.fund,
      ...(result.warning ? { warning: result.warning } : {}),
    });
  } catch (err) {
    console.error('POST /api/payments/confirm error:', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
