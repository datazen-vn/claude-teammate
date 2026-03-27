# Pattern: NestJS CRUD API (chatbot-nestjs)

Extracted from: Canned Responses + Conversation Notes (Sprint 1, 2026-03)
Applicable: Any new CRUD feature in chatbot-nestjs tenant database

---

## Overview

Standard pattern for adding a CRUD API to chatbot-nestjs. Data lives in tenant PostgreSQL databases (TypeORM). Connections obtained from `TenantConnectionPool` (LRU cache, max 50 tenants). Endpoints exposed under `/api/v1/internal/messages/:tenantId/` and proxied by datazen Laravel controllers.

## Architecture Flow

```
Vue composable (useInboxApi)
  → Ziggy named route
  → Laravel InboxController (proxy)
  → MessageManagementApiService → ChatBotApiClient
  → NestJS Controller (@Public, @SkipTenantCheck)
  → Service (TenantConnectionPool → TypeORM repo)
  → Tenant PostgreSQL
```

## File Structure (per feature)

```
src/modules/{module-name}/
├── entities/
│   ├── {feature}.entity.ts        # TypeORM entity
│   └── index.ts                   # Barrel export (add new entity)
├── dto/
│   ├── {feature}.dto.ts           # Create, Update, ListQuery DTOs
│   └── index.ts                   # Barrel export (add new DTOs)
├── services/
│   ├── {feature}.service.ts       # Business logic + DB operations
│   └── index.ts                   # Barrel export (add new service)
├── controllers/
│   └── {feature}.controller.ts    # REST endpoints
└── {module-name}.module.ts        # Register controller + service + export

# Also update:
src/infrastructure/database/tenant/entities/index.ts  # Add to TenantEntities array
database_structures/migrations/{feature}_setup.sql     # Raw SQL migration
```

---

## Entity Template

TypeORM entity with bigint PK, unix millisecond timestamps, soft delete.

```typescript
import { Entity, PrimaryGeneratedColumn, Column, Index } from 'typeorm';

@Entity('cb_{feature_snake_plural}')
@Index('idx_{short}_{composite_name}', ['field1', 'field2'], {
  where: '"deleted_at" IS NULL',  // Partial index — MUST match migration SQL
})
export class {Feature}Entity {
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id!: number;

  @Column({ name: 'subscription_uuid', type: 'varchar', length: 36 })
  @Index('idx_{short}_sub')
  subscriptionUuid!: string;

  // --- Feature-specific fields ---

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title!: string;

  @Column({ name: 'content', type: 'text' })
  content!: string;

  @Column({ name: 'some_flag', type: 'boolean', default: false })
  someFlag!: boolean;

  @Column({ name: 'json_field', type: 'jsonb', default: '[]' })
  jsonField!: string[];

  @Column({ name: 'nullable_field', type: 'varchar', length: 100, nullable: true })
  nullableField!: string | null;

  // --- Audit fields (standard for all entities) ---

  @Column({ name: 'created_by', type: 'varchar', length: 255 })
  createdBy!: string;

  @Column({ name: 'created_by_name', type: 'varchar', length: 255, nullable: true })
  createdByName!: string | null;

  @Column({ name: 'updated_by', type: 'varchar', length: 255, nullable: true })
  updatedBy!: string | null;

  @Column({ name: 'created_at', type: 'bigint' })
  createdAt!: number;

  @Column({ name: 'updated_at', type: 'bigint' })
  updatedAt!: number;

  @Column({ name: 'deleted_at', type: 'bigint', nullable: true })
  deletedAt!: number | null;
}
```

### Entity Rules

- **PK**: Always `bigint` with `@PrimaryGeneratedColumn('increment', { type: 'bigint' })`.
- **Timestamps**: Unix milliseconds (`bigint`), set with `Date.now()`. NOT `timestamp` columns.
- **Soft delete**: `deleted_at bigint NULL`. Filter with `AND deleted_at IS NULL` in queries.
- **Table prefix**: `cb_` for chatbot tables.
- **Column names**: snake_case in `name` option, camelCase in TypeScript property.
- **Partial index `where`**: Must use double-quoted column `"deleted_at"` in entity decorator to match PostgreSQL syntax.
- **Nullable columns**: Use `nullable: true` in Column options, type as `string | null` in TypeScript.

