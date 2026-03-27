# Pattern: Adding a Feature to Datazen Inbox

Extracted from: Canned Responses + Conversation Notes (Sprint 1, 2026-03)
Applicable: Any new feature that integrates into the datazen inbox page

---

## Overview

The inbox is a unified conversation management page in the ChatBot module. It combines an Inertia page (`Index.vue`) with client-side JSON API calls. New features are added as:

- **Picker/Popover** (like Canned Responses): A button/popover that injects content into the message composer.
- **Tab Panel** (like Internal Notes): A new tab in the conversation detail sidebar.
- **Both** are possible on the same feature.

All data flows through the NestJS chatbot-nestjs API, proxied by Laravel.

## Integration Stack (4 layers)

```
Layer 1: Vue composable     → useInboxApi.ts (API methods)
Layer 2: Laravel routes      → tenant.php (route definitions)
Layer 3: Laravel controller  → InboxController.php (proxy methods)
Layer 4: Laravel API service → MessageManagementApiService.php (HTTP to NestJS)
```

Each new feature needs additions to ALL 4 layers, plus the Vue page integration.

---

## Layer 1: Vue Composable — `useInboxApi.ts`

File: `Modules/ChatBot/resources/js/vue/tenant/composables/useInboxApi.ts`

Add API methods for each endpoint. Follow existing patterns exactly.

### GET (list/fetch) pattern

```typescript
const fetch{Feature}s = (
  filters: Record<string, any> = {},
  callbacks?: { onSuccess?: (data: any) => void; onError?: (err: any) => void },
) =>
  useApi(
    () =>
      api.get("tenant.chatbot.inbox.api.{feature-kebab-plural}", {
        ...getRouteParams(),
        ...filters,
      }),
    { silent: true, disableGlobalLoading: true, showSuccess: false, ...callbacks },
  );
```

### POST (create) pattern

```typescript
const create{Feature} = (
  payload: { /* typed fields */ },
  callbacks?: { onSuccess?: (data: any) => void; onError?: (err: any) => void },
) =>
  useApi(
    () =>
      api.post(
        "tenant.chatbot.inbox.api.{feature-kebab-plural}.create",
        payload,
        getRouteParams(),
      ),
    { silent: false, disableGlobalLoading: true, ...callbacks },
  );
```

### PATCH (update) pattern

```typescript
const update{Feature} = (
  {feature}Id: number,
  payload: { /* typed optional fields */ },
  callbacks?: { onSuccess?: (data: any) => void; onError?: (err: any) => void },
) =>
  useApi(
    () =>
      api.patch(
        "tenant.chatbot.inbox.api.{feature-kebab-plural}.update",
        payload,
        getRouteParams({ {feature}Id }),
      ),
    { silent: false, disableGlobalLoading: true, ...callbacks },
  );
```

### DELETE pattern

```typescript
const delete{Feature} = (
  {feature}Id: number,
  callbacks?: { onSuccess?: (data: any) => void; onError?: (err: any) => void },
) =>
  useApi(
    () =>
      api.delete(
        "tenant.chatbot.inbox.api.{feature-kebab-plural}.delete",
        getRouteParams({ {feature}Id }),
      ),
    { silent: false, disableGlobalLoading: true, ...callbacks },
  );
```

### For conversation-scoped features (like notes)

Pass `conversationId` in route params:
```typescript
const fetch{Feature}s = (
  conversationId: number,
  callbacks?: { onSuccess?: (data: any) => void; onError?: (err: any) => void },
) =>
  useApi(
    () =>
      api.get("tenant.chatbot.inbox.api.{feature-kebab-plural}", {
        ...getRouteParams({ conversationId }),
      }),
    { silent: true, disableGlobalLoading: true, showSuccess: false, ...callbacks },
  );
```

### Key conventions

- **Route names**: Use Ziggy named routes (`tenant.chatbot.inbox.api.{feature}.{action}`).
- **`getRouteParams()`**: Always spread this first — includes `subscription` UUID.
- **GET calls**: `silent: true`, `showSuccess: false` (background data fetch).
- **Mutation calls**: `silent: false` (show loading/error to user).
- **All calls**: `disableGlobalLoading: true` (inbox manages its own loading states).
- **Return all methods** from the composable's return object.

---

## Layer 2: Laravel Routes — `tenant.php`

File: `Modules/ChatBot/routes/tenant.php`

Add routes inside the existing inbox API group:

```php
Route::prefix('{subscription}/app/chatbot/inbox')
    ->middleware(['auth', 'tenant', BindSubscriptionContext::class])
    ->where(['subscription' => '[0-9a-f-]{36}'])
    ->group(function () {
        Route::prefix('api')->group(function () {
            // ... existing routes ...

            // ── {Feature} ({source} proxy) ──
            Route::get('{feature-kebab-plural}', [InboxController::class, 'api{Feature}s'])
                ->name('tenant.chatbot.inbox.api.{feature-kebab-plural}');
            Route::post('{feature-kebab-plural}', [InboxController::class, 'apiCreate{Feature}'])
                ->name('tenant.chatbot.inbox.api.{feature-kebab-plural}.create');
            Route::patch('{feature-kebab-plural}/{{feature}Id}', [InboxController::class, 'apiUpdate{Feature}'])
                ->name('tenant.chatbot.inbox.api.{feature-kebab-plural}.update')
                ->where('{feature}Id', '[0-9]+');
            Route::delete('{feature-kebab-plural}/{{feature}Id}', [InboxController::class, 'apiDelete{Feature}'])
                ->name('tenant.chatbot.inbox.api.{feature-kebab-plural}.delete')
                ->where('{feature}Id', '[0-9]+');
        });
    });
```

