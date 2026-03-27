---
name: crud-generator
description: "Sinh toàn bộ CRUD module/feature mới. Supports 2 targets: (A) datazen Laravel module — full CRUD with UI, (B) chatbot-nestjs NestJS API — backend CRUD with proxy integration. Input: target + entity name + fields. Output: complete implementation per target."
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# CRUD Generator Agent

Bạn là code generator agent. Bạn tạo CRUD modules/features mới dựa trên documented conventions.

## Input (nhận từ Lead)

- **Target**: `datazen` (Laravel module with UI) hoặc `chatbot-nestjs` (NestJS API)
- **Module name**: Tên module (VD: "Inventory", "MessageManagement")
- **Module prefix**: Viết tắt (VD: "Inv", "Cb")
- **Entity name**: Entity chính (VD: "Product", "CannedResponse")
- **Fields**: Danh sách fields với types
- **Relationships**: Relations với modules khác
- **Features**: Soft deletes? Media? Webhooks? Cursor pagination? Inbox integration?

---

## Target A: datazen (Laravel Module)

### Step 1: Đọc Pattern
```
Đọc:
- ./knowledge/patterns/datazen-module.md — Standard CRUD module pattern
- Scan 1 module tương tự trong Modules/ (VD: CRM cho reference)
```

### Step 2: Scan Base Classes
```
Đọc base classes để hiểu hooks available:
- packages/laravel-crud-foundation/ — BaseCrudAbstract, BaseCrudService, BaseModelAbstract
```

### Step 3: Generate Backend

1. **Model** (`app/Models/{Prefix}{Entity}.php`)
   ```php
   class {Prefix}{Entity} extends BaseModelAbstract
   {
       use HasSubscriptionScope;
       // + SoftDeletes, WebhookableTrait nếu requested

       protected $table = '{module}_{entities}';
       protected $fillable = [...fields];
       protected function casts(): array { ... }
       // Relationships
   }
   ```

2. **Migration** (`database/migrations/`)
   - subscription_uuid + foreign key
   - Fields từ input
   - Indexes cho frequently queried fields
   - timestamps() + softDeletes() nếu needed

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
   - Custom business methods nếu needed

5. **Repository** (`app/Repositories/{Entity}/{Entity}Repository.php`)
   - Query methods

6. **Resource** (`app/Http/Resources/{Entity}/{Entity}Resource.php`)
   - toArray() với field mapping

7. **FormRequest** (`app/Http/Requests/{Entity}/`)
   - SnU{Entity}Request (Store/Update validation)
   - Index{Entity}Request (list filtering)

8. **Providers**
   - {Module}ServiceProvider (copy pattern)
   - PoliciesServiceProvider

9. **Routes** (`routes/tenant.php`)
   - Standard CRUD routes
   - API routes nếu needed

### Step 4: Generate Frontend

1. **Pages** (`resources/js/vue/tenant/pages/{entity}/`)
   - `Index.vue` — DzDataView table với search, filters, pagination
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

### Step 1: Đọc Pattern
```
Đọc:
- ./knowledge/patterns/nestjs-crud-api.md — NestJS CRUD API pattern (Sprint 1 learnings)
- ./knowledge/patterns/inbox-feature.md — If feature integrates into datazen inbox
- Scan existing feature in same module for conventions
```

### Step 2: Generate NestJS Backend

#### 2a. Entity (`src/modules/{module}/entities/{feature}.entity.ts`)

```typescript
import { Entity, PrimaryGeneratedColumn, Column, Index } from 'typeorm';

@Entity('cb_{feature_snake_plural}')
@Index('idx_{short}_{composite}', ['field1', 'field2'], {
  where: '"deleted_at" IS NULL',  // MUST double-quote column name
})
export class {Feature}Entity {
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id!: number;

  @Column({ name: 'subscription_uuid', type: 'varchar', length: 36 })
  @Index('idx_{short}_sub')
  subscriptionUuid!: string;

  // Feature fields...

  // Audit fields (STANDARD — always include)
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

**Entity RULES:**
- PK: `bigint` with `@PrimaryGeneratedColumn('increment', { type: 'bigint' })`
- Timestamps: `bigint` (unix ms), set with `Date.now()`
- Soft delete: `deleted_at bigint NULL`
- Table prefix: `cb_`
- Partial index `where`: double-quoted column — `'"deleted_at" IS NULL'`

#### 2b. DTOs (`src/modules/{module}/dto/{feature}.dto.ts`)

```typescript
import { IsString, IsNotEmpty, IsOptional, IsBoolean, MaxLength } from 'class-validator';
import { Type, Transform } from 'class-transformer';

export class Create{Feature}Dto {
  @IsString() @IsNotEmpty() @MaxLength(36)
  subscriptionUuid!: string;