---

## DTO Template

class-validator + class-transformer. MaxLength on ALL string fields.

```typescript
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsArray,
  IsNumber,
  MaxLength,
} from 'class-validator';
import { Type, Transform } from 'class-transformer';

// ── Create DTO ──
export class Create{Feature}Dto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(36)              // ALWAYS 36 for subscription UUID
  subscriptionUuid!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)             // Match varchar(255) in DB
  title!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(10000)           // TEXT fields: set reasonable app-level max
  content!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)             // Match varchar length in DB
  category?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  createdBy!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  createdByName?: string;
}

// ── Update DTO ──
export class Update{Feature}Dto {
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10000)
  content?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  updatedBy!: string;         // REQUIRED in update — tracks who changed it
}

// ── List Query DTO ──
export class {Feature}ListQueryDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(36)
  subscriptionUuid!: string;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  isActive?: boolean;         // Query string booleans need @Transform

  @IsOptional()
  @IsString()
  cursor?: string;            // Cursor = string (validated as numeric in service)

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  limit?: number;
}
```

### DTO Rules

- **MaxLength on ALL strings**: `MaxLength(36)` for UUIDs, `MaxLength(255)` for varchar(255), `MaxLength(10000)` for TEXT.
- **@IsOptional** before optional fields — not after validators.
- **Boolean from query string**: Use `@Transform(({ value }) => value === 'true' || value === true)` before `@IsBoolean()`.
- **Cursor**: Keep as `string` in DTO, parse to number and validate `isNaN` in service.
- **Limit**: Use `@Type(() => Number)` + `@IsNumber()` to coerce query string number.
- **updatedBy**: Required in Update DTO (who made the change). NOT optional.

---

## Service Template

TenantConnectionPool, QueryBuilder, cursor pagination, ILIKE escape.

```typescript
import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { TenantConnectionPool } from '@/infrastructure/database/tenant/tenant-connection.pool';
import { {Feature}Entity } from '../entities/{feature}.entity';

const DEFAULT_PAGE_SIZE = 20;
const MAX_PAGE_SIZE = 50;

@Injectable()
export class {Feature}Service {
  private readonly logger = new Logger({Feature}Service.name);

  constructor(private readonly pool: TenantConnectionPool) {}

  // ── List with cursor pagination ──
  async list(tenantId: string, query: {Feature}ListQuery): Promise<Paginated{Feature}s> {
    const ds = await this.pool.get(tenantId);
    const limit = Math.min(query.limit ?? DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE);

    const qb = ds
      .getRepository({Feature}Entity)
      .createQueryBuilder('t')
      .where('t.subscription_uuid = :subscriptionUuid', {
        subscriptionUuid: query.subscriptionUuid,
      })
      .andWhere('t.deleted_at IS NULL');

    // Optional filters
    if (query.search) {
      // MUST escape % and _ to prevent ILIKE injection
      const escaped = query.search.replace(/%/g, '\\%').replace(/_/g, '\\_');
      qb.andWhere('(t.title ILIKE :search OR t.content ILIKE :search)', {
        search: `%${escaped}%`,
      });
    }

    if (query.isActive !== undefined) {
      qb.andWhere('t.is_active = :isActive', { isActive: query.isActive });
    }

    // Cursor pagination: cursor = last seen id
    if (query.cursor) {
      const cursorId = Number(query.cursor);
      if (isNaN(cursorId)) {
        throw new HttpException('Invalid cursor', HttpStatus.BAD_REQUEST);
      }
      qb.andWhere('t.id < :cursorId', { cursorId });
    }

    qb.orderBy('t.id', 'DESC').take(limit + 1);

    const results = await qb.getMany();
    const hasMore = results.length > limit;
    const data = results.slice(0, limit);
    const nextCursor = hasMore && data.length > 0
      ? String(data[data.length - 1].id)
      : null;

    return { data, nextCursor, hasMore };
  }

  // ── Get by ID ──
  async getById(tenantId: string, id: number): Promise<{Feature}Entity | null> {
    const ds = await this.pool.get(tenantId);
    const entity = await ds.getRepository({Feature}Entity).findOne({
      where: { id },
    });
    if (!entity || entity.deletedAt) return null;
    return entity;
  }

  // ── Create ──
  async create(tenantId: string, data: Create{Feature}Input): Promise<{Feature}Entity> {
    const ds = await this.pool.get(tenantId);
    const repo = ds.getRepository({Feature}Entity);
    const now = Date.now();

    const entity = repo.create({
      subscriptionUuid: data.subscriptionUuid,
      // ...fields...
      createdBy: data.createdBy,
      createdByName: data.createdByName ?? null,
      updatedBy: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    });

    const saved = await repo.save(entity);
    this.logger.log(`{Feature} created: id=${saved.id}, subscription=${data.subscriptionUuid}`);
    return saved;
  }

  // ── Update ──
  async update(tenantId: string, id: number, data: Update{Feature}Input): Promise<{Feature}Entity> {
    const ds = await this.pool.get(tenantId);
    const repo = ds.getRepository({Feature}Entity);

    const existing = await repo.findOne({ where: { id } });
    if (!existing || existing.deletedAt) {
      throw new HttpException('{Feature} not found', HttpStatus.NOT_FOUND);
    }

    const updateData: Partial<{Feature}Entity> = {
      updatedBy: data.updatedBy,
      updatedAt: Date.now(),
    };

    // Only update provided fields
    if (data.title !== undefined) updateData.title = data.title;
    if (data.content !== undefined) updateData.content = data.content;

    await repo.update(id, updateData);

    const updated = await repo.findOneOrFail({ where: { id } });
    this.logger.log(`{Feature} updated: id=${id}`);
    return updated;
  }

  // ── Soft Delete ──
  async softDelete(tenantId: string, id: number): Promise<void> {
    const ds = await this.pool.get(tenantId);
    const repo = ds.getRepository({Feature}Entity);

    const existing = await repo.findOne({ where: { id } });
    if (!existing || existing.deletedAt) {
      throw new HttpException('{Feature} not found', HttpStatus.NOT_FOUND);
    }

    await repo.update(id, { deletedAt: Date.now(), updatedAt: Date.now() });
    this.logger.log(`{Feature} soft-deleted: id=${id}`);
  }
}
```

