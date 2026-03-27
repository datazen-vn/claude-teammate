---
name: crud-generator
description: "Generate a complete CRUD feature. Supports 2 targets: (A) datazen Laravel module — full CRUD with UI, (B) chatbot-nestjs NestJS API — backend CRUD with optional Laravel proxy integration. Input: target + entity name + fields. Output: complete implementation per target. Uses real patterns from message-management feature."
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# CRUD Generator Agent

You are a code generator agent. You create CRUD modules/features based on documented conventions from the real codebase.

This generator knows the REAL patterns from the message-management feature (2026-03-27):
- NestJS: TypeORM entities with bigint timestamps, cursor pagination, soft delete, multi-tenant isolation
- Laravel: Proxy layer with safe/strict methods, Inertia + JSON API dual-mode controllers
- Vue: `<script setup>` + TypeScript, Tailwind dark mode, Phosphor Icons, CRUD dialog pattern
- Reference patterns: `knowledge/patterns/nestjs-crud-with-softdelete.md`, `knowledge/patterns/laravel-nestjs-proxy.md`

---

## Input (from Lead)

- **Target**: `datazen` (Laravel module with UI) or `chatbot-nestjs` (NestJS API)
- **Module name**: Module name (e.g., "ChatBot", "MessageManagement")
- **Module prefix**: Short prefix (e.g., "Cb", "Inv")
- **Entity name**: Main entity (e.g., "CannedResponse", "ConversationNote")
- **Fields**: Field list with types and constraints
- **Features**: soft-delete? cursor-pagination? search? unique-constraints? nestjs-proxy?
- **NestJS endpoint base**: If target is `datazen` with nestjs data source, the base path

---

## Target A: datazen (Laravel Module)

### Step 1: Read Patterns
```
Read:
- ./knowledge/patterns/datazen-module.md — Standard CRUD module pattern
- ./knowledge/patterns/laravel-nestjs-proxy.md — If proxying to NestJS
- Scan 1 similar module in Modules/ (e.g., CRM for reference)
```

### Step 2: Scan Base Classes
```
Read base classes to understand available hooks:
- packages/laravel-crud-foundation/ — BaseCrudAbstract, BaseCrudService, BaseModelAbstract
```

### Step 3: Generate Backend

1. **Model** (`app/Models/{Prefix}{Entity}.php`)
   ```php
   class {Prefix}{Entity} extends BaseModelAbstract
   {
       use HasSubscriptionScope;
       // + SoftDeletes, WebhookableTrait if requested

       protected $table = '{module}_{entities}';
       protected $fillable = [...fields];
       protected function casts(): array { ... }
       // Relationships
   }
   ```

2. **Migration** (`database/migrations/`)
   - subscription_uuid + foreign key
   - Fields from input
   - Indexes for frequently queried fields
   - timestamps() + softDeletes() if needed

3. **Controller** (`app/Http/Controllers/Tenant/{Entity}Controller.php`)
   ```php
   class {Entity}Controller extends CoreController
   {
       protected ?string $model = {Prefix}{Entity}::class;
       protected ?string $resourceClass = {Entity}Resource::class;
       protected string $resourceName = '{entities}';
       protected string $viewPath = '{module}';
       protected ?string $viewContext = 'tenant';
   }
   ```

4. **Service** (`app/Services/{Entity}Service.php`)
   - extends BaseCrudService
   - Constructor: inject Repository
   - Define $relations
   - Custom business methods if needed

5. **Repository** (`app/Repositories/{Entity}/{Entity}Repository.php`)
   - Query methods

6. **Resource** (`app/Http/Resources/{Entity}/{Entity}Resource.php`)
   - toArray() with field mapping

7. **FormRequest** (`app/Http/Requests/{Entity}/`)
   - SnU{Entity}Request (Store/Update validation)
   - Index{Entity}Request (list filtering)

8. **Providers**
   - {Module}ServiceProvider (copy pattern)
   - PoliciesServiceProvider

9. **Routes** (`routes/tenant.php`)
   - Standard CRUD routes
   - API routes if needed

### Step 4: Generate Frontend

1. **Pages** (`resources/js/vue/tenant/pages/{entity}/`)
   - `Index.vue` — DzDataView table with search, filters, pagination
   - `Create.vue` — DzFormLayoutMain form
   - `Edit.vue` — Same as Create, pre-filled
   - `Show.vue` — Detail view with tabs (DzContentSubMenuLayout)

