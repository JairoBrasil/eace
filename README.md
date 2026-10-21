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
