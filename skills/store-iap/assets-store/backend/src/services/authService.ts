import { randomUUID } from "node:crypto";
import { z } from "zod";
import { AppError } from "../utils/errors.js";
import { hashPassword, verifyPassword } from "../utils/password.js";
import { fileDatabase } from "./fileDatabase.js";

const signUpSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  displayName: z.string().min(1).max(80)
});

const signInSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1)
});

export async function signUp(input: unknown) {
  const payload = signUpSchema.parse(input);
  const now = new Date().toISOString();
  const email = payload.email.toLowerCase();
  let createdUserId = "";

  await fileDatabase.update((db) => {
    if (db.users.some((user) => user.email === email)) {
      throw new AppError(409, "account_exists", "Account already exists");
    }

    createdUserId = randomUUID();
    db.users.push({
      id: createdUserId,
      email,
      displayName: payload.displayName,
      passwordHash: hashPassword(payload.password),
      status: "active",
      createdAt: now,
      updatedAt: now
    });
  });

  return createSession(createdUserId);
}

export async function signIn(input: unknown) {
  const payload = signInSchema.parse(input);
  const db = await fileDatabase.read();
  const user = db.users.find((item) => item.email === payload.email.toLowerCase());

  if (!user || !verifyPassword(payload.password, user.passwordHash) || user.status !== "active") {
    throw new AppError(401, "invalid_credentials", "Invalid email or password");
  }

  return createSession(user.id);
}

export async function getSession(token?: string) {
  if (!token) return undefined;
  const db = await fileDatabase.read();
  const session = db.sessions.find((item) => item.token === token && new Date(item.expiresAt) > new Date());
  if (!session) return undefined;
  const user = db.users.find((item) => item.id === session.userId);
  if (!user) return undefined;
  return { session, user };
}

async function createSession(userId: string) {
  const now = new Date();
  const token = randomUUID();
  const expiresAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString();

  const db = await fileDatabase.update((draft) => {
    draft.sessions.push({ token, userId, expiresAt, createdAt: now.toISOString() });
  });

  const user = db.users.find((item) => item.id === userId);
  return { token, user };
}
