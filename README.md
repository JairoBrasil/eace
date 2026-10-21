# OperaOS

Gestão de ordens de serviço em campo. Hierarquia: **Fábrica → Distribuição → Parceiro → Técnico**.

Stack: Next.js 15 + Prisma 6 + PostgreSQL. Deploy via Kadai Deploy.

## Desenvolvimento
```bash
cp .env.example .env   # ajustar DATABASE_URL
npm ci
npx prisma migrate dev
npm run dev
```

## Regras financeiras
- Cada tipo de serviço tem `defaultValue` (valor a pagar ao parceiro). Admin pode sobrescrever na OS (`serviceValue`).
- OS concluída gera `LedgerEntry` tipo `SERVICO` (+).
- Adiantamento (`Advance`) é abatido na conclusão da OS: gera `ABATIMENTO` (−) até o limite do saldo do adiantamento.
- Pagamentos ao parceiro: `PAGAMENTO` (−). Correções: `AJUSTE`. O razão é imutável.
- Saldo a receber = soma de `LedgerEntry.amount` do parceiro.

## Deploy (Kadai)
Bloco `apps.operaos` do `config.json`: `previewHook` e `promoteHook` = `npx prisma migrate deploy`,
`healthPath` = `/api/health`, `previewUrlVars` = `["APP_URL"]`. Bancos `operaos` e `operaos_staging`.
Fotos gravadas em `UPLOAD_DIR` (fora de `releases/`, que é apagada a cada deploy).

## Primeiro acesso
Variável obrigatória: `AUTH_SECRET` (16+ caracteres) no `.env.production` e no `.env.preview`.
Criar o primeiro admin (como jairo, na pasta do release ou local):
```bash
node scripts/criar-admin.mjs "Nome da Fábrica" email@dominio "Nome" senhaProvisoria
```
O usuário é obrigado a trocar a senha no primeiro login. Trocar senha ou desativar o usuário derruba as sessões abertas.
