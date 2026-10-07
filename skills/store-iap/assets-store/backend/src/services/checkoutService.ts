import { randomUUID } from "node:crypto";
import { z } from "zod";
import { AppError, assertFound } from "../utils/errors.js";
import type { User } from "../types/domain.js";
import { fileDatabase } from "./fileDatabase.js";

const checkoutSchema = z.object({
  skillId: z.string().min(1),
  planId: z.string().min(1),
  buyerEmail: z.string().email().optional()
});

const webhookSchema = z.object({
  transactionId: z.string().min(1),
  amountVnd: z.number().int().positive(),
  transferContent: z.string().min(1)
});

export async function createCheckoutSession(input: unknown, user?: User) {
  const payload = checkoutSchema.parse(input);
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 30 * 60 * 1000).toISOString();
  const orderCode = createOrderCode();
  let orderId = "";

  const db = await fileDatabase.update((draft) => {
    const skill = assertFound(draft.skills.find((item) => item.id === payload.skillId && item.status === "active"), "skill_not_found", "Skill not found");
    const plan = assertFound(draft.skillPlans.find((item) => item.id === payload.planId && item.skillId === skill.id && item.status === "active"), "plan_not_found", "Plan not found");
    const buyerEmail = user?.email ?? payload.buyerEmail;
    if (!buyerEmail) throw new AppError(400, "buyer_email_required", "Buyer email is required for guest checkout");

    orderId = randomUUID();
    draft.orders.push({
      id: orderId,
      orderCode,
      userId: user?.id,
      buyerEmail: buyerEmail.toLowerCase(),
      skillId: skill.id,
      planId: plan.id,
      amountVnd: plan.priceVnd,
      status: "pending_payment",
      paymentProvider: "sepay",
      expiresAt,
      createdAt: now.toISOString(),
      updatedAt: now.toISOString()
    });
    draft.paymentInstructions.push({
      id: randomUUID(),
      orderId,
      provider: "sepay",
      bankName: "Demo Bank",
      bankAccountNo: "0123456789",
      bankAccountName: "SKILL STORE DEMO",
      amountVnd: plan.priceVnd,
      transferContent: orderCode,
      qrImageUrl: `https://img.vietqr.io/image/970436-0123456789-compact2.png?amount=${plan.priceVnd}&addInfo=${orderCode}&accountName=SKILL%20STORE%20DEMO`,
      createdAt: now.toISOString()
    });
  });

  return buildOrderResponse(db, orderId);
}

export async function getOrder(orderCode: string, user?: User) {
  const db = await fileDatabase.read();
  const order = assertFound(db.orders.find((item) => item.orderCode === orderCode), "order_not_found", "Order not found");
  if (order.userId && user?.id !== order.userId) throw new AppError(403, "order_forbidden", "Order is not available for this user");
  return buildOrderResponse(db, order.id);
}

export async function receiveSepayWebhook(input: unknown) {
  const payload = webhookSchema.parse(input);
  const now = new Date().toISOString();
  const orderCode = extractOrderCode(payload.transferContent);
  let orderId: string | undefined;

  const db = await fileDatabase.update((draft) => {
    const duplicate = draft.paymentTransactions.find((item) => item.providerTransactionId === payload.transactionId);
    if (duplicate) return;

    const order = orderCode ? draft.orders.find((item) => item.orderCode === orderCode) : undefined;
    orderId = order?.id;

    if (!order) {
      draft.paymentTransactions.push({
        id: randomUUID(),
        provider: "sepay",
        providerTransactionId: payload.transactionId,
        matchedOrderCode: orderCode,
        amountVnd: payload.amountVnd,
        transferContent: payload.transferContent,
        matchStatus: "order_not_found",
        createdAt: now
      });
      return;
    }

    if (order.status === "paid") {
      draft.paymentTransactions.push({
        id: randomUUID(),
        provider: "sepay",
        providerTransactionId: payload.transactionId,
        orderId: order.id,
        matchedOrderCode: order.orderCode,
        amountVnd: payload.amountVnd,
        transferContent: payload.transferContent,
        matchStatus: "duplicate",
        createdAt: now
      });
      return;
    }

    if (order.amountVnd !== payload.amountVnd) {
      order.status = "needs_review";
      order.updatedAt = now;
      draft.paymentTransactions.push({
        id: randomUUID(),
        provider: "sepay",
        providerTransactionId: payload.transactionId,
        orderId: order.id,
        matchedOrderCode: order.orderCode,
        amountVnd: payload.amountVnd,
        transferContent: payload.transferContent,
        matchStatus: "amount_mismatch",
        createdAt: now
      });
      return;
    }

    order.status = "paid";
    order.paidAt = now;
    order.updatedAt = now;
    draft.paymentTransactions.push({
      id: randomUUID(),
      provider: "sepay",
      providerTransactionId: payload.transactionId,
      orderId: order.id,
      matchedOrderCode: order.orderCode,
      amountVnd: payload.amountVnd,
      transferContent: payload.transferContent,
      matchStatus: "matched",
      createdAt: now
    });

    const user = order.userId ? draft.users.find((item) => item.id === order.userId) : draft.users.find((item) => item.email === order.buyerEmail);
    if (user && !draft.entitlements.some((item) => item.orderId === order.id)) {
      draft.entitlements.push({
        id: randomUUID(),
        userId: user.id,
        skillId: order.skillId,
        planId: order.planId,
        orderId: order.id,
        status: "active",
        grantedAt: now,
        createdAt: now
      });
    }
  });

  return orderId ? buildOrderResponse(db, orderId) : { received: true, matchStatus: "order_not_found" };
}

function buildOrderResponse(db: Awaited<ReturnType<typeof fileDatabase.read>>, orderId: string) {
  const order = assertFound(db.orders.find((item) => item.id === orderId), "order_not_found", "Order not found");
  const skill = assertFound(db.skills.find((item) => item.id === order.skillId), "skill_not_found", "Skill not found");
  const plan = assertFound(db.skillPlans.find((item) => item.id === order.planId), "plan_not_found", "Plan not found");
  const paymentInstruction = db.paymentInstructions.find((item) => item.orderId === order.id);
  const entitlement = db.entitlements.find((item) => item.orderId === order.id);
  return { order, skill, plan, paymentInstruction, entitlement };
}

function createOrderCode() {
  const date = new Date().toISOString().slice(0, 10).replaceAll("-", "");
  return `SKILL-${date}-${randomUUID().slice(0, 6).toUpperCase()}`;
}

function extractOrderCode(content: string) {
  return content.match(/SKILL-\d{8}-[A-Z0-9]{6}/)?.[0];
}
