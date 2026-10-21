import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { verifyPassword } from "@/lib/password";
import { createSession, getCurrentUser } from "@/lib/session";

async function login(formData: FormData) {
  "use server";
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");
  const user = await db.user.findUnique({ where: { email } });
  if (!user || !user.active || !verifyPassword(password, user.passwordHash)) {
    redirect("/login?erro=1");
  }
  await createSession(user.id);
  redirect(user.mustChangePw ? "/trocar-senha" : "/");
}

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ erro?: string }> }) {
  if (await getCurrentUser()) redirect("/");
  const { erro } = await searchParams;
  return (
    <main style={{ maxWidth: 360, margin: "10vh auto", padding: 16 }}>
      <h1>OperaOS</h1>
      <form action={login} style={{ display: "grid", gap: 12 }}>
        <input name="email" type="email" placeholder="E-mail" required autoComplete="username" />
        <input name="password" type="password" placeholder="Senha" required autoComplete="current-password" />
        {erro && <p style={{ color: "#b91c1c" }}>E-mail ou senha inválidos.</p>}
        <button type="submit">Entrar</button>
      </form>
    </main>
  );
}