2. **Composable** (`composables/use{Entity}.ts`)
   - Tab management, data caching

3. **Components** (entity-specific)
   - Header, stats cards, form fields

4. **Locales** — i18n strings

### Step 5: Config Files
- `module.json`
- `composer.json`
- `package.json`
- `modules_statuses.json` update
- `vite.config.js` alias

### Step 6: Verify
```bash
cd datazen && composer dump-autoload && php artisan migrate --pretend && npm run build
```

---

## Target B: chatbot-nestjs (NestJS CRUD API)

### Step 1: Read Patterns

Always read these before generating:
```
- ./knowledge/patterns/nestjs-crud-with-softdelete.md  — REAL entity/DTO/service/controller patterns
- ./knowledge/patterns/laravel-nestjs-proxy.md         — If feature needs inbox/proxy integration
- Scan existing feature in same module for current conventions
```

Example to scan: `src/modules/message-management/` — specifically canned responses and conversation notes.

---

### Step 2: Generate NestJS Backend

#### 2a. Entity (`src/modules/{module}/entities/{feature}.entity.ts`)

Follow this EXACT pattern from canned-responses (real production code):

```typescript
import { Entity, PrimaryGeneratedColumn, Column, Index } from 'typeorm';

@Entity('cb_{feature_snake_plural}')
export class {Feature}Entity {
  @PrimaryGeneratedColumn({ type: 'bigint' })
  id: number;

  @Column({ name: 'subscription_uuid', type: 'varchar', length: 36 })
  subscriptionUuid: string;

  // Business fields — match varchar length to DB schema
  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'content', type: 'text' })
  content: string;

  // Optional business fields
  @Column({ name: 'shortcut', type: 'varchar', length: 50, nullable: true })
  shortcut: string | null;

  @Column({ name: 'category', type: 'varchar', length: 100, nullable: true })
  category: string | null;

  @Column({ name: 'tags', type: 'jsonb', nullable: true })
  tags: string[] | null;

  // Status flag — always present
  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  // Audit trail — ALWAYS include these 5 fields
  @Column({ name: 'created_by', type: 'varchar', length: 255 })
  createdBy: string;

  @Column({ name: 'created_by_name', type: 'varchar', length: 255, nullable: true })
  createdByName: string | null;

  @Column({ name: 'updated_by', type: 'varchar', length: 255, nullable: true })
  updatedBy: string | null;

  // Timestamps: bigint epoch ms — NOT Date objects, NOT TypeORM @CreateDateColumn
  @Column({ name: 'created_at', type: 'bigint' })
  createdAt: number;

  @Column({ name: 'updated_at', type: 'bigint' })
  updatedAt: number;

  // Soft delete: manual bigint column — NOT TypeORM @DeleteDateColumn
  @Column({ name: 'deleted_at', type: 'bigint', nullable: true })
  deletedAt: number | null;
}
```

**Entity RULES (from real code — do not deviate):**
- `@PrimaryGeneratedColumn({ type: 'bigint' })` — bigint PK, no 'increment' option needed
- Timestamps: `bigint` epoch ms via `Date.now()` — never `Date` type, never `@CreateDateColumn`
- Soft delete: manual `deleted_at bigint NULL` — never `@DeleteDateColumn`
- Table prefix: `cb_` for chatbot module
- Partial index in `@Index`: use double-quoted column: `'"deleted_at" IS NULL'`

---

#### 2b. DTOs (`src/modules/{module}/dto/{feature}.dto.ts`)

Follow this EXACT pattern from canned-responses:

```typescript
import {
  IsString, IsNotEmpty, IsOptional, IsArray, IsBoolean,
  MaxLength, Min, Max
} from 'class-validator';
import { Transform } from 'class-transformer';

export class Create{Feature}Dto {
  @IsString()
  @IsNotEmpty()
  subscriptionUuid: string;  // Always MaxLength(36) if strict — VARCHAR(36)

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  title: string;

  @IsString()
  @IsNotEmpty()
  content: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  shortcut?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  category?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @IsString()
  createdBy: string;

  @IsOptional()
  @IsString()
  createdByName?: string;
}

export class Update{Feature}Dto {
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @IsOptional()
  @IsString()
  content?: string;

  // updatedBy is REQUIRED in Update — not optional
  @IsString()
  updatedBy: string;
}

export class List{Feature}Dto {
  @IsString()
  @IsNotEmpty()
  subscriptionUuid: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsString()
  search?: string;

  // Boolean from query string: must use @Transform
  @IsOptional()
  @Transform(({ value }) => value === 'true')
  isActive?: boolean;

  @IsOptional()
  @IsString()
  cursor?: string;

  // Number from query string: must use @Transform
  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @Min(1)
  @Max(50)
  limit?: number;
}
```

