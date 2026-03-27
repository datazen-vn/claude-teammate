# Pattern: Laravel → NestJS API Proxy Layer

Extracted from: Message Management — Laravel proxy to NestJS (2026-03-27)
Projects: datazen (Laravel) proxying to chatbot-nestjs (NestJS)

---

## Overview

When NestJS owns the business logic + data, and Laravel serves the frontend (Inertia/Vue), Laravel acts as a thin proxy:
- Controller handles Inertia page rendering + JSON API endpoints
- Service wraps HTTP calls to NestJS internal API
- "Safe" methods return empty data on failure (graceful degradation)

## File Structure

```
Modules/{ModuleName}/
├── app/Http/Controllers/Tenant/
│   └── {Feature}Controller.php        # Inertia page + API proxy endpoints
├── app/Services/{ModuleName}/
│   └── {Feature}ApiService.php        # HTTP client to NestJS
├── routes/
│   └── tenant.php                     # Route definitions
```

## API Service Pattern

```php
class MessageManagementApiService
{
    public function __construct(
        private readonly ChatBotApiClient $apiClient  // shared HTTP client
    ) {}

    // "Safe" method — returns empty data on failure, never throws
    public function getConversationsSafe(string $tenantId, array $params): array
    {
        try {
            $response = $this->apiClient->get(
                "/api/v1/internal/messages/{$tenantId}/conversations",
                $params
            );
            return $response->json();
        } catch (\Exception $e) {
            Log::warning("Failed to fetch conversations", ['error' => $e->getMessage()]);
            return ['data' => [], 'nextCursor' => null, 'hasMore' => false];
        }
    }

    // "Strict" method — throws on failure (for mutations)
    public function takeover(string $tenantId, int $conversationId, array $data): array
    {
        $response = $this->apiClient->post(
            "/api/v1/internal/messages/{$tenantId}/conversations/{$conversationId}/takeover",
            $data
        );
        return $response->json();
    }
}
```

## Controller Pattern

```php
class InboxController extends Controller
{
    public function __construct(
        private readonly MessageManagementApiService $apiService,
        private readonly InboxDataService $dataService,
    ) {}

    // Inertia page — render with initial data
    public function inbox(Request $request, string $subscription)
    {
        $pages = $this->dataService->getConnectedPages($subscription);
        $conversations = $this->dataService->getInitialConversations($subscription);

        return Inertia::render('ChatBot::Inbox/Index', [
            'connectedPages' => $pages,
            'initialConversations' => $conversations,
        ]);
    }

    // JSON API — proxy to NestJS
    public function apiConversations(Request $request, string $subscription)
    {
        $tenantId = $this->resolveTenantId($subscription);
        $result = $this->apiService->getConversationsSafe($tenantId, $request->all());
        return response()->json($result);
    }
}
```

## Route Pattern

```php
// All routes under {subscription}/app/{module}/{feature}
Route::prefix('{subscription}/app/chatbot/inbox')->group(function () {
    // Inertia page
    Route::get('/', [InboxController::class, 'inbox'])->name('chatbot.inbox');

    // JSON API endpoints for Vue client-side fetching
    Route::get('/conversations', [InboxController::class, 'apiConversations']);
    Route::get('/conversations/{conversation}', [InboxController::class, 'apiConversationDetail']);
    Route::post('/conversations/{conversation}/takeover', [InboxController::class, 'apiTakeover']);
    // ... more endpoints
});
```

## Key Decisions

1. **Safe vs Strict methods**: Read operations use "safe" (return empty on failure) — page still renders. Mutations use "strict" (throw) — user sees error.
2. **No authentication between services**: Internal network, NestJS API is not exposed publicly.
3. **TenantId resolution**: Laravel resolves subscription UUID → tenant ID before calling NestJS.
4. **Initial data via Inertia props**: First page load includes data (SSR-friendly). Subsequent fetches via JSON API.

## Gotchas

1. **Timeout handling**: NestJS may be slow under load. Set reasonable timeouts on HTTP client.
2. **Error shape**: NestJS returns `{ statusCode, message, error }` — Laravel should translate to frontend-friendly format.
3. **Pagination passthrough**: Pass cursor/limit params directly — don't re-implement pagination in Laravel.
4. **subscriptionUuid**: Sometimes in route param, sometimes in query param. Be consistent.

## When To Use

- NestJS owns data + logic, Laravel serves the UI
- Adding a new page that reads from NestJS
- Need graceful degradation (page renders even if NestJS is down)
