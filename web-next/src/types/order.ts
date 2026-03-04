import type { OrderStatus } from './database';

export interface OrderSummary {
  id: string;
  fundId: string;
  productName: string;
  productImage: string;
  quantity: number;
  optionValue: string | null;
  paidPrice: number;
  finalPrice: number | null;
  refundAmount: number | null;
  status: OrderStatus;
  trackingNumber: string | null;
  createdAt: string;
  fundEndAt: string;
  fundStatus: string;
  currentPrice: number;
}

export interface CreateOrderRequest {
  fundId: string;
  quantity: number;
  optionValue?: string;
  address: string;
  addressDetail?: string;
  zipcode: string;
  phone: string;
}

export interface CreateOrderResponse {
  orderId: string;
  orderName: string;
  amount: number;
  customerKey: string;
}

export interface ConfirmPaymentRequest {
  orderId: string;
  paymentKey: string;
  amount: number;
}
