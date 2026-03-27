# Progress Dashboard
Last updated: 2026-03-27

## Active Now
**Message Management** — Wave 2 done. Remaining: Customer Sidebar, Transfer Dropdown fix, Accessibility, E2E Tests.

---

## chatbot-nestjs (NestJS Backend)
[xxxxxxxxxx] 100%

### Done
- DONE: Message persistence module (13 API endpoints, 8 services, 5 entities)
- DONE: Canned responses CRUD + Conversation notes CRUD
- DONE: Auto-release scheduler + data retention + data deletion
- DONE: Real-time events via Redis Pub/Sub
- DONE: Human takeover state machine
- DONE: Merged to main

### Pending
- QUEUED: Run migration SQL for cb_canned_responses + cb_conversation_notes on tenant DBs

---

## datazen (Laravel + Vue Frontend)
[xxxxxxxxx.] 92%

### Active
- QUEUED: Customer Context Sidebar (#7)
- QUEUED: Fix Transfer Dialog — searchable staff dropdown (#8)
- QUEUED: Keyboard shortcuts + ARIA accessibility (#10)
- QUEUED: E2E Functional Tests (#4) — blocked by #8

### Done (this session)
- DONE: Transfer Conversation UI — dialog + button (#1)
- DONE: Typing Indicator Display — 3 dots + list preview (#2)
- DONE: Echo event handlers wired up (bonus)
- DONE: Zalo OA platform support — filter, badge, icon (#6)
- DONE: Message retry + dismiss for failed sends (#9)
- DONE: Fix P0 — fatal import, daemon reconnection, event validation (#11)
- DONE: Fix P1 — HTTP timeout, input validation, cache TTL
- DONE: Code Review — 18 findings, P0s fixed

### Done (previous sessions)
- DONE: Laravel proxy layer → NestJS API
- DONE: Vue Inbox page 2-panel layout
- DONE: Conversation list + filters + cursor pagination
- DONE: Message display (attachments, role badges, timestamps)
- DONE: Send message + takeover/release + canned responses + notes
- DONE: Real-time WebSocket (Reverb) + polling fallback
- DONE: Unread tracking + notifications + mobile responsive + dark mode

---

## Teammates Active

| Name | Role | Project | Status | Current Task |
|------|------|---------|--------|-------------|
| _None_ | — | — | — | All Wave 2 teammates completed |

## Blockers
None

## Recent Decisions

| When | Decision | Reasoning |
|------|----------|-----------|
| 2026-03-27 | Delete InboxDataService (dead code) | Imported non-existent class → fatal error, no references anywhere |
| 2026-03-27 | Add reconnection + backoff to daemon | Redis drop kills daemon → rapid restart loop under supervisor |
| 2026-03-27 | Add HTTP timeout 10s/5s | NestJS hang → exhausts PHP-FPM workers |
| 2026-03-27 | Prioritize Zalo UI | 85% VN users on Zalo, backend ready, UI trivial |
| 2026-03-27 | Add .gitignore for project dirs | Projects are separate git repos, must not be tracked by claude-teammate |

## Velocity

| Feature | Time | Generator Used | Auto-Generated % | Manual % |
|---------|------|----------------|-------------------|----------|
| Message Management (backend) | Previous sessions | None | 0% | 100% |
| Message Management (frontend) | Previous sessions + this session | None | 0% | 100% |
| Transfer UI + Typing Indicator | ~6 min (Frontend Eng A) | None | 0% | 100% |
| P0 Fixes | ~3 min (Backend Eng) | None | 0% | 100% |
| Zalo UI + Message Retry | ~6 min (Frontend Eng B) | None | 0% | 100% |

## Knowledge Extracted This Session

| Type | File | Description |
|------|------|-------------|
| Pattern | inbox-realtime-page.md | 2-panel real-time inbox with WebSocket + polling |
| Pattern | laravel-nestjs-proxy.md | Laravel thin proxy to NestJS API |
| Pattern | nestjs-crud-with-softdelete.md | NestJS CRUD with soft delete, cursor pagination |
| Decision | multi-tenant-realtime-bridge.md | Redis Pub/Sub → Reverb bridge architecture |
| Research | inbox-competitor-analysis-2026-03.md | 7 competitors analysis + pricing + gaps |
| Research | inbox-ux-audit-2026-03.md | 31 UX issues (3 critical, 7 high) |

---

## Recovery Info
- **Identity**: I am Team Lead. I coordinate, not code. Teammates code. I review.
- **Feature in progress**: Message Management — Wave 2 complete, Wave 3 pending
- **Current phase**: Between waves. Ready for Customer Sidebar or merge review.
- **Process**: Read CLAUDE.md -> Read LESSONS.md -> Check PROGRESS.md -> Spawn teammates
- **After compact**: Re-read this section. Respawn teammates if lost.