### For conversation-scoped features

Nest under `conversations/{conversationId}/`:
```php
Route::get('conversations/{conversationId}/{feature-kebab-plural}', [InboxController::class, 'api{Feature}s'])
    ->name('tenant.chatbot.inbox.api.{feature-kebab-plural}')
    ->where('conversationId', '[0-9]+');
Route::post('conversations/{conversationId}/{feature-kebab-plural}', [InboxController::class, 'apiCreate{Feature}'])
    ->name('tenant.chatbot.inbox.api.{feature-kebab-plural}.create')
    ->where('conversationId', '[0-9]+');
Route::patch('conversations/{conversationId}/{feature-kebab-plural}/{noteId}', ...)
    ->where(['conversationId' => '[0-9]+', 'noteId' => '[0-9]+']);
```

### Route naming convention

```
tenant.chatbot.inbox.api.{feature-kebab-plural}          → list
tenant.chatbot.inbox.api.{feature-kebab-plural}.create    → create
tenant.chatbot.inbox.api.{feature-kebab-plural}.update    → update
tenant.chatbot.inbox.api.{feature-kebab-plural}.delete    → delete
```

---

## Layer 3: Laravel Controller — `InboxController.php`

File: `Modules/ChatBot/app/Http/Controllers/Tenant/InboxController.php`

Add proxy methods to `InboxController`. Each method:
1. Gets `tenantId` from `tenant('id')`
2. Gets `subscription` from route param
3. Validates input
4. Calls `MessageManagementApiService`
5. Returns JSON response

### List method pattern

```php
public function api{Feature}s(Request $request, string $subscription): JsonResponse
{
    $tenantId = tenant('id');

    $data = $this->apiService->get{Feature}s($tenantId, array_filter([
        'subscriptionUuid' => $subscription,
        'search' => $request->input('search'),
        'cursor' => $request->input('cursor'),
    ]));

    return response()->json(['success' => true, ...$data]);
}
```

### Create method pattern

```php
public function apiCreate{Feature}(Request $request, string $subscription): JsonResponse
{
    $tenantId = tenant('id');

    $request->validate([
        'field1' => 'required|string|max:255',
        'field2' => 'required|string|max:5000',
    ]);

    $result = $this->apiService->create{Feature}($tenantId, [
        'subscriptionUuid' => $subscription,
        'field1' => $request->input('field1'),
        'field2' => $request->input('field2'),
        'createdBy' => (string) auth()->id(),
        'createdByName' => auth()->user()->name,
    ]);

    if (! ($result['success'] ?? true)) {
        return response()->json(['success' => false, 'error' => $result['error'] ?? 'Create failed'], 422);
    }

    return response()->json(['success' => true, ...$result]);
}
```

### Update method pattern

```php
public function apiUpdate{Feature}(Request $request, string $subscription, int ${feature}Id): JsonResponse
{
    $tenantId = tenant('id');

    $request->validate([
        'field1' => 'sometimes|required|string|max:255',
        'field2' => 'sometimes|required|string|max:5000',
    ]);

    $result = $this->apiService->update{Feature}($tenantId, ${feature}Id, array_filter([
        'field1' => $request->input('field1'),
        'field2' => $request->input('field2'),
        'updatedBy' => (string) auth()->id(),
    ], fn ($v) => $v !== null));

    if (! ($result['success'] ?? true)) {
        return response()->json(['success' => false, 'error' => $result['error'] ?? 'Update failed'], 422);
    }

    return response()->json(['success' => true, ...$result]);
}
```

### Delete method pattern

```php
public function apiDelete{Feature}(Request $request, string $subscription, int ${feature}Id): JsonResponse
{
    $tenantId = tenant('id');

    $result = $this->apiService->delete{Feature}($tenantId, ${feature}Id);

    if (! ($result['success'] ?? true)) {
        return response()->json(['success' => false, 'error' => $result['error'] ?? 'Delete failed'], 422);
    }

    return response()->json(['success' => true, ...$result]);
}
```

### Key conventions

- **`tenant('id')`**: Gets tenant UUID from multi-tenancy context (set by middleware).
- **`$request->route('subscription')`** or method param `string $subscription`: Gets subscription UUID from route.
- **`auth()->id()`**: Gets staff user ID for audit trail. Cast to string for NestJS.
- **`auth()->user()->name`**: Gets staff name for display.
- **`array_filter(..., fn ($v) => $v !== null)`**: Strip null values before sending to NestJS (prevents overwriting with null).
- **Validation**: Use Laravel inline validation (`$request->validate()`) before proxying.
- **Error check**: `if (! ($result['success'] ?? true))` — default to success if key missing.

