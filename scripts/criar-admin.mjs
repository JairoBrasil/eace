// Uso: node scripts/criar-admin.mjs "Nome da Fábrica" email@dominio "Nome" senhaProvisoria
import { randomBytes, scryptSync } from "node:crypto";
import { PrismaClient } from "@prisma/client";

const [, , orgName, email, name, password] = process.argv;
if (!orgName || !email || !name || !password) {
  console.error('Uso: node scripts/criar-admin.mjs "Fábrica" email "Nome" senha');
  process.exit(1);
}
const salt = randomBytes(16).toString("hex");
const passwordHash = `${salt}:${scryptSync(password, salt, 64).toString("hex")}`;

const db = new PrismaClient();
const org =
  (await db.org.findFirst({ where: { type: "FABRICA", name: orgName } })) ??
  (await db.org.create({ data: { type: "FABRICA", name: orgName } }));
const user = await db.user.create({
  data: { orgId: org.id, email: email.toLowerCase(), name, role: "ADMIN", passwordHash },
});
console.log(`Admin criado: ${user.email} (${org.name})`);
await db.$disconnect();