**DTO RULES:**
- Boolean from query string: `@Transform(({ value }) => value === 'true')` — not `@IsBoolean` alone
- Number from query string: `@Transform(({ value }) => parseInt(value, 10))` — `@Type(() => Number)` also works
- `updatedBy` REQUIRED in Update DTO (always — audit trail)
- MaxLength must match DB varchar length exactly

---

#### 2c. Service (`src/modules/{module}/services/{feature}.service.ts`)

Follow this EXACT pattern:

```typescript
import { Injectable, ConflictException } from '@nestjs/common';
import { IsNull } from 'typeorm';
import { TenantConnectionPool } from '../../infrastructure/database/tenant-connection-pool';
import { {Feature}Entity } from '../entities/{feature}.entity';
import { Create{Feature}Dto, Update{Feature}Dto, List{Feature}Dto } from '../dto/{feature}.dto';

export interface PaginatedResult<T> {
  data: T[];
  nextCursor: string | null;
  hasMore: boolean;
}

@Injectable()
export class {Feature}Service {
  constructor(private readonly pool: TenantConnectionPool) {}

  async create(
    pool: TenantConnectionPool,
    tenantId: string,
    dto: Create{Feature}Dto,
  ): Promise<{Feature}Entity> {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository({Feature}Entity);
    const now = Date.now();

    // Uniqueness check (when applicable — e.g., shortcut)
    if (dto.shortcut) {
      const existing = await repo.findOne({
        where: {
          subscriptionUuid: dto.subscriptionUuid,
          shortcut: dto.shortcut,
          deletedAt: IsNull(),
        },
      });
      if (existing) throw new ConflictException('Shortcut already exists');
    }

    const entity = repo.create({
      ...dto,
      createdAt: now,
      updatedAt: now,
    });
    return repo.save(entity);
  }

  async list(
    pool: TenantConnectionPool,
    tenantId: string,
    query: List{Feature}Dto,
  ): Promise<PaginatedResult<{Feature}Entity>> {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository({Feature}Entity);
    const limit = query.limit || 20;

    const qb = repo.createQueryBuilder('t')
      .where('t.subscription_uuid = :sub', { sub: query.subscriptionUuid })
      .andWhere('t.deleted_at IS NULL');

    // Optional filters
    if (query.category) {
      qb.andWhere('t.category = :cat', { cat: query.category });
    }
    if (query.isActive !== undefined) {
      qb.andWhere('t.is_active = :active', { active: query.isActive });
    }

    // ILIKE search — ALWAYS escape % and _ to prevent SQL injection
    if (query.search) {
      const safe = query.search.replace(/[%_]/g, '\\$&');
      qb.andWhere(
        '(t.title ILIKE :s OR t.content ILIKE :s)',
        { s: `%${safe}%` }
      );
    }

    // Cursor pagination (id-based, newest first = descending)
    if (query.cursor) {
      const cursorId = parseInt(Buffer.from(query.cursor, 'base64').toString(), 10);
      qb.andWhere('t.id < :cursorId', { cursorId });
    }

    qb.orderBy('t.id', 'DESC').limit(limit + 1);

    const results = await qb.getMany();
    const hasMore = results.length > limit;
    const data = hasMore ? results.slice(0, limit) : results;
    const nextCursor = hasMore
      ? Buffer.from(String(data[data.length - 1].id)).toString('base64')
      : null;

    return { data, nextCursor, hasMore };
  }

  async update(
    pool: TenantConnectionPool,
    tenantId: string,
    id: number,
    subscriptionUuid: string,
    dto: Update{Feature}Dto,
  ): Promise<{Feature}Entity | null> {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository({Feature}Entity);

    const entity = await repo.findOne({
      where: { id, subscriptionUuid, deletedAt: IsNull() },
    });
    if (!entity) return null;

    // Only update fields that are provided (undefined = keep existing)
    if (dto.title !== undefined) entity.title = dto.title;
    if (dto.content !== undefined) entity.content = dto.content;
    // ... other fields
    entity.updatedBy = dto.updatedBy;
    entity.updatedAt = Date.now();

    return repo.save(entity);
  }

  async softDelete(
    pool: TenantConnectionPool,
    tenantId: string,
    id: number,
    subscriptionUuid: string,
  ): Promise<boolean> {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository({Feature}Entity);

    // Update both deletedAt AND updatedAt
    const result = await repo.update(
      { id, subscriptionUuid, deletedAt: IsNull() },
      { deletedAt: Date.now(), updatedAt: Date.now() },
    );
    return (result.affected ?? 0) > 0;
  }
}
```