---

## Layer 4: Laravel API Service — `MessageManagementApiService.php`

File: `Modules/ChatBot/app/Services/MessageManagementApiService.php`

Add methods that call the NestJS internal API.

### GET method pattern

```php
/**
 * GET /{feature-kebab-plural} — List {features}.
 *
 * @param  array<string, mixed>  $params
 * @return array<string, mixed>
 */
public function get{Feature}s(string $tenantId, array $params = []): array
{
    return $this->safeGet("{$this->basePath($tenantId)}/{feature-kebab-plural}", $params);
}
```

### POST method pattern

```php
/**
 * POST /{feature-kebab-plural} — Create a {feature}.
 *
 * @param  array<string, mixed>  $data
 * @return array<string, mixed>
 */
public function create{Feature}(string $tenantId, array $data): array
{
    return $this->safePost("{$this->basePath($tenantId)}/{feature-kebab-plural}", $data);
}
```

### PATCH method pattern

```php
public function update{Feature}(string $tenantId, int $id, array $data): array
{
    return $this->safePatch("{$this->basePath($tenantId)}/{feature-kebab-plural}/{$id}", $data);
}
```

### DELETE method pattern

```php
public function delete{Feature}(string $tenantId, int $id): array
{
    return $this->safeDelete("{$this->basePath($tenantId)}/{feature-kebab-plural}/{$id}");
}
```

### For conversation-scoped features

```php
public function get{Feature}s(string $tenantId, int $conversationId): array
{
    return $this->safeGet("{$this->basePath($tenantId)}/conversations/{$conversationId}/{feature-kebab-plural}");
}
```

### Key conventions

- **Use `safeGet/safePost/safePatch/safeDelete`**: These wrap HTTP calls with try-catch and return structured error responses instead of throwing.
- **`basePath($tenantId)`**: Returns `/api/v1/internal/messages/{tenantId}`.
- **Keys sent to NestJS must be camelCase** (not snake_case). The ConvertCase middleware handles browser requests, but API service calls are raw.

---

## Vue Page Integration (Index.vue)

File: `Modules/ChatBot/resources/js/vue/tenant/pages/inbox/Index.vue`

### Integration Type A: Picker/Popover (like Canned Responses)

A button that opens a popover/dialog to select or create items, then injects content into the message composer.

**Integration points in Index.vue:**
1. Import composable methods in `<script setup>`
2. Add reactive state (list data, search, loading)
3. Add a toolbar button (next to other composer tools)
4. Add popover/dialog component with search + list
5. Handle selection → inject into message input
6. Handle CRUD operations inline (create/edit/delete within popover)

### Integration Type B: Tab Panel (like Internal Notes)

A new tab in the conversation detail sidebar that shows feature-specific content.

**Integration points in Index.vue:**
1. Import composable methods
2. Add tab definition to tab list
3. Add tab panel content component
4. Fetch data when tab becomes active or conversation changes
5. Handle CRUD within the tab panel

### Integration Type C: Notification (sound + badge)

For features that generate real-time events.

**Integration points:**
1. WebSocket/polling listener for new events
2. Badge count on tab or sidebar item
3. Sound notification (optional, user-configurable)

---

## Checklist: Adding a New Inbox Feature

### NestJS Backend (chatbot-nestjs)

- [ ] Entity created with bigint PK, unix ms timestamps, soft delete
- [ ] DTOs with MaxLength on all strings, @Transform for booleans
- [ ] Service with TenantConnectionPool, cursor pagination, ILIKE escape
- [ ] Controller with @Public, @SkipTenantCheck, setTenantContext
- [ ] Entity added to module entities/index.ts barrel
- [ ] DTOs added to module dto/index.ts barrel
- [ ] Service added to module services/index.ts barrel
- [ ] Controller + Service registered in module.ts
- [ ] Entity added to TenantEntities array in infrastructure/database/tenant/entities/index.ts
- [ ] Migration SQL created in database_structures/migrations/

### Laravel Proxy (datazen)

- [ ] Routes added to tenant.php (inside inbox api group)
- [ ] Controller proxy methods added to InboxController.php
- [ ] API service methods added to MessageManagementApiService.php
- [ ] Validation rules in controller match NestJS DTO constraints

### Vue Frontend (datazen)

- [ ] Composable API methods added to useInboxApi.ts
- [ ] Methods returned from composable return object
- [ ] Index.vue integrated (popover/tab/notification as appropriate)
- [ ] Loading states handled
- [ ] Error states handled
- [ ] Optimistic UI updates where appropriate

### Cross-cutting

- [ ] Route names follow convention: `tenant.chatbot.inbox.api.{feature}.{action}`
- [ ] NestJS endpoint paths follow convention: `internal/messages/:tenantId/{feature}`
- [ ] camelCase in NestJS, snake_case in Laravel validation, camelCase in Vue
- [ ] Auth user info (id + name) passed as createdBy/updatedBy
- [ ] subscriptionUuid passed for tenant isolation
