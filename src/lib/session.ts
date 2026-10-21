import { createHmac, timingSafeEqual } from "node:crypto";
import { cookies } from "next/headers";
import { db } from "@/lib/db";

export const SESSION_COOKIE = "operaos_session";
const MAX_AGE_SEC = 60 * 60 * 12;

function secret(): string {
  const s = process.env.AUTH_SECRET;
  if (!s || s.length < 16) throw new Error("AUTH_SECRET ausente ou curto demais");
  return s;
}

function sign(payload: string): string {
  return createHmac("sha256", secret()).update(payload).digest("base64url");
}

export async function createSession(userId: string) {
  const payload = `${userId}.${Date.now()}`;
  const store = await cookies();
  store.set(SESSION_COOKIE, `${payload}.${sign(payload)}`, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: MAX_AGE_SEC,
  });
}

export async function destroySession() {
  (await cookies()).delete(SESSION_COOKIE);
}

// Valida a assinatura e confere o usuário no banco a cada requisição:
// desativar o usuário ou trocar a senha derruba a sessão na hora.
export async function getCurrentUser() {
  const raw = (await cookies()).get(SESSION_COOKIE)?.value;
  if (!raw) return null;
  const i = raw.lastIndexOf(".");
  const payload = raw.slice(0, i);
  const given = Buffer.from(raw.slice(i + 1));
  const wanted = Buffer.from(sign(payload));
  if (given.length !== wanted.length || !timingSafeEqual(given, wanted)) return null;

  const [userId, issuedAt] = payload.split(".");
  const user = await db.user.findUnique({ where: { id: userId }, include: { org: true } });
  if (!user || !user.active) return null;
  if (user.passwordChangedAt && user.passwordChangedAt.getTime() > Number(issuedAt)) return null;
  if (Date.now() - Number(issuedAt) > MAX_AGE_SEC * 1000) return null;
  return user;
}