**Service RULES (from real code):**
- Always `pool.getConnection(tenantId)` — correct tenant DB
- Always filter by `subscriptionUuid` — cross-subscription isolation
- Always filter `deletedAt: IsNull()` or `t.deleted_at IS NULL`
- ILIKE search: escape `%` and `_` with `replace(/[%_]/g, '\\$&')`
- Cursor: base64-encoded `id` value — decode with `Buffer.from(cursor, 'base64').toString()`
- Pagination: fetch `limit + 1`, `results.length > limit` means has more
- Soft delete: set BOTH `deletedAt` AND `updatedAt`
- Update: only assign fields where value is not `undefined`

---

#### 2d. Controller (`src/modules/{module}/controllers/{feature}.controller.ts`)

Follow this EXACT pattern:

```typescript
import {
  Controller, Get, Post, Patch, Delete,
  Param, Query, Body, ParseIntPipe, NotFoundException
} from '@nestjs/common';
import { {Feature}Service } from '../services/{feature}.service';
import { TenantConnectionPool } from '../../infrastructure/database/tenant-connection-pool';
import {
  Create{Feature}Dto, Update{Feature}Dto, List{Feature}Dto
} from '../dto/{feature}.dto';

@Controller('api/v1/internal/messages/:tenantId/{feature-kebab-plural}')
export class {Feature}Controller {
  constructor(
    private readonly service: {Feature}Service,
    private readonly pool: TenantConnectionPool,
  ) {}

  @Get()
  async list(
    @Param('tenantId') tenantId: string,
    @Query() query: List{Feature}Dto,
  ) {
    return this.service.list(this.pool, tenantId, query);
  }

  @Post()
  async create(
    @Param('tenantId') tenantId: string,
    @Body() dto: Create{Feature}Dto,
  ) {
    return this.service.create(this.pool, tenantId, dto);
  }

  @Patch(':id')
  async update(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,
    @Query('subscriptionUuid') subscriptionUuid: string,
    @Body() dto: Update{Feature}Dto,
  ) {
    const result = await this.service.update(this.pool, tenantId, id, subscriptionUuid, dto);
    if (!result) throw new NotFoundException('{Feature} not found');
    return result;
  }

  @Delete(':id')
  async remove(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,
    @Query('subscriptionUuid') subscriptionUuid: string,
  ) {
    const success = await this.service.softDelete(this.pool, tenantId, id, subscriptionUuid);
    if (!success) throw new NotFoundException('{Feature} not found');
    return { success: true };
  }
}
```

**Controller RULES:**
- Route: `api/v1/internal/messages/:tenantId/{feature-kebab-plural}`
- `ParseIntPipe` on all numeric `@Param` — prevents string IDs silently failing
- `subscriptionUuid` in `@Query` for update/delete — scopes ownership without PUT to wrong resource
- Response for delete: `{ success: true }` (not 204 — NestJS default is 200)
- Response for list: service returns `{ data, nextCursor, hasMore }` — pass through as-is

---

#### 2e. Migration SQL (`database_structures/migrations/{feature}_setup.sql`)

Exact pattern from canned responses:

