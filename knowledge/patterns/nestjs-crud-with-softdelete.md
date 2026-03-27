# Pattern: NestJS CRUD Module with Soft Delete + Cursor Pagination

Extracted from: Message Management — Canned Responses + Conversation Notes (2026-03-27)
Project: chatbot-nestjs

---

## Overview

Standard CRUD module in the chatbot-nestjs multi-tenant architecture:
- TypeORM entities with soft delete (deleted_at timestamp, not TypeORM @DeleteDateColumn)
- Cursor-based pagination (id-based, newest first)
- Multi-tenant isolation via subscription_uuid
- DTOs with class-validator
- Service layer handles all business logic

## File Structure

```
src/modules/{module-name}/
├── controllers/
│   └── {feature}.controller.ts          # HTTP endpoints
├── services/
│   └── {feature}.service.ts             # Business logic
├── entities/
│   └── {feature}.entity.ts              # TypeORM entity
├── dto/
│   └── {feature}.dto.ts                 # Request/response DTOs
```

## Entity Pattern

```typescript
@Entity('cb_{table_name}')
export class CannedResponseEntity {
  @PrimaryGeneratedColumn({ type: 'bigint' })
  id: number;

  @Column({ name: 'subscription_uuid', type: 'varchar', length: 36 })
  subscriptionUuid: string;

  // ... business fields ...

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ name: 'created_by', type: 'varchar', length: 255 })
  createdBy: string;

  @Column({ name: 'created_by_name', type: 'varchar', length: 255, nullable: true })
  createdByName: string;

  @Column({ name: 'updated_by', type: 'varchar', length: 255, nullable: true })
  updatedBy: string;

  @Column({ name: 'created_at', type: 'bigint' })
  createdAt: number;  // epoch ms

  @Column({ name: 'updated_at', type: 'bigint' })
  updatedAt: number;  // epoch ms

  @Column({ name: 'deleted_at', type: 'bigint', nullable: true })
  deletedAt: number | null;  // soft delete — NOT using TypeORM @DeleteDateColumn
}
```

Key: Timestamps are `bigint` epoch milliseconds, NOT Date objects. Soft delete is manual `deleted_at` column.

## DTO Pattern

```typescript
export class CreateCannedResponseDto {
  @IsString()
  @IsNotEmpty()
  subscriptionUuid: string;

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

export class ListCannedResponseDto {
  @IsString()
  @IsNotEmpty()
  subscriptionUuid: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Transform(({ value }) => value === 'true')
  isActive?: boolean;

  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @Transform(({ value }) => parseInt(value, 10))
  @Min(1)
  @Max(50)
  limit?: number;
}
```

## Service Pattern

```typescript
@Injectable()
export class CannedResponseService {
  async create(
    pool: TenantConnectionPool,
    tenantId: string,
    dto: CreateCannedResponseDto,
  ) {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository(CannedResponseEntity);
    const now = Date.now();

    // Uniqueness check (if applicable)
    if (dto.shortcut) {
      const existing = await repo.findOne({
        where: {
          subscriptionUuid: dto.subscriptionUuid,
          shortcut: dto.shortcut,
          deletedAt: IsNull(),  // exclude soft-deleted
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
    query: ListCannedResponseDto,
  ): Promise<PaginatedResult<CannedResponseEntity>> {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository(CannedResponseEntity);
    const limit = query.limit || 20;

    const qb = repo.createQueryBuilder('cr')
      .where('cr.subscription_uuid = :sub', { sub: query.subscriptionUuid })
      .andWhere('cr.deleted_at IS NULL');

    // Filters
    if (query.category) {
      qb.andWhere('cr.category = :cat', { cat: query.category });
    }
    if (query.search) {
      const safe = query.search.replace(/[%_]/g, '\\$&');
      qb.andWhere('(cr.title ILIKE :s OR cr.content ILIKE :s OR cr.shortcut ILIKE :s)',
        { s: `%${safe}%` });
    }
    if (query.isActive !== undefined) {
      qb.andWhere('cr.is_active = :active', { active: query.isActive });
    }

    // Cursor pagination (id-based, newest first)
    if (query.cursor) {
      const cursorId = parseInt(Buffer.from(query.cursor, 'base64').toString(), 10);
      qb.andWhere('cr.id < :cursorId', { cursorId });
    }

    qb.orderBy('cr.id', 'DESC').limit(limit + 1);

    const results = await qb.getMany();
    const hasMore = results.length > limit;
    const data = hasMore ? results.slice(0, limit) : results;
    const nextCursor = hasMore
      ? Buffer.from(String(data[data.length - 1].id)).toString('base64')
      : null;

    return { data, nextCursor, hasMore };
  }

  async softDelete(
    pool: TenantConnectionPool,
    tenantId: string,
    id: number,
    subscriptionUuid: string,
  ): Promise<boolean> {
    const conn = await pool.getConnection(tenantId);
    const repo = conn.getRepository(CannedResponseEntity);

    const result = await repo.update(
      { id, subscriptionUuid, deletedAt: IsNull() },
      { deletedAt: Date.now(), updatedAt: Date.now() },
    );
    return result.affected > 0;
  }
}
```

