-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "username" TEXT,
    "passwordHash" TEXT,
    "ldapUsername" TEXT,
    "role" TEXT NOT NULL DEFAULT 'USER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "password_reset_tokens" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "token" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expiresAt" DATETIME NOT NULL,
    "usedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "password_reset_tokens_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "key" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "user_permissions" (
    "userId" TEXT NOT NULL,
    "permissionId" TEXT NOT NULL,
    "grantedBy" TEXT,
    "grantedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("userId", "permissionId"),
    CONSTRAINT "user_permissions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "user_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "permissions" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "user_permissions_grantedBy_fkey" FOREIGN KEY ("grantedBy") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "files" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "filename" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" BIGINT NOT NULL,
    "storagePath" TEXT NOT NULL,
    "storageType" TEXT NOT NULL DEFAULT 'local',
    "uploadedBy" TEXT NOT NULL,
    "deletedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "files_uploadedBy_fkey" FOREIGN KEY ("uploadedBy") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "document_analyses" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fileContentId" TEXT NOT NULL,
    "documentType" TEXT NOT NULL,
    "documentTypeConfidence" REAL NOT NULL,
    "extractedMetadata" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "document_analyses_fileContentId_fkey" FOREIGN KEY ("fileContentId") REFERENCES "file_contents" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chunking_proposals" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fileContentId" TEXT NOT NULL,
    "suggestedMethods" TEXT NOT NULL,
    "selectedMethod" TEXT,
    "userFeedback" TEXT,
    "finalStrategy" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "chunking_proposals_fileContentId_fkey" FOREIGN KEY ("fileContentId") REFERENCES "file_contents" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chunk_previews" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "proposalId" TEXT NOT NULL,
    "chunkIndex" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "startChar" INTEGER NOT NULL,
    "endChar" INTEGER NOT NULL,
    "userFeedback" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chunk_previews_proposalId_fkey" FOREIGN KEY ("proposalId") REFERENCES "chunking_proposals" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chunk_embeddings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "chunkId" TEXT NOT NULL,
    "chromaId" TEXT NOT NULL,
    "chromaCollection" TEXT NOT NULL,
    "embeddingModel" TEXT NOT NULL,
    "embeddingDim" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "embeddedAt" DATETIME,
    "error" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "fileContentId" TEXT,
    CONSTRAINT "chunk_embeddings_chunkId_fkey" FOREIGN KEY ("chunkId") REFERENCES "chunks" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "chunk_embeddings_fileContentId_fkey" FOREIGN KEY ("fileContentId") REFERENCES "file_contents" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "rag_retrievals" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fileContentId" TEXT NOT NULL,
    "query" TEXT NOT NULL,
    "retrievedChunks" TEXT NOT NULL,
    "llmResponse" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "rag_retrievals_fileContentId_fkey" FOREIGN KEY ("fileContentId") REFERENCES "file_contents" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chain_executions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fileContentId" TEXT NOT NULL,
    "chainType" TEXT NOT NULL,
    "input" TEXT NOT NULL,
    "output" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "tokensUsed" INTEGER,
    "executionTime" INTEGER,
    "status" TEXT NOT NULL,
    "error" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chain_executions_fileContentId_fkey" FOREIGN KEY ("fileContentId") REFERENCES "file_contents" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "file_contents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fileId" TEXT NOT NULL,
    "parseStatus" TEXT NOT NULL DEFAULT 'pending',
    "parsedAt" DATETIME,
    "parseError" TEXT,
    "parseVersion" INTEGER NOT NULL DEFAULT 1,
    "markdownPath" TEXT,
    "metadata" TEXT,
    "deletedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "file_contents_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "files" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chunks" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fileContentId" TEXT NOT NULL,
    "chunkIndex" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "startChar" INTEGER NOT NULL,
    "endChar" INTEGER NOT NULL,
    "heading" TEXT,
    "embeddingId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chunks_fileContentId_fkey" FOREIGN KEY ("fileContentId") REFERENCES "file_contents" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_ldapUsername_key" ON "users"("ldapUsername");

-- CreateIndex
CREATE INDEX "users_isActive_idx" ON "users"("isActive");

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");

-- CreateIndex
CREATE INDEX "users_createdAt_idx" ON "users"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "password_reset_tokens_token_key" ON "password_reset_tokens"("token");

-- CreateIndex
CREATE INDEX "password_reset_tokens_expiresAt_idx" ON "password_reset_tokens"("expiresAt");

-- CreateIndex
CREATE INDEX "password_reset_tokens_userId_expiresAt_idx" ON "password_reset_tokens"("userId", "expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_key_key" ON "permissions"("key");

-- CreateIndex
CREATE INDEX "permissions_category_idx" ON "permissions"("category");

-- CreateIndex
CREATE INDEX "user_permissions_permissionId_idx" ON "user_permissions"("permissionId");

-- CreateIndex
CREATE INDEX "user_permissions_grantedBy_idx" ON "user_permissions"("grantedBy");

-- CreateIndex
CREATE INDEX "files_uploadedBy_idx" ON "files"("uploadedBy");

-- CreateIndex
CREATE INDEX "files_deletedAt_idx" ON "files"("deletedAt");

-- CreateIndex
CREATE INDEX "files_createdAt_idx" ON "files"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "document_analyses_fileContentId_key" ON "document_analyses"("fileContentId");

-- CreateIndex
CREATE INDEX "document_analyses_fileContentId_idx" ON "document_analyses"("fileContentId");

-- CreateIndex
CREATE INDEX "document_analyses_status_idx" ON "document_analyses"("status");

-- CreateIndex
CREATE UNIQUE INDEX "chunking_proposals_fileContentId_key" ON "chunking_proposals"("fileContentId");

-- CreateIndex
CREATE INDEX "chunking_proposals_fileContentId_idx" ON "chunking_proposals"("fileContentId");

-- CreateIndex
CREATE INDEX "chunking_proposals_status_idx" ON "chunking_proposals"("status");

-- CreateIndex
CREATE INDEX "chunk_previews_proposalId_idx" ON "chunk_previews"("proposalId");

-- CreateIndex
CREATE UNIQUE INDEX "chunk_embeddings_chunkId_key" ON "chunk_embeddings"("chunkId");

-- CreateIndex
CREATE UNIQUE INDEX "chunk_embeddings_chromaId_key" ON "chunk_embeddings"("chromaId");

-- CreateIndex
CREATE INDEX "chunk_embeddings_chunkId_idx" ON "chunk_embeddings"("chunkId");

-- CreateIndex
CREATE INDEX "chunk_embeddings_chromaCollection_idx" ON "chunk_embeddings"("chromaCollection");

-- CreateIndex
CREATE INDEX "chunk_embeddings_status_idx" ON "chunk_embeddings"("status");

-- CreateIndex
CREATE INDEX "rag_retrievals_fileContentId_idx" ON "rag_retrievals"("fileContentId");

-- CreateIndex
CREATE INDEX "rag_retrievals_createdAt_idx" ON "rag_retrievals"("createdAt");

-- CreateIndex
CREATE INDEX "chain_executions_fileContentId_idx" ON "chain_executions"("fileContentId");

-- CreateIndex
CREATE INDEX "chain_executions_chainType_idx" ON "chain_executions"("chainType");

-- CreateIndex
CREATE UNIQUE INDEX "file_contents_fileId_key" ON "file_contents"("fileId");

-- CreateIndex
CREATE INDEX "file_contents_createdAt_idx" ON "file_contents"("createdAt");

-- CreateIndex
CREATE INDEX "chunks_fileContentId_idx" ON "chunks"("fileContentId");

-- CreateIndex
CREATE UNIQUE INDEX "chunks_fileContentId_chunkIndex_key" ON "chunks"("fileContentId", "chunkIndex");