  @IsString() @IsNotEmpty() @MaxLength(255)    // MUST match varchar(255)
  title!: string;

  @IsString() @IsNotEmpty() @MaxLength(10000)  // TEXT: reasonable app max
  content!: string;

  @IsString() @IsNotEmpty() @MaxLength(255)
  createdBy!: string;

  @IsOptional() @IsString() @MaxLength(255)
  createdByName?: string;
}

export class Update{Feature}Dto {
  @IsOptional() @IsString() @MaxLength(255)
  title?: string;

  @IsOptional() @IsString() @MaxLength(10000)
  content?: string;

  @IsString() @IsNotEmpty() @MaxLength(255)
  updatedBy!: string;
}

export class {Feature}ListQueryDto {
  @IsString() @IsNotEmpty() @MaxLength(36)
  subscriptionUuid!: string;

  @IsOptional() @IsString()
  search?: string;

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  isActive?: boolean;

  @IsOptional() @IsString()
  cursor?: string;

  @IsOptional() @Type(() => Number) @IsNumber()
  limit?: number;
}
```

**DTO RULES:**
- `MaxLength(36)` on subscriptionUuid — ALWAYS
- `MaxLength(255)` on ALL varchar(255) fields — MUST match DB
- `MaxLength(10000)` on TEXT fields — reasonable app-level limit
- Boolean from query string: `@Transform(({ value }) => value === 'true' || value === true)`
- Cursor: string in DTO, validate numeric in service
- updatedBy: REQUIRED in Update DTO (not optional)

#### 2c. Service (`src/modules/{module}/services/{feature}.service.ts`)

```typescript
@Injectable()
export class {Feature}Service {
  constructor(private readonly pool: TenantConnectionPool) {}

  async list(tenantId: string, query: ...): Promise<...> {
    const ds = await this.pool.get(tenantId);
    const limit = Math.min(query.limit ?? 20, 50);

    const qb = ds.getRepository({Feature}Entity)
      .createQueryBuilder('t')
      .where('t.subscription_uuid = :subscriptionUuid', { subscriptionUuid: query.subscriptionUuid })
      .andWhere('t.deleted_at IS NULL');

    // ILIKE search — MUST escape % and _
    if (query.search) {
      const escaped = query.search.replace(/%/g, '\\%').replace(/_/g, '\\_');
      qb.andWhere('(t.title ILIKE :search OR t.content ILIKE :search)', { search: `%${escaped}%` });
    }

    // Cursor — MUST validate numeric
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
    const nextCursor = hasMore && data.length > 0 ? String(data[data.length - 1].id) : null;
    return { data, nextCursor, hasMore };
  }
}
```

**Service RULES:**
- ALWAYS `await this.pool.get(tenantId)` for correct tenant DB
- ALWAYS filter by subscriptionUuid — prevents cross-subscription data leak
- ALWAYS filter `deleted_at IS NULL`
- ILIKE: escape `%` and `_` — `query.search.replace(/%/g, '\\%').replace(/_/g, '\\_')`
- Cursor: `isNaN(Number(cursor))` check, throw 400 if invalid
- Pagination: fetch `limit + 1`, check `results.length > limit` for hasMore
- Timestamps: `Date.now()` (unix ms)
- Update: only set fields where `data.field !== undefined`

#### 2d. Controller (`src/modules/{module}/controllers/{feature}.controller.ts`)

```typescript
@Controller('internal/messages')
@Public()
@SkipTenantCheck()
export class {Feature}Controller {
  constructor(
    private readonly cls: ClsService,
    private readonly service: {Feature}Service,
  ) {}

  private setTenantContext(tenantId: string): void {
    this.cls.set('tenantId', tenantId);
  }

  @Get(':tenantId/{feature-kebab-plural}')
  async list(@Param('tenantId') tenantId: string, @Query() query: ...) {
    this.setTenantContext(tenantId);  // MUST call before ANY DB operation
    return this.service.list(tenantId, ...);
  }
  // ... CRUD endpoints
}
```

**Controller RULES:**
- `@Public()` + `@SkipTenantCheck()` — internal API
- `setTenantContext(tenantId)` BEFORE every handler — CRITICAL
- `ParseIntPipe` on all numeric route params
- Error pattern: re-throw HttpException, wrap unknown with 500
- Response: `{ data: entity }` for items, `{ data: [], nextCursor, hasMore }` for lists, `{ success: true }` for deletes

#### 2e. Migration SQL (`database_structures/migrations/{feature}_setup.sql`)

```sql
CREATE TABLE IF NOT EXISTS cb_{feature_snake_plural} (
  id                BIGSERIAL PRIMARY KEY,
  subscription_uuid VARCHAR(36) NOT NULL,
  -- fields --
  created_by        VARCHAR(255) NOT NULL,
  created_by_name   VARCHAR(255),
  updated_by        VARCHAR(255),
  created_at        BIGINT NOT NULL,
  updated_at        BIGINT NOT NULL,
  deleted_at        BIGINT
);