## Controller Pattern

```typescript
@Controller('api/v1/internal/messages/:tenantId/canned-responses')
export class CannedResponseController {
  constructor(
    private readonly service: CannedResponseService,
    private readonly pool: TenantConnectionPool,
  ) {}

  @Get()
  async list(@Param('tenantId') tenantId: string, @Query() query: ListCannedResponseDto) {
    return this.service.list(this.pool, tenantId, query);
  }

  @Post()
  async create(@Param('tenantId') tenantId: string, @Body() dto: CreateCannedResponseDto) {
    return this.service.create(this.pool, tenantId, dto);
  }

  @Patch(':id')
  async update(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,
    @Query('subscriptionUuid') subscriptionUuid: string,
    @Body() dto: UpdateCannedResponseDto,
  ) {
    return this.service.update(this.pool, tenantId, id, subscriptionUuid, dto);
  }

  @Delete(':id')
  async remove(
    @Param('tenantId') tenantId: string,
    @Param('id', ParseIntPipe) id: number,
    @Query('subscriptionUuid') subscriptionUuid: string,
  ) {
    return this.service.softDelete(this.pool, tenantId, id, subscriptionUuid);
  }
}
```

## Migration SQL Pattern

```sql
CREATE TABLE IF NOT EXISTS cb_{table_name} (
    id BIGSERIAL PRIMARY KEY,
    subscription_uuid VARCHAR(36) NOT NULL,
    -- business columns --
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by VARCHAR(255) NOT NULL,
    created_by_name VARCHAR(255),
    updated_by VARCHAR(255),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    deleted_at BIGINT
);

-- Standard indexes
CREATE INDEX idx_{table}_sub ON cb_{table_name} (subscription_uuid);
CREATE INDEX idx_{table}_sub_active ON cb_{table_name} (subscription_uuid, is_active);

-- Unique constraint excluding soft-deleted
CREATE UNIQUE INDEX idx_{table}_unique_field
  ON cb_{table_name} (subscription_uuid, unique_field)
  WHERE deleted_at IS NULL;
```

## Conventions

1. **Table prefix**: `cb_` for chatbot module
2. **Timestamps**: `bigint` epoch ms via `Date.now()`
3. **Soft delete**: Manual `deleted_at` column, all queries add `WHERE deleted_at IS NULL`
4. **Pagination**: Cursor-based, id DESC, base64-encoded cursor
5. **Search**: ILIKE with wildcard-safe escaping (`%` and `_`)
6. **Multi-tenant**: All queries filtered by `subscription_uuid`
7. **Paginated response**: `{ data: T[], nextCursor: string | null, hasMore: boolean }`

## When To Use

- Adding any new CRUD entity to the chatbot-nestjs module
- Need soft delete for GDPR compliance
- Need multi-tenant isolation
- Need cursor-based pagination for large datasets
