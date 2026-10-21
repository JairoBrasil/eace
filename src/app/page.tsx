import { redirect } from "next/navigation";
import { destroySession, getCurrentUser } from "@/lib/session";

async function logout() {
  "use server";
  await destroySession();
  redirect("/login");
}

export default async function Home() {
  const user = await getCurrentUser();
  if (!user) redirect("/login");
  if (user.mustChangePw) redirect("/trocar-senha");
  return (
    <main style={{ padding: 24 }}>
      <h1>OperaOS</h1>
      <p>
        {user.name} · {user.role} · {user.org.name} ({user.org.type})
      </p>
      <form action={logout}>
        <button type="submit">Sair</button>
      </form>
    </main>
  );
}
