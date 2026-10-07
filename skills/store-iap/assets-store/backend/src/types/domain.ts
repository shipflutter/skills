export type UserStatus = "active" | "pending_verification" | "locked" | "deleted";
export type OrderStatus = "pending_payment" | "paid" | "expired" | "needs_review" | "cancelled" | "failed" | "refunded";
export type EntitlementStatus = "active" | "revoked" | "refunded";

export interface User {
  id: string;
  email: string;
  displayName: string;
  passwordHash: string;
  status: UserStatus;
  createdAt: string;
  updatedAt: string;
}

export interface Session {
  token: string;
  userId: string;
  expiresAt: string;
  createdAt: string;
}

export interface Skill {
  id: string;
  slug: string;
  title: string;
  category: string;
  summary: string;
  description: string;
  status: "active" | "draft" | "archived";
}

export interface SkillPlan {
  id: string;
  skillId: string;
  name: string;
  priceVnd: number;
  compareAtPriceVnd?: number;
  status: "active" | "archived";
}

export interface Order {
  id: string;
  orderCode: string;
  userId?: string;
  buyerEmail: string;
  skillId: string;
  planId: string;
  amountVnd: number;
  status: OrderStatus;
  paymentProvider: "sepay";
  expiresAt: string;
  paidAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface PaymentInstruction {
  id: string;
  orderId: string;
  provider: "sepay";
  bankName: string;
  bankAccountNo: string;
  bankAccountName: string;
  amountVnd: number;
  transferContent: string;
  qrImageUrl?: string;
  createdAt: string;
}

export interface PaymentTransaction {
  id: string;
  provider: "sepay";
  providerTransactionId: string;
  orderId?: string;
  matchedOrderCode?: string;
  amountVnd: number;
  transferContent: string;
  matchStatus: "matched" | "duplicate" | "amount_mismatch" | "order_not_found";
  createdAt: string;
}

export interface Entitlement {
  id: string;
  userId: string;
  skillId: string;
  planId: string;
  orderId: string;
  status: EntitlementStatus;
  grantedAt: string;
  createdAt: string;
}

export interface DatabaseShape {
  users: User[];
  sessions: Session[];
  skills: Skill[];
  skillPlans: SkillPlan[];
  orders: Order[];
  paymentInstructions: PaymentInstruction[];
  paymentTransactions: PaymentTransaction[];
  entitlements: Entitlement[];
}
