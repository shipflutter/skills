import { hashPassword } from "./utils/password.js";
import { fileDatabase } from "./services/fileDatabase.js";

const now = new Date().toISOString();

await fileDatabase.write({
  users: [
    {
      id: "user-demo-1",
      email: "buyer@example.com",
      displayName: "Demo Buyer",
      passwordHash: hashPassword("password123"),
      status: "active",
      createdAt: now,
      updatedAt: now
    }
  ],
  sessions: [],
  skills: [
    {
      id: "skill-agent-commerce-kit",
      slug: "agent-commerce-kit",
      title: "Agent Commerce Kit",
      category: "Payments",
      summary: "Checkout UX, entitlement rules, webhook reconciliation, and launch copy for premium skill businesses.",
      description: "A production-minded package for selling premium AI skills with SePay-ready payment flows.",
      status: "active"
    },
    {
      id: "skill-taste-ui-pack",
      slug: "taste-ui-pack",
      title: "Taste UI Pack",
      category: "Design",
      summary: "Editorial storefront sections, dense bento grids, and confident premium CTAs.",
      description: "A polished UI kit for reviewing and launching a premium skill storefront.",
      status: "active"
    },
    {
      id: "skill-review-agent-suite",
      slug: "review-agent-suite",
      title: "Review Agent Suite",
      category: "Agent Ops",
      summary: "Review workflows for code, architecture, security, reliability, and release readiness.",
      description: "A structured suite for teams that want repeatable second-opinion review rituals.",
      status: "active"
    }
  ],
  skillPlans: [
    { id: "plan-agent-commerce-premium", skillId: "skill-agent-commerce-kit", name: "Premium", priceVnd: 899000, compareAtPriceVnd: 1299000, status: "active" },
    { id: "plan-taste-ui-premium", skillId: "skill-taste-ui-pack", name: "Premium", priceVnd: 549000, compareAtPriceVnd: 799000, status: "active" },
    { id: "plan-review-agent-premium", skillId: "skill-review-agent-suite", name: "Premium", priceVnd: 699000, compareAtPriceVnd: 999000, status: "active" }
  ],
  orders: [],
  paymentInstructions: [],
  paymentTransactions: [],
  entitlements: []
});

console.log("Seeded skill-store/backend/data/db.json");
