# Pattern: Real-time Inbox Page (2-Panel Layout)

Extracted from: Message Management — Inbox feature (2026-03-27)
Projects: chatbot-nestjs (backend) + datazen (frontend)

---

## Overview

A 2-panel real-time inbox page where:
- **Left panel**: Conversation/item list with filters, search, pagination
- **Right panel**: Detail view (messages, notes, actions)
- **Real-time**: WebSocket for instant updates + polling fallback

## Architecture

```
NestJS Backend → Redis Pub/Sub → Laravel MessageSubscribeCommand → Laravel Reverb (WebSocket) → Vue Echo
                                                                                                  ↓
                                                                 Vue also polls API every 15s (fallback)
```

## File Structure

### Backend (NestJS — chatbot-nestjs)
```
src/modules/{module-name}/
├── controllers/
│   ├── internal-{name}.controller.ts      # Main CRUD endpoints
│   ├── {sub-feature}.controller.ts        # Sub-feature endpoints
├── services/
│   ├── inbox-query.service.ts             # List + search + pagination
│   ├── inbox-cache.service.ts             # Redis dirty-flag caching
│   ├── conversation-state.service.ts      # Redis state management
│   ├── message-persist.service.ts         # Async message storage
│   ├── {sub-feature}.service.ts           # Sub-feature business logic
├── entities/
│   ├── conversation.entity.ts             # Main entity
│   ├── conversation-message.entity.ts     # Child entity
│   ├── conversation-event.entity.ts       # Audit trail
├── dto/
│   ├── index.ts                           # DTO barrel export
│   ├── {feature}.dto.ts                   # Validation DTOs
├── processors/
│   ├── message-persist.processor.ts       # BullMQ worker
│   ├── auto-release.processor.ts          # Scheduled cleanup
│   ├── data-retention.processor.ts        # GDPR/retention
├── schedulers/
│   ├── auto-release.scheduler.ts          # Repeatable job registration
│   ├── data-retention.scheduler.ts
├── publishers/
│   ├── message-event.publisher.ts         # Redis Pub/Sub events
├── interfaces/
│   ├── {module}.interface.ts              # TypeScript interfaces
├── constants/
│   ├── {module}.constants.ts              # Queue names, defaults
├── {module}.module.ts                     # NestJS module definition
```

### Frontend (Laravel + Vue — datazen)
```
Modules/ChatBot/
├── app/Http/Controllers/Tenant/
│   └── InboxController.php                # Inertia page + JSON API proxy
├── app/Services/ChatBot/
│   └── MessageManagementApiService.php    # HTTP client to NestJS
├── app/Console/Commands/
│   └── MessageSubscribeCommand.php        # Redis→Reverb bridge daemon
├── app/Events/
│   └── InboxMessageEvent.php              # Broadcast event
├── routes/
│   └── tenant.php                         # Route definitions
├── resources/js/Pages/Inbox/
│   └── Index.vue                          # Main SFC (~2000+ lines)
```

## Key Patterns

### 1. Cursor-based Pagination
```typescript
// Backend: encode cursor from composite key
const cursor = Buffer.from(`${lastMessageAt}:${id}`).toString('base64');

// Frontend: pass cursor param for next page
const { data, nextCursor, hasMore } = await api.listConversations({ cursor });
```

### 2. Dirty-flag Cache Invalidation
```
On message persist:
  SET inbox_dirty:{subscriptionUuid}:{pageId} 1 EX 2   // 2-sec TTL

On inbox read:
  if EXISTS inbox_dirty:... → rebuild from DB
  else → return cached result
```
Purpose: debounce burst of messages, only rebuild once.

### 3. Real-time Event Bridge (NestJS → Vue)
```
NestJS publishes:  PUBLISH msg:{subscriptionUuid} {type, data}
Laravel daemon:    SUBSCRIBE msg:* → broadcast InboxMessageEvent to Reverb
Vue Echo:          listen('tenant.{tenantId}.inbox.{subscriptionUuid}')
```

### 4. Polling Fallback
```javascript
// Every 15 seconds, refresh conversation list
setInterval(() => {
  const conversations = await api.listConversations(filters);
  mergeIntoExisting(conversations); // update existing, prepend new
}, 15000);
```

### 5. Optimistic Updates
```javascript
// Send message → immediately show in UI with "pending" state
messages.push({ ...msg, _pending: true });
try {
  await api.sendMessage(msg);
  msg._pending = false;
} catch {
  msg._failed = true;
}
```

### 6. State Machine (Takeover/Release)
```
States: bot_active → human_active → bot_active
        human_active → human_active (transfer)

Redis key: conv_state:{subscriptionUuid}:{platform}:{pageId}:{senderId}
  null = bot_active (default)
  {state, assignedStaffId, assignedStaffName, assignedAt} = active state

Auto-release: scheduler sweeps every 5min, releases stale human_active after 30min
```

### 7. Multi-tenant Isolation
```
Every query: WHERE subscription_uuid = :subscriptionUuid
Every Redis key: includes subscriptionUuid
Every WebSocket channel: tenant.{tenantId}.inbox.{subscriptionUuid}
```

## Gotchas & Lessons

1. **Vue SFC size**: 2000+ lines is too large. Should split into composables + sub-components.
2. **MessageSubscribeCommand**: Long-running daemon needs reconnection logic and health monitoring.
3. **Race condition on conversation create**: Use INSERT ... ON CONFLICT DO NOTHING + re-fetch pattern.
4. **Profile backfill**: Fire-and-forget — don't block message persist on Graph API calls.
5. **Unread count**: Increment atomically in SQL, not application code.
6. **Typing debounce**: 3s on send side, 5s auto-clear on display side.

## When To Use This Pattern

- Building any real-time list + detail page (inbox, chat, support tickets, live feed)
- Need WebSocket with graceful fallback
- Multi-tenant SaaS with per-tenant isolation
- Requires audit trail of state changes
