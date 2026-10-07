import { beforeEach, describe, expect, it } from "vitest";
import { createCheckoutSession, receiveSepayWebhook } from "../services/checkoutService.js";
import { fileDatabase } from "../services/fileDatabase.js";

const now = new Date().toISOString();

beforeEach(async () => {
  await fileDatabase.write({
    users: [
      {
        id: "user-1",
        email: "buyer@example.com",
        displayName: "Buyer",
        passwordHash: "demo",
        status: "active",
        createdAt: now,
        updatedAt: now
      }
    ],
    sessions: [],
    skills: [
      {
        id: "skill-1",
        slug: "agent-commerce-kit",
        title: "Agent Commerce Kit",
        category: "Payments",
        summary: "Checkout and payment skill.",
        description: "Demo skill.",
        status: "active"
      }
    ],
    skillPlans: [
      {
        id: "plan-1",
        skillId: "skill-1",
        name: "Premium",
        priceVnd: 899000,
        status: "active"
      }
    ],
    orders: [],
    paymentInstructions: [],
    paymentTransactions: [],
    entitlements: []
  });
});

describe("checkoutService", () => {
  it("creates checkout session with payment instruction", async () => {
    const result = await createCheckoutSession({ skillId: "skill-1", planId: "plan-1", buyerEmail: "buyer@example.com" });

    expect(result.order.status).toBe("pending_payment");
    expect(result.order.amountVnd).toBe(899000);
    expect(result.paymentInstruction?.transferContent).toBe(result.order.orderCode);
  });

  it("marks order paid and grants entitlement on matching webhook", async () => {
    const checkout = await createCheckoutSession({ skillId: "skill-1", planId: "plan-1", buyerEmail: "buyer@example.com" });

    const result = await receiveSepayWebhook({
      transactionId: "tx-1",
      amountVnd: checkout.order.amountVnd,
      transferContent: checkout.order.orderCode
    });

    expect("order" in result && result.order.status).toBe("paid");
    expect("entitlement" in result && result.entitlement?.status).toBe("active");
  });

  it("marks order needs_review when amount does not match", async () => {
    const checkout = await createCheckoutSession({ skillId: "skill-1", planId: "plan-1", buyerEmail: "buyer@example.com" });

    const result = await receiveSepayWebhook({
      transactionId: "tx-wrong-amount",
      amountVnd: 1000,
      transferContent: checkout.order.orderCode
    });

    expect("order" in result && result.order.status).toBe("needs_review");
    expect("entitlement" in result && result.entitlement).toBeUndefined();
  });
});
