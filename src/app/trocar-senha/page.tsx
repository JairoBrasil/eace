import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { hashPassword, verifyPassword } from "@/lib/password";
import { createSession, getCurrentUser } from "@/lib/session";

async function changePassword(formData: FormData) {
  "use server";
  const user = await getCurrentUser();
  if (!user) redirect("/login");
  const current = String(formData.get("current") ?? "");
  const next = String(formData.get("next") ?? "");
  if (!verifyPassword(current, user.passwordHash)) redirect("/trocar-senha?erro=atual");
  if (next.length < 8) redirect("/trocar-senha?erro=curta");
  await db.user.update({
    where: { id: user.id },
    data: { passwordHash: hashPassword(next), mustChangePw: false, passwordChangedAt: new Date() },
  });
  await createSession(user.id); // sessões antigas caem; esta é renovada
  redirect("/");
}

export default async function TrocarSenhaPage({ searchParams }: { searchParams: Promise<{ erro?: string }> }) {
  if (!(await getCurrentUser())) redirect("/login");
  const { erro } = await searchParams;
  return (
    <main style={{ maxWidth: 360, margin: "10vh auto", padding: 16 }}>
      <h1>Trocar senha</h1>
      <form action={changePassword} style={{ display: "grid", gap: 12 }}>
        <input name="current" type="password" placeholder="Senha atual" required autoComplete="current-password" />
        <input name="next" type="password" placeholder="Nova senha (mín. 8)" required autoComplete="new-password" />
        {erro === "atual" && <p style={{ color: "#b91c1c" }}>Senha atual incorreta.</p>}
        {erro === "curta" && <p style={{ color: "#b91c1c" }}>A nova senha precisa de 8+ caracteres.</p>}
        <button type="submit">Salvar</button>
      </form>
    </main>
  );
}
