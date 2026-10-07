import { createHash, randomBytes, timingSafeEqual } from "node:crypto";

export function hashPassword(password: string): string {
  const salt = randomBytes(16).toString("hex");
  const digest = createHash("sha256").update(`${salt}:${password}`).digest("hex");
  return `${salt}:${digest}`;
}

export function verifyPassword(password: string, passwordHash: string): boolean {
  const [salt, digest] = passwordHash.split(":");
  if (!salt || !digest) return false;
  const candidate = createHash("sha256").update(`${salt}:${password}`).digest("hex");
  return timingSafeEqual(Buffer.from(candidate), Buffer.from(digest));
}
