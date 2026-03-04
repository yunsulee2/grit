import { NextResponse } from 'next/server';
import { createAdminClient } from '@/lib/supabase/admin';
import type { OrderRow } from '@/types/database';
import { createHmac, timingSafeEqual } from 'crypto';

// ---------------------------------------------------------------------------
// POST /api/payments/webhook
// Receives TossPayments webhook notifications.
// TossPayments sends POST with JSON body containing payment status changes.
// Must return 200 OK quickly — otherwise Toss retries.
// ---------------------------------------------------------------------------

// Verify TossPayments webhook signature (HMAC-SHA256)
// Returns true if signature is valid or if TOSS_WEBHOOK_SECRET is not set (test/mock mode).
// Returns false if secret is set but signature is missing or invalid.
async function verifyWebhookSignature(rawBody: string, signatureHeader: string | null): Promise<boolean> {
  const secret = process.env.TOSS_WEBHOOK_SECRET;
  if (!secret) {
    console.warn('TOSS_WEBHOOK_SECRET is not set — skipping signature verification (test/mock mode)');
    return true;
  }
  if (!signatureHeader) {
    console.error('Webhook: missing TossPayments-Signature header');
    return false;
  }
  const expected = createHmac('sha256', secret).update(rawBody, 'utf8').digest('hex');
  const expectedBuf = Buffer.from(expected, 'hex');
  let receivedBuf: Buffer;
  try {
    receivedBuf = Buffer.from(signatureHeader, 'hex');
  } catch {
    return false;
  }
  if (expectedBuf.length !== receivedBuf.length) {
    return false;
  }
  return timingSafeEqual(expectedBuf, receivedBuf);
}

// TossPayments webhook event shape (subset of fields we use)
interface TossWebhookEvent {
  eventType: string; // e.g. 'PAYMENT_STATUS_CHANGED'
  data: {
    paymentKey: string;
    orderId: string;
    status: string; // 'DONE' | 'CANCELED' | 'PARTIAL_CANCELED' | 'EXPIRED' etc.
    totalAmount?: number;
    cancels?: Array<{
      cancelAmount: number;
      cancelReason: string;
      canceledAt: string;
    }>;
  };
}

// Map Toss status to our OrderStatus
function mapTossStatusToOrderStatus(
  tossStatus: string,
  currentOrderStatus: string,
): string | null {
  switch (tossStatus) {
    case 'DONE':
      // Only upgrade to PAID if still PENDING
      return currentOrderStatus === 'PENDING' ? 'PAID' : null;
    case 'CANCELED':
      return 'CANCELLED';
    case 'PARTIAL_CANCELED':
      return 'REFUNDED_PARTIAL';
    case 'EXPIRED':
    case 'ABORTED':
      return currentOrderStatus === 'PENDING' ? 'CANCELLED' : null;
    default:
      return null;
  }
}

export async function POST(request: Request) {
  try {
    // Read raw body for signature verification before parsing JSON
    const rawBody = await request.text();
    const signatureHeader = request.headers.get('TossPayments-Signature');

    const signatureValid = await verifyWebhookSignature(rawBody, signatureHeader);
    if (!signatureValid) {
      console.error('Webhook: invalid signature — rejecting request');
      return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
    }

    const body = JSON.parse(rawBody) as TossWebhookEvent;
    const { eventType, data } = body;

    if (!eventType || !data?.paymentKey) {
      // Return 200 to avoid retries on malformed payloads
      return NextResponse.json({ received: true });
    }

    const admin = createAdminClient();

    // --- Find the order by paymentKey or orderId ---
    let order: OrderRow | null = null;

    // Try by payment_key first (most reliable for post-payment events)
    if (data.paymentKey) {
      const { data: found } = await admin
        .from('orders')
        .select('*')
        .eq('payment_key', data.paymentKey)
        .single<OrderRow>();
      order = found;
    }

    // Fall back to orderId (useful for PENDING orders that don't have payment_key yet)
    if (!order && data.orderId) {
      const { data: found } = await admin
        .from('orders')
        .select('*')
        .eq('id', data.orderId)
        .single<OrderRow>();
      order = found;
    }

    if (!order) {
      // Order not found — still return 200 to prevent retries
      console.warn(`Webhook: order not found for paymentKey=${data.paymentKey}`);
      return NextResponse.json({ received: true, matched: false });
    }

    // --- Determine new status ---
    const newStatus = mapTossStatusToOrderStatus(data.status, order.status);

    if (!newStatus) {
      // No status change needed
      return NextResponse.json({ received: true, updated: false });
    }

    // --- Update order ---
    const updatePayload: Record<string, unknown> = {
      status: newStatus,
    };

    // Attach paymentKey if not yet set (e.g. DONE webhook for PENDING order)
    if (!order.payment_key && data.paymentKey) {
      updatePayload.payment_key = data.paymentKey;
    }

    const { error: updateError } = await admin
      .from('orders')
      .update(updatePayload)
      .eq('id', order.id);

    if (updateError) {
      console.error('Webhook: order update failed:', updateError);
      // Still return 200 — we log the error; manual reconciliation needed
    }

    return NextResponse.json({ received: true, updated: !updateError, newStatus });
  } catch (err) {
    console.error('POST /api/payments/webhook error:', err);
    // Return 200 even on error to prevent infinite retries from Toss
    return NextResponse.json({ received: true, error: true });
  }
}
