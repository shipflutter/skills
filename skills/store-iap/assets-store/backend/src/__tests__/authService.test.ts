import { beforeEach, describe, expect, it } from "vitest";
import { signIn, signUp } from "../services/authService.js";
import { fileDatabase } from "../services/fileDatabase.js";

beforeEach(async () => {
  await fileDatabase.write({
    users: [],
    sessions: [],
    skills: [],
    skillPlans: [],
    orders: [],
    paymentInstructions: [],
    paymentTransactions: [],
    entitlements: []
  });
});

describe("authService", () => {
  it("creates a user and session on sign up", async () => {
    const result = await signUp({ email: "new@example.com", password: "password123", displayName: "New Buyer" });

    expect(result.token).toHaveLength(36);
    expect(result.user?.email).toBe("new@example.com");

    const db = await fileDatabase.read();
    expect(db.users).toHaveLength(1);
    expect(db.sessions).toHaveLength(1);
  });

  it("signs in with valid credentials", async () => {
    await signUp({ email: "buyer@example.com", password: "password123", displayName: "Buyer" });

    const result = await signIn({ email: "buyer@example.com", password: "password123" });

    expect(result.user?.email).toBe("buyer@example.com");
    expect(result.token).toHaveLength(36);
  });

  it("rejects invalid credentials", async () => {
    await signUp({ email: "buyer@example.com", password: "password123", displayName: "Buyer" });

    await expect(signIn({ email: "buyer@example.com", password: "bad-password" })).rejects.toMatchObject({
      status: 401,
      code: "invalid_credentials"
    });
  });
});