### Service Rules

- **ALWAYS `await this.pool.get(tenantId)`** to get the DataSource for the correct tenant DB.
- **ALWAYS filter by `subscriptionUuid`** to prevent cross-subscription data leaks (multi-tenant isolation).
- **ALWAYS filter `deleted_at IS NULL`** for soft-deleted records in list/get queries.
- **ILIKE escape**: Replace `%` and `_` before constructing ILIKE patterns.
- **Cursor validation**: Parse to Number, check `isNaN`, throw 400 if invalid.
- **Timestamps**: `Date.now()` returns unix milliseconds.
- **Update pattern**: Build partial update object, only set fields that are `!== undefined`.
- **Soft delete**: Set `deletedAt = Date.now()`, also update `updatedAt`.

---

## Controller Template

`@Public()`, `@SkipTenantCheck()`, `setTenantContext()`, `ParseIntPipe`.

```typescript
import {
  Controller, Get, Post, Patch, Delete,
  Param, Query, Body, Logger,
  ParseIntPipe, HttpException, HttpStatus,
} from '@nestjs/common';
import { ClsService } from 'nestjs-cls';
import { Public, SkipTenantCheck } from '@common/index';
import { {Feature}Service } from '../services/{feature}.service';
import { Create{Feature}Dto, Update{Feature}Dto, {Feature}ListQueryDto } from '../dto';

@Controller('internal/messages')
@Public()              // Skip JWT auth (internal API, called by Laravel backend)
@SkipTenantCheck()     // Skip tenant middleware (tenantId in route params)
export class {Feature}Controller {
  private readonly logger = new Logger({Feature}Controller.name);

  constructor(
    private readonly cls: ClsService,
    private readonly service: {Feature}Service,
  ) {}

  // CRITICAL: Must call this BEFORE any tenant DB operation
  private setTenantContext(tenantId: string): void {
    this.cls.set('tenantId', tenantId);
  }

  @Get(':tenantId/{feature-kebab-plural}')
  async list(
    @Param('tenantId') tenantId: string,
    @Query() query: {Feature}ListQueryDto,
  ) {
    this.setTenantContext(tenantId);
    return this.service.list(tenantId, { /* map query fields */ });
  }

  @Get(':tenantId/{feature-kebab-plural}/:id')
  async getById(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,  // ParseIntPipe validates & converts
  ) {
    this.setTenantContext(tenantId);
    const item = await this.service.getById(tenantId, id);
    if (!item) {
      throw new HttpException('{Feature} not found', HttpStatus.NOT_FOUND);
    }
    return { data: item };
  }

  @Post(':tenantId/{feature-kebab-plural}')
  async create(
    @Param('tenantId') tenantId: string,
    @Body() body: Create{Feature}Dto,
  ) {
    this.setTenantContext(tenantId);
    try {
      const item = await this.service.create(tenantId, { /* map body fields */ });
      return { data: item };
    } catch (error: any) {
      if (error instanceof HttpException) throw error;
      this.logger.error(`Create {feature} failed: ${error?.message}`, error?.stack);
      throw new HttpException(
        error?.message || 'Failed to create {feature}',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Patch(':tenantId/{feature-kebab-plural}/:id')
  async update(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,
    @Body() body: Update{Feature}Dto,
  ) {
    this.setTenantContext(tenantId);
    try {
      const item = await this.service.update(tenantId, id, { /* map body fields */ });
      return { data: item };
    } catch (error: any) {
      if (error instanceof HttpException) throw error;
      this.logger.error(`Update {feature} failed: ${error?.message}`, error?.stack);
      throw new HttpException(
        error?.message || 'Failed to update {feature}',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Delete(':tenantId/{feature-kebab-plural}/:id')
  async delete(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,
  ) {
    this.setTenantContext(tenantId);
    try {
      await this.service.softDelete(tenantId, id);
      return { success: true };
    } catch (error: any) {
      if (error instanceof HttpException) throw error;
      this.logger.error(`Delete {feature} failed: ${error?.message}`, error?.stack);
      throw new HttpException(
        error?.message || 'Failed to delete {feature}',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
```