-- Indexes (MUST match entity @Index decorators)
CREATE INDEX IF NOT EXISTS idx_{short}_sub ON cb_{feature_snake_plural} (subscription_uuid);

-- Partial indexes: WHERE deleted_at IS NULL
CREATE INDEX IF NOT EXISTS idx_{short}_{name}
  ON cb_{feature_snake_plural} (field1, field2)
  WHERE deleted_at IS NULL;
```

#### 2f. Registration (CRITICAL — miss any = broken)

1. `entities/index.ts` — barrel export new entity
2. `dto/index.ts` — barrel export new DTOs
3. `services/index.ts` — barrel export new service
4. `{module}.module.ts` — register controller in `controllers[]`, service in `providers[]` + `exports[]`
5. `src/infrastructure/database/tenant/entities/index.ts` — import entity + add to `TenantEntities[]`
6. `database_structures/migrations/` — create SQL file

### Step 3: Generate Datazen Proxy (if inbox integration)

If feature needs inbox integration, follow `./knowledge/patterns/inbox-feature.md`:

1. **Routes** (`datazen/Modules/ChatBot/routes/tenant.php`) — add to inbox API group
2. **Controller** (`InboxController.php`) — add proxy methods
3. **API Service** (`MessageManagementApiService.php`) — add HTTP methods
4. **Composable** (`useInboxApi.ts`) — add API call methods
5. **Vue** (`Index.vue`) — integrate picker/tab/notification

### Step 4: Verify

```bash
cd chatbot-nestjs && pnpm run build && pnpm test
```

If inbox integration:
```bash
cd datazen && npm run build
```

---

## Output

### Target A (datazen)
- Backend: Model, Migration, Controller, Service, Repository, Resource, Requests, Providers, Routes
- Frontend: 4 CRUD pages, composable, components
- Config: module registration files
- Build clean

### Target B (chatbot-nestjs)
- Backend: Entity, DTOs, Service, Controller, Migration SQL
- Registration: barrel exports, module registration, TenantEntities array
- Proxy (if inbox): Routes, Controller methods, API Service methods, Composable methods
- Build clean

---

## Quality Checks — Target A (datazen)

- [ ] Model extends BaseModelAbstract, has HasSubscriptionScope
- [ ] Controller extends CoreController, properties set correctly
- [ ] Service extends BaseCrudService, constructor correct
- [ ] Migration has subscription_uuid foreign key
- [ ] Naming: {Prefix}{Entity} model, {module}_{entities} table
- [ ] Routes scoped with subscription + middleware
- [ ] Vue pages use script setup + TypeScript
- [ ] FormRequest validation rules match fields
- [ ] composer.json PSR-4 autoload correct

## Quality Checks — Target B (chatbot-nestjs)

### Security
- [ ] subscriptionUuid filter in ALL list queries (cross-subscription isolation)
- [ ] MaxLength(36) on subscriptionUuid in DTOs
- [ ] MaxLength matching varchar length on ALL string DTO fields
- [ ] deleted_at IS NULL in ALL queries (soft delete isolation)

### Tenant Context
- [ ] setTenantContext(tenantId) called BEFORE every DB operation in controller
- [ ] @Public() + @SkipTenantCheck() on controller class

### Data Integrity
- [ ] ILIKE search escapes % and _ characters
- [ ] Cursor validated with isNaN check, throws 400 if non-numeric
- [ ] Boolean query params use @Transform for string-to-boolean coercion
- [ ] Timestamps use Date.now() (unix ms bigint)
- [ ] Update only sets fields where value !== undefined
- [ ] Soft delete sets both deletedAt and updatedAt

### Indexes
- [ ] Entity @Index where clause matches migration SQL exactly
- [ ] Partial index uses double-quoted column: '"deleted_at" IS NULL'
- [ ] subscription_uuid has its own index

### Registration
- [ ] Entity in entities/index.ts barrel
- [ ] DTOs in dto/index.ts barrel
- [ ] Service in services/index.ts barrel
- [ ] Controller in module.ts controllers array
- [ ] Service in module.ts providers + exports arrays
- [ ] Entity in TenantEntities array (infrastructure/database/tenant/entities/index.ts)
- [ ] Migration SQL in database_structures/migrations/

### Proxy Integration (if applicable)
- [ ] Laravel routes added with correct naming convention
- [ ] Controller proxy methods use tenant('id') and subscription from route
- [ ] API service methods use correct NestJS endpoint paths
- [ ] Vue composable methods follow existing patterns
- [ ] createdBy/updatedBy populated from auth()->id()
- [ ] createdByName populated from auth()->user()->name