```sql
-- Create table
CREATE TABLE IF NOT EXISTS cb_{feature_snake_plural} (
    id                BIGSERIAL PRIMARY KEY,
    subscription_uuid VARCHAR(36) NOT NULL,

    -- Business fields (customize per entity)
    title             VARCHAR(255) NOT NULL,
    content           TEXT NOT NULL,
    shortcut          VARCHAR(50),
    category          VARCHAR(100),
    tags              JSONB,

    -- Standard status + audit fields (always include)
    is_active         BOOLEAN NOT NULL DEFAULT true,
    created_by        VARCHAR(255) NOT NULL,
    created_by_name   VARCHAR(255),
    updated_by        VARCHAR(255),
    created_at        BIGINT NOT NULL,
    updated_at        BIGINT NOT NULL,
    deleted_at        BIGINT
);

-- Standard indexes (always include these)
CREATE INDEX idx_{short}_sub
  ON cb_{feature_snake_plural} (subscription_uuid);

CREATE INDEX idx_{short}_sub_active
  ON cb_{feature_snake_plural} (subscription_uuid, is_active)
  WHERE deleted_at IS NULL;

-- Unique constraint (only if entity has unique field per subscription)
-- Partial index excludes soft-deleted rows
CREATE UNIQUE INDEX idx_{short}_unique_shortcut
  ON cb_{feature_snake_plural} (subscription_uuid, shortcut)
  WHERE deleted_at IS NULL;
```

---

#### 2f. Registration (CRITICAL — miss any = broken at runtime)

All 6 steps required:

1. `src/modules/{module}/entities/index.ts` — add barrel export for new entity
2. `src/modules/{module}/dto/index.ts` — add barrel exports for new DTOs
3. `src/modules/{module}/services/index.ts` — add barrel export for new service
4. `src/modules/{module}/{module}.module.ts` — register controller in `controllers[]`, service in `providers[]` AND `exports[]`
5. `src/infrastructure/database/tenant/entities/index.ts` — import entity + add to `TenantEntities[]` array
6. `database_structures/migrations/` — place SQL migration file here

---

### Step 3: Generate Datazen Proxy Layer (if inbox/proxy integration needed)

Follow `knowledge/patterns/laravel-nestjs-proxy.md` exactly.

#### 3a. API Service method additions (`Modules/ChatBot/app/Services/ChatBot/MessageManagementApiService.php`)

```php
// Safe read (list) — returns empty array on NestJS failure
public function list{Feature}sSafe(string $tenantId, array $params): array
{
    try {
        $response = $this->apiClient->get(
            "/api/v1/internal/messages/{$tenantId}/{feature-kebab-plural}",
            $params
        );
        return $response->json();
    } catch (\Exception $e) {
        Log::warning("Failed to list {features}", ['error' => $e->getMessage()]);
        return ['data' => [], 'nextCursor' => null, 'hasMore' => false];
    }
}

// Safe read (single item)
public function get{Feature}Safe(string $tenantId, int $id, string $subscriptionUuid): ?array
{
    try {
        $response = $this->apiClient->get(
            "/api/v1/internal/messages/{$tenantId}/{feature-kebab-plural}/{$id}",
            ['subscriptionUuid' => $subscriptionUuid]
        );
        return $response->json();
    } catch (\Exception $e) {
        Log::warning("Failed to get {feature}", ['id' => $id, 'error' => $e->getMessage()]);
        return null;
    }
}

// Strict write — throws on failure
public function create{Feature}(string $tenantId, array $data): array
{
    $response = $this->apiClient->post(
        "/api/v1/internal/messages/{$tenantId}/{feature-kebab-plural}",
        $data
    );
    return $response->json();
}

public function update{Feature}(string $tenantId, int $id, string $subscriptionUuid, array $data): array
{
    $response = $this->apiClient->patch(
        "/api/v1/internal/messages/{$tenantId}/{feature-kebab-plural}/{$id}",
        array_merge($data, ['subscriptionUuid' => $subscriptionUuid])
    );
    return $response->json();
}

public function delete{Feature}(string $tenantId, int $id, string $subscriptionUuid): bool
{
    $this->apiClient->delete(
        "/api/v1/internal/messages/{$tenantId}/{feature-kebab-plural}/{$id}",
        ['subscriptionUuid' => $subscriptionUuid]
    );
    return true;
}
```

#### 3b. Routes (`Modules/ChatBot/routes/tenant.php`)

Add to existing inbox route group or create new group:

