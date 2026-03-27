# Architecture Decision: Multi-tenant Real-time via Redis Pub/Sub Bridge

Date: 2026-03-27
Status: Implemented
Feature: Message Management — Inbox

---

## Context

Need real-time message delivery from NestJS backend to Vue frontend in a multi-tenant SaaS platform. Each tenant has isolated data and WebSocket channels.

## Options Considered

### Option A: NestJS WebSocket Gateway directly
- NestJS serves WebSocket connections directly
- Vue connects to NestJS WebSocket
- **Pros**: Simpler, fewer moving parts
- **Cons**: Bypasses Laravel auth, need separate auth for WS, CORS issues, can't leverage Laravel Reverb

### Option B: Redis Pub/Sub → Laravel Reverb (CHOSEN)
- NestJS publishes events to Redis Pub/Sub channels
- Laravel long-running command subscribes to Redis, rebroadcasts to Reverb
- Vue uses Laravel Echo to connect to Reverb
- **Pros**: Leverages existing Laravel auth + channel authorization, Reverb handles scaling, tenant isolation via Laravel's broadcast auth
- **Cons**: Extra hop (NestJS → Redis → Laravel → Reverb → Vue), requires long-running command

### Option C: Direct Redis → Client (Socket.IO adapter)
- Use Socket.IO with Redis adapter
- **Pros**: Low latency
- **Cons**: Completely separate auth system, doesn't integrate with Laravel ecosystem

## Decision

**Option B** — Redis Pub/Sub bridge via Laravel MessageSubscribeCommand.

## Reasoning

1. **Auth reuse**: Laravel's broadcast channel authorization handles tenant isolation — no need to re-implement auth for WebSocket.
2. **Reverb maturity**: Laravel Reverb is the official real-time solution, production-tested.
3. **Fallback**: Polling every 15s ensures eventual consistency if WebSocket drops.
4. **Separation of concerns**: NestJS doesn't need to know about WebSocket connections. It just publishes events.
5. **Scalability**: Reverb can be scaled independently. Multiple Laravel workers can subscribe to Redis.

## Consequences

- Must run `php artisan chatbot:message-subscribe` as a daemon (supervisor/systemd)
- Extra latency (~50-100ms) from the bridge hop — acceptable for chat
- Need health monitoring on the daemon process
- Redis must be shared between NestJS and Laravel (same instance or cluster)

## Risk Mitigation

- **Daemon crashes**: Supervisor auto-restarts
- **Redis connection loss**: Command has reconnection logic
- **Message loss during restart**: Polling fallback catches up within 15s
- **Channel auth**: TenantChannel verifies user belongs to tenant before allowing subscription
