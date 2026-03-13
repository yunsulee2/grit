// TossPayments API Client
// Docs: https://docs.tosspayments.com/reference

const TOSS_BASE_URL = 'https://api.tosspayments.com';
const TOSS_SECRET_KEY = process.env.TOSS_SECRET_KEY ?? '';
const IS_PLACEHOLDER = TOSS_SECRET_KEY === 'sk_test_placeholder' || TOSS_SECRET_KEY === '';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface TossPayment {
  paymentKey: string;
  orderId: string;
  orderName: string;
  status: string;
  totalAmount: number;
  method: string | null;
  requestedAt: string;
  approvedAt: string | null;
  cancels: TossCancel[] | null;
}

export interface TossCancel {
  cancelAmount: number;
  cancelReason: string;
  canceledAt: string;
  transactionKey: string;
}

export interface TossError {
  code: string;
  message: string;
}

export class TossPaymentError extends Error {
  public readonly code: string;
  public readonly statusCode: number;

  constructor(code: string, message: string, statusCode: number) {
    super(message);
    this.name = 'TossPaymentError';
    this.code = code;
    this.statusCode = statusCode;
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

function authHeader(): string {
  const encoded = Buffer.from(TOSS_SECRET_KEY + ':').toString('base64');
  return `Basic ${encoded}`;
}

async function tossRequest<T>(
  method: 'GET' | 'POST',
  path: string,
  body?: Record<string, unknown>,
): Promise<T> {
  const res = await fetch(`${TOSS_BASE_URL}${path}`, {
    method,
    headers: {
      Authorization: authHeader(),
      'Content-Type': 'application/json',
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });

  const data = await res.json();

  if (!res.ok) {
    const err = data as TossError;
    throw new TossPaymentError(
      err.code ?? 'UNKNOWN',
      err.message ?? 'Unknown TossPayments error',
      res.status,
    );
  }

  return data as T;
}

// ---------------------------------------------------------------------------
// Mock responses (for development without real keys)
// ---------------------------------------------------------------------------

function mockPayment(orderId: string, amount: number, paymentKey: string): TossPayment {
  const now = new Date().toISOString();
  return {
    paymentKey,
    orderId,
    orderName: 'Mock Order',
    status: 'DONE',
    totalAmount: amount,
    method: '카드',
    requestedAt: now,
    approvedAt: now,
    cancels: null,
  };
}

function mockCancelPayment(paymentKey: string, cancelAmount: number): TossPayment {
  const now = new Date().toISOString();
  return {
    paymentKey,
    orderId: 'mock-order',
    orderName: 'Mock Order',
    status: cancelAmount > 0 ? 'PARTIAL_CANCELED' : 'CANCELED',
    totalAmount: 0,
    method: '카드',
    requestedAt: now,
    approvedAt: now,
    cancels: [
      {
        cancelAmount,
        cancelReason: 'Mock cancel',
        canceledAt: now,
        transactionKey: `mock-tx-${Date.now()}`,
      },
    ],
  };
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Confirm (approve) a payment after the client-side payment flow.
 * POST /v1/payments/confirm
 */
export async function confirmPayment(
  paymentKey: string,
  orderId: string,
  amount: number,
): Promise<TossPayment> {
  if (IS_PLACEHOLDER) {
    return mockPayment(orderId, amount, paymentKey);
  }

  return tossRequest<TossPayment>('POST', '/v1/payments/confirm', {
    paymentKey,
    orderId,
    amount,
  });
}

/**
 * Cancel a payment (full or partial).
 * POST /v1/payments/{paymentKey}/cancel
 */
export async function cancelPayment(
  paymentKey: string,
  cancelReason: string,
  cancelAmount?: number,
): Promise<TossPayment> {
  if (IS_PLACEHOLDER) {
    return mockCancelPayment(paymentKey, cancelAmount ?? 0);
  }

  const body: Record<string, unknown> = { cancelReason };
  if (cancelAmount !== undefined) {
    body.cancelAmount = cancelAmount;
  }

  return tossRequest<TossPayment>('POST', `/v1/payments/${paymentKey}/cancel`, body);
}

/**
 * Retrieve payment details.
 * GET /v1/payments/{paymentKey}
 */
export async function getPayment(paymentKey: string): Promise<TossPayment> {
  if (IS_PLACEHOLDER) {
    return mockPayment('unknown', 0, paymentKey);
  }

  return tossRequest<TossPayment>('GET', `/v1/payments/${paymentKey}`);
}