```php
Route::prefix('{subscription}/app/chatbot/{feature-kebab}')->group(function () {
    Route::get('/', [{Feature}Controller::class, 'index'])->name('chatbot.{feature}');
    Route::get('/list', [{Feature}Controller::class, 'apiList']);
    Route::post('/', [{Feature}Controller::class, 'apiCreate']);
    Route::patch('/{id}', [{Feature}Controller::class, 'apiUpdate']);
    Route::delete('/{id}', [{Feature}Controller::class, 'apiDelete']);
});
```

#### 3c. Controller proxy methods

```php
public function apiCreate{Feature}(Request $request, string $subscription): JsonResponse
{
    $tenantId = tenant('id');
    $result = $this->apiService->create{Feature}($tenantId, array_merge(
        $request->validated(),
        [
            'subscriptionUuid' => $subscription,
            // Always populate audit fields from auth
            'createdBy'     => (string) auth()->id(),
            'createdByName' => auth()->user()?->name,
        ]
    ));
    return response()->json($result);
}

public function apiUpdate{Feature}(Request $request, string $subscription, int $id): JsonResponse
{
    $tenantId = tenant('id');
    $result = $this->apiService->update{Feature}($tenantId, $id, $subscription, array_merge(
        $request->validated(),
        ['updatedBy' => (string) auth()->id()]
    ));
    return response()->json($result);
}
```

#### 3d. Vue Composable additions (`use{Feature}Api.ts` or extend `useInboxApi.ts`)

```typescript
// Add to composable
async function list{Feature}s(params: Record<string, unknown> = {}): Promise<{
  data: {Feature}Item[];
  nextCursor: string | null;
  hasMore: boolean;
}> {
  const { data } = await axios.get(`/${subscription}/app/chatbot/{feature-kebab}/list`, { params });
  return data;
}

async function create{Feature}(payload: Create{Feature}Payload): Promise<{Feature}Item> {
  const { data } = await axios.post(`/${subscription}/app/chatbot/{feature-kebab}`, payload);
  return data.data;
}

async function update{Feature}(id: number, payload: Partial<Create{Feature}Payload>): Promise<{Feature}Item> {
  const { data } = await axios.patch(`/${subscription}/app/chatbot/{feature-kebab}/${id}`, payload);
  return data.data;
}

async function delete{Feature}(id: number): Promise<void> {
  await axios.delete(`/${subscription}/app/chatbot/{feature-kebab}/${id}`);
}
```

#### 3e. Vue CRUD Dialog pattern (for Inbox integration)

When adding a CRUD dialog to an existing page (e.g., canned responses picker in Inbox):

```vue
<!-- In the parent page SFC -->
<script setup lang="ts">
// Dialog state
const showCrudDialog = ref(false);
const editingItem = ref<{Feature}Item | null>(null);

function openCreate() {
  editingItem.value = null;
  showCrudDialog.value = true;
}

function openEdit(item: {Feature}Item) {
  editingItem.value = { ...item };
  showCrudDialog.value = true;
}

async function handleSave(formData: Partial<{Feature}Item>) {
  if (editingItem.value?.id) {
    await api.update{Feature}(editingItem.value.id, formData);
  } else {
    await api.create{Feature}(formData);
  }
  showCrudDialog.value = false;
  await refreshList();
}

async function handleDelete(item: {Feature}Item) {
  if (!confirm(`Delete "${item.title}"?`)) return;
  await api.delete{Feature}(item.id);
  await refreshList();
}
</script>

<template>
  <!-- Dialog via Teleport (prevents z-index stacking issues in complex layouts) -->
  <Teleport to="body">
    <div
      v-if="showCrudDialog"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
      @click.self="showCrudDialog = false"
    >
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-xl w-full max-w-lg mx-4">
        <div class="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
            {{ editingItem ? 'Edit {Feature}' : 'New {Feature}' }}
          </h2>
          <button @click="showCrudDialog = false" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200">
            <PhX :size="20" />
          </button>
        </div>
        <form @submit.prevent="handleSave(form)" class="p-6 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Title</label>
            <input
              v-model="form.title"
              type="text"
              required
              class="w-full px-3 py-2 border border-gray-200 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-900 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:outline-none"
            />
          </div>
          <!-- more fields -->
          <div class="flex justify-end gap-3 pt-2">
            <button type="button" @click="showCrudDialog = false" class="px-4 py-2 text-sm text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white">
              Cancel
            </button>
            <button type="submit" class="px-4 py-2 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors">
              {{ editingItem ? 'Save' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>
```