### Controller Rules

- **`@Public()` + `@SkipTenantCheck()`**: Internal APIs called by Laravel backend, not browser clients.
- **`setTenantContext(tenantId)` BEFORE every handler body**: Required so TenantConnectionPool resolves the correct tenant DB.
- **`ParseIntPipe`** on all numeric route params (id, conversationId, etc.).
- **Error handling pattern**: Re-throw HttpException, wrap unknown errors with 500 + logger.
- **Response format**: `{ data: entity }` for single items, `{ data: [], nextCursor, hasMore }` for lists, `{ success: true }` for deletes.
- **Route prefix**: All under `internal/messages` controller, sub-paths per feature.

---

## Migration SQL Template

Raw SQL for manual execution on tenant databases (TypeORM synchronize may be disabled in production).

```sql
-- ═══════════════════════════════════════════════════════════════════════════
-- {FEATURE_UPPER} SETUP - Tenant Database (TypeORM)
-- ═══════════════════════════════════════════════════════════════════════════
-- Run this SQL in each Tenant Database to create the {feature} table.
-- Table: cb_{feature_snake_plural}

CREATE TABLE IF NOT EXISTS cb_{feature_snake_plural} (
  id                BIGSERIAL PRIMARY KEY,
  subscription_uuid VARCHAR(36) NOT NULL,
  -- feature-specific columns --
  title             VARCHAR(255) NOT NULL,
  content           TEXT NOT NULL,
  some_flag         BOOLEAN NOT NULL DEFAULT false,
  json_field        JSONB NOT NULL DEFAULT '[]',
  nullable_field    VARCHAR(100),
  -- audit columns --
  created_by        VARCHAR(255) NOT NULL,
  created_by_name   VARCHAR(255),
  updated_by        VARCHAR(255),
  created_at        BIGINT NOT NULL,
  updated_at        BIGINT NOT NULL,
  deleted_at        BIGINT
);

-- Index: subscription_uuid (partition key for multi-tenant queries)
CREATE INDEX IF NOT EXISTS idx_{short}_sub
  ON cb_{feature_snake_plural} (subscription_uuid);

-- Index: composite for common queries
CREATE INDEX IF NOT EXISTS idx_{short}_{fields}
  ON cb_{feature_snake_plural} (field1, field2);

-- Partial index: exclude soft-deleted records (MUST match entity @Index where clause)
CREATE INDEX IF NOT EXISTS idx_{short}_{name}
  ON cb_{feature_snake_plural} (field1, field2, created_at)
  WHERE deleted_at IS NULL;

-- Unique partial index (if needed): unique constraint excluding soft-deleted
CREATE UNIQUE INDEX IF NOT EXISTS uq_{short}_{fields}
  ON cb_{feature_snake_plural} (subscription_uuid, unique_field)
  WHERE deleted_at IS NULL AND unique_field IS NOT NULL;
```

