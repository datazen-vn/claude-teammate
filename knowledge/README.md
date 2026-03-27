# Knowledge Base -- Exponential Growth Engine

Catalog of all patterns, generators, decisions, and research accumulated by the team.
Lead + Teammates read this before starting any new task.

---

## Patterns (`patterns/`)

Documented patterns extracted from shipped features.

| File | Description | Extracted From |
|------|-------------|----------------|
| inbox-realtime-page.md | 2-panel real-time inbox with WebSocket + polling fallback | Message Management Inbox |
| laravel-nestjs-proxy.md | Laravel thin proxy layer to NestJS internal API | Message Management API proxy |
| nestjs-crud-with-softdelete.md | NestJS CRUD with soft delete, cursor pagination, multi-tenant | Canned Responses + Conversation Notes |

**How to add:** After shipping a feature, extract the repeating structure into a pattern document.
Include: file structure, naming conventions, data flow, key decisions, gotchas.

## Generators (`generators/`)

Agent definitions that auto-generate code based on accumulated patterns.

| File | Description | Input -> Output |
|------|-------------|-----------------|
| _None yet_ | | |

**How to add:** When you see 2+ features following the same pattern, create a generator agent.
Place the agent definition in `.claude/agents/` and document it here.

## Decisions (`decisions/`)

Architecture decisions with reasoning, so the team does not re-debate settled questions.

| File | Description |
|------|-------------|
| multi-tenant-realtime-bridge.md | Why Redis Pub/Sub → Laravel Reverb bridge for real-time (vs direct WS) |
| message-management-deploy-checklist.md | Full deploy checklist: migrations, daemon, smoke tests, rollback |

**How to add:** When making a significant architecture decision, document the options considered,
tradeoffs evaluated, and reasoning for the final choice.

## Research Cache (`research-cache/`)

Advisory research already completed, cached to avoid re-research.

| File | Description |
|------|-------------|
| inbox-competitor-analysis-2026-03.md | Competitor analysis vs 7 competitors (Intercom, Zendesk, etc.) with pricing + feature matrix |
| inbox-ux-audit-2026-03.md | UX audit: 31 issues found (3 critical, 7 high) with prioritized fix plan |

**How to add:** When advisory agents complete research (competitor analysis, regulation review,
best practices), save the findings here for future reference.

## Lessons (`lessons/`)

Extracted lessons organized by topic for quick reference.

| File | Description |
|------|-------------|
| _None yet_ | |

**How to add:** Periodically consolidate LESSONS.md entries by topic into focused documents here.