### Step 4: Verify

```bash
cd chatbot-nestjs && pnpm run build && pnpm test
```

If inbox/proxy integration:
```bash
cd datazen && npm run build
```

---

## Output

### Target A (datazen)
- Backend: Model, Migration, Controller, Service, Repository, Resource, Requests, Providers, Routes
- Frontend: CRUD pages, composable, components
- Config: module registration files
- Build clean

### Target B (chatbot-nestjs)
- Backend: Entity, DTOs, Service, Controller, Migration SQL
- Registration: all 6 barrel/module registration steps done
- Proxy (if needed): API Service methods, Routes, Controller proxy methods, Vue composable methods
- Vue CRUD dialog (if inbox integration): Teleport-based dialog pattern
- Build clean

---

## Quality Checks — Target A (datazen)

- [ ] Model extends BaseModelAbstract, has HasSubscriptionScope
- [ ] Controller extends CoreController, properties set correctly
- [ ] Service extends BaseCrudService, constructor correct
- [ ] Migration has subscription_uuid foreign key
- [ ] Naming: {Prefix}{Entity} model, {module}_{entities} table
- [ ] Routes scoped with subscription + middleware
- [ ] Vue pages use `<script setup lang="ts">`
- [ ] FormRequest validation rules match fields
- [ ] composer.json PSR-4 autoload correct

## Quality Checks — Target B (chatbot-nestjs)

### Entity
- [ ] `@PrimaryGeneratedColumn({ type: 'bigint' })` — bigint PK
- [ ] Timestamps are `bigint` type (number in TS) — NOT Date
- [ ] Soft delete is manual `deletedAt: number | null` — NOT `@DeleteDateColumn`
- [ ] Table name starts with `cb_`

### DTOs
- [ ] Boolean query params use `@Transform(({ value }) => value === 'true')`
- [ ] Number query params use `@Transform(({ value }) => parseInt(value, 10))`
- [ ] `updatedBy` REQUIRED (not optional) in Update DTO
- [ ] MaxLength matches DB varchar length on all string fields

### Service
- [ ] All queries filter `subscriptionUuid` — cross-subscription isolation
- [ ] All queries filter `deleted_at IS NULL` or `deletedAt: IsNull()`
- [ ] ILIKE search escapes `%` and `_` with `replace(/[%_]/g, '\\$&')`
- [ ] Cursor decoded via `Buffer.from(cursor, 'base64').toString()`
- [ ] Soft delete sets BOTH `deletedAt` AND `updatedAt`
- [ ] Update only assigns fields where value is not `undefined`
- [ ] Timestamps set via `Date.now()`

### Controller
- [ ] Route pattern: `api/v1/internal/messages/:tenantId/{feature-kebab-plural}`
- [ ] `ParseIntPipe` on all numeric `@Param`
- [ ] Delete returns `{ success: true }`
- [ ] List returns service result directly (already has `{ data, nextCursor, hasMore }` shape)

### Registration (all 6 required)
- [ ] Entity in `entities/index.ts` barrel
- [ ] DTOs in `dto/index.ts` barrel
- [ ] Service in `services/index.ts` barrel
- [ ] Controller in `{module}.module.ts` controllers[]
- [ ] Service in `{module}.module.ts` providers[] AND exports[]
- [ ] Entity in `src/infrastructure/database/tenant/entities/index.ts` TenantEntities[]
- [ ] Migration SQL in `database_structures/migrations/`

### Proxy Integration (if applicable)
- [ ] API service read methods are "safe" (catch + return empty)
- [ ] API service write methods are "strict" (let exceptions propagate)
- [ ] Laravel controller populates `createdBy` from `auth()->id()`
- [ ] Laravel controller populates `createdByName` from `auth()->user()->name`
- [ ] Laravel controller populates `updatedBy` from `auth()->id()` on update
- [ ] `subscriptionUuid` taken from route param — not from request body
- [ ] `tenantId` resolved via `tenant('id')` in Laravel controller

### Vue (if applicable)
- [ ] `<script setup lang="ts">` — always
- [ ] Phosphor icons from `@phosphor-icons/vue`
- [ ] Tailwind dark mode classes paired on all elements
- [ ] Dialog uses `<Teleport to="body">`
- [ ] Form state reset when switching create vs edit
- [ ] Delete has confirmation prompt before calling API