### Migration Rules

- **Table prefix**: `cb_` for all chatbot tables.
- **PK**: `BIGSERIAL PRIMARY KEY` (auto-increment bigint).
- **subscription_uuid**: `VARCHAR(36) NOT NULL` — always present, always indexed.
- **Timestamps**: `BIGINT NOT NULL` (unix milliseconds). NOT `TIMESTAMP`.
- **Soft delete**: `deleted_at BIGINT` (nullable).
- **Partial indexes**: `WHERE deleted_at IS NULL` — exclude soft-deleted records from indexes.
- **Unique indexes**: Use `CREATE UNIQUE INDEX ... WHERE deleted_at IS NULL AND field IS NOT NULL` for soft-delete-aware uniqueness.
- **Index naming**: `idx_{short}_{purpose}` for regular, `uq_{short}_{purpose}` for unique.

---

## Module Registration Checklist

When adding a new CRUD feature, update these files:

1. **`entities/index.ts`** (module barrel): Export the new entity class
2. **`dto/index.ts`** (module barrel): Export new DTO classes
3. **`services/index.ts`** (module barrel): Export new service class
4. **`{module}.module.ts`**: Add controller to `controllers[]`, service to `providers[]` and `exports[]`
5. **`src/infrastructure/database/tenant/entities/index.ts`**:
   - Add import for new entity
   - Add entity class to `TenantEntities[]` array
6. **`database_structures/migrations/`**: Create `{feature}_setup.sql`

### Registration Order Matters

If you forget step 5 (TenantEntities), TypeORM will NOT recognize the entity and all queries will fail silently or throw "Entity not found" errors.

---

## Critical Gotchas (from Sprint 1 code review)

### Security

- **ALWAYS filter by `subscriptionUuid`** in list queries. Without this, tenant A can see tenant B's data within the same database.
- **`MaxLength(36)` on subscriptionUuid** in DTOs — prevents overflow attacks.
- **`MaxLength(255)` on all varchar(255) fields** — DTO validation must match DB constraints.

### Tenant Context

- **MUST call `setTenantContext(tenantId)` BEFORE any tenant DB operation** in every controller handler. If you forget, `pool.get()` may resolve to the wrong tenant or fail.

### ILIKE Search

- **MUST escape `%` and `_`** in ILIKE search values: `query.search.replace(/%/g, '\\%').replace(/_/g, '\\_')`. Without this, a search query containing `%` becomes a wildcard that returns all rows.

### Cursor Pagination

- **Cursor is a string in DTO but numeric in practice**. MUST validate with `isNaN(Number(cursor))` in service and throw 400 if invalid. Without this, a non-numeric cursor causes a PostgreSQL cast error.
- **Fetch `limit + 1`** rows, check `results.length > limit` for hasMore, return `results.slice(0, limit)`.

### Partial Indexes

- **Entity `@Index` `where` clause MUST match migration SQL exactly**. Use double-quoted column names in entity: `where: '"deleted_at" IS NULL'`. Mismatch = TypeORM creates a different index than expected.

### Timestamps

- **Always set both `createdAt` and `updatedAt` to `Date.now()`** on create.
- **Always set `updatedAt` to `Date.now()`** on update and soft-delete.
- **Soft delete**: Set `deletedAt = Date.now()`, NOT a boolean flag.

### Boolean Query Params

- **Query string booleans** arrive as `'true'`/`'false'` strings. Use `@Transform(({ value }) => value === 'true' || value === true)` in DTO.

### Null vs Undefined in Updates

- **`undefined` = field not provided** (don't update).
- **`null` = explicitly set to null** (clear the field).
- Use `if (data.field !== undefined)` pattern in service update methods.
