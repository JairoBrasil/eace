-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "OrgType" AS ENUM ('FABRICA', 'DISTRIBUIDOR', 'PARCEIRO');

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'GESTOR', 'TECNICO');

-- CreateEnum
CREATE TYPE "StepKind" AS ENUM ('FOTO_OBRIGATORIA', 'FOTO_OPCIONAL', 'TEXTO', 'CHECKBOX', 'ASSINATURA', 'SELECAO_MULTIPLA', 'NUMERO', 'CHECKLIST', 'DOCUMENTO');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('ABERTA', 'AGENDADA', 'EM_DESLOCAMENTO', 'EM_ANDAMENTO', 'AGUARDANDO_VALIDACAO', 'REPROVADA', 'CONCLUIDA', 'CANCELADA');

-- CreateEnum
CREATE TYPE "LedgerType" AS ENUM ('SERVICO', 'ABATIMENTO', 'PAGAMENTO', 'AJUSTE');

-- CreateTable
CREATE TABLE "Org" (
    "id" TEXT NOT NULL,
    "type" "OrgType" NOT NULL,
    "name" TEXT NOT NULL,
    "document" TEXT,
    "parentId" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Org_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "orgId" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "Role" NOT NULL,
    "mustChangePw" BOOLEAN NOT NULL DEFAULT true,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ServiceType" (
    "id" TEXT NOT NULL,
    "factoryId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "defaultValue" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "slaHours" INTEGER NOT NULL DEFAULT 48,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ServiceType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StepTemplate" (
    "id" TEXT NOT NULL,
    "serviceTypeId" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "kind" "StepKind" NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT true,
    "config" JSONB,

    CONSTRAINT "StepTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkOrder" (
    "id" TEXT NOT NULL,
    "number" SERIAL NOT NULL,
    "serviceTypeId" TEXT NOT NULL,
    "factoryId" TEXT NOT NULL,
    "distributorId" TEXT,
    "partnerId" TEXT,
    "technicianId" TEXT,
    "customerName" TEXT NOT NULL,
    "customerPhone" TEXT,
    "address" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "status" "OrderStatus" NOT NULL DEFAULT 'ABERTA',
    "openedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "scheduledAt" TIMESTAMP(3),
    "slaDueAt" TIMESTAMP(3),
    "startedAt" TIMESTAMP(3),
    "finishedAt" TIMESTAMP(3),
    "validatedAt" TIMESTAMP(3),
    "serviceValue" DECIMAL(12,2) NOT NULL,
    "valueOverriddenById" TEXT,
    "valueOverrideReason" TEXT,

    CONSTRAINT "WorkOrder_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrderStep" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "kind" "StepKind" NOT NULL,
    "required" BOOLEAN NOT NULL,
    "config" JSONB,
    "value" JSONB,
    "completedAt" TIMESTAMP(3),
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,

    CONSTRAINT "OrderStep_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Photo" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "stepId" TEXT,
    "userId" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "sha256" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "takenAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Photo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TrackPoint" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "accuracy" DOUBLE PRECISION,
    "recordedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TrackPoint_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Advance" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "applied" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "paidAt" TIMESTAMP(3) NOT NULL,
    "note" TEXT,
    "createdBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Advance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LedgerEntry" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "orderId" TEXT,
    "type" "LedgerType" NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "note" TEXT,
    "createdBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LedgerEntry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Org_parentId_idx" ON "Org"("parentId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_orgId_idx" ON "User"("orgId");

-- CreateIndex
CREATE INDEX "ServiceType_factoryId_idx" ON "ServiceType"("factoryId");

-- CreateIndex
CREATE UNIQUE INDEX "StepTemplate_serviceTypeId_position_key" ON "StepTemplate"("serviceTypeId", "position");

-- CreateIndex
CREATE UNIQUE INDEX "WorkOrder_number_key" ON "WorkOrder"("number");

-- CreateIndex
CREATE INDEX "WorkOrder_partnerId_status_idx" ON "WorkOrder"("partnerId", "status");

-- CreateIndex
CREATE INDEX "WorkOrder_technicianId_status_idx" ON "WorkOrder"("technicianId", "status");

-- CreateIndex
CREATE INDEX "WorkOrder_distributorId_idx" ON "WorkOrder"("distributorId");

-- CreateIndex
CREATE UNIQUE INDEX "OrderStep_orderId_position_key" ON "OrderStep"("orderId", "position");

-- CreateIndex
CREATE INDEX "Photo_orderId_idx" ON "Photo"("orderId");

-- CreateIndex
CREATE INDEX "TrackPoint_orderId_recordedAt_idx" ON "TrackPoint"("orderId", "recordedAt");

-- CreateIndex
CREATE INDEX "Advance_partnerId_idx" ON "Advance"("partnerId");

-- CreateIndex
CREATE INDEX "LedgerEntry_partnerId_createdAt_idx" ON "LedgerEntry"("partnerId", "createdAt");

-- AddForeignKey
ALTER TABLE "Org" ADD CONSTRAINT "Org_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Org"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_orgId_fkey" FOREIGN KEY ("orgId") REFERENCES "Org"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ServiceType" ADD CONSTRAINT "ServiceType_factoryId_fkey" FOREIGN KEY ("factoryId") REFERENCES "Org"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StepTemplate" ADD CONSTRAINT "StepTemplate_serviceTypeId_fkey" FOREIGN KEY ("serviceTypeId") REFERENCES "ServiceType"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkOrder" ADD CONSTRAINT "WorkOrder_serviceTypeId_fkey" FOREIGN KEY ("serviceTypeId") REFERENCES "ServiceType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkOrder" ADD CONSTRAINT "WorkOrder_technicianId_fkey" FOREIGN KEY ("technicianId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrderStep" ADD CONSTRAINT "OrderStep_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "WorkOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "WorkOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_stepId_fkey" FOREIGN KEY ("stepId") REFERENCES "OrderStep"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TrackPoint" ADD CONSTRAINT "TrackPoint_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "WorkOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TrackPoint" ADD CONSTRAINT "TrackPoint_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Advance" ADD CONSTRAINT "Advance_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Org"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Org"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LedgerEntry" ADD CONSTRAINT "LedgerEntry_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "WorkOrder"("id") ON DELETE SET NULL ON UPDATE CASCADE;

