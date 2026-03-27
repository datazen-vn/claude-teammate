# Progress Dashboard
Last updated: 2026-03-27 (session 8 — Sprint 1 HOTFIX + SECURITY AUDIT)

## Active Now
**Sprint 1 Hotfix — 🔄 QA GATE RUNNING**

Code review found 8 P0 bugs (5 functional + 3 security). All fixed. QA gates verifying builds.

### Sprint 1 Summary
| # | Feature | Backend | Frontend | Status |
|---|---------|---------|----------|--------|
| 1 | Canned Responses | 5 CRUD endpoints + entity + migration | Picker (⚡ + `/` shortcut) + CRUD dialog | ✅ pushed |
| 2 | Internal Notes | 4 CRUD endpoints + GDPR soft-delete | Notes tab + pin + inline edit + delete | ✅ pushed |
| 3 | Notifications Phase A | — | Sound chime + tab title `(N)` + sidebar badge | ✅ pushed |
| 4 | Orchestrator Context | Staff msg tagging + bot resume awareness | — | ✅ pushed |
| 5 | CRM Subscription Fix | Cache invalidation + fresh lookup + TTL 15min | — | ✅ pushed |
| 6 | DB Schema Docs | 38 files updated from production DB | — | ✅ pushed |
| 7 | Customer Typing | — | — | ❌ DEFERRED (no FB webhook) |

### Deployment Pipeline — chatbot-nestjs (6 new commits on main)
| Commit | Content |
|--------|---------|
| 7f6b186 | feat: add canned responses CRUD API |
| ccae1c1 | feat: add conversation notes CRUD API |
| 13ce006 | feat: staff message context tagging + bot resume awareness |
| 87c603e | fix: CRM subscription UUID stale cache |
| a232717 | docs: update database schema from production DB |
| 854bc7b | refactor: minor code quality improvements |

### Deployment Pipeline — datazen (2 new commits on main)
| Commit | Content |
|--------|---------|
| 2e38e283 | feat(inbox): proxy routes for canned responses + notes |
| 30ea8da9 | feat(inbox): canned responses picker, notes tab, notifications |

### Deployment Status — ALL DEPLOYED + MIGRATED
| Repo | Action | Status |
|------|--------|--------|
| chatbot-nestjs | CI/CD Pipeline (deploy=true) | ✅ deployed |
| datazen | Build and Deploy (Sprint 1 features) | ✅ deployed |
| datazen | Build and Deploy (tenant migrations) | ✅ deployed |
| datazen | tenants:migrate (8/8 tenants) | ✅ cb_canned_responses + cb_conversation_notes created |

### Config Cache Issue — ✅ ROOT CAUSE FIXED
`CoreServiceProvider::registerTenancyMigrationPaths()` was overwriting glob() result with only 3 base modules.
Fix: removed method entirely — glob() in config/tenancy.php now works correctly for all 10 modules.

### Sprint 1 Code Review — 8 P0 Found & Fixed
| # | P0 Issue | Project | Fix |
|---|----------|---------|-----|
| 1 | `createCannedResponse` missing createdBy/createdByName | datazen | Added auth fields to proxy payload |
| 2 | `getConversationNotes` missing subscriptionUuid query | datazen | Pass subscription to service + API |
| 3 | Canned Response getById/update/delete no subscription isolation | chatbot-nestjs | Added subscriptionUuid to WHERE clauses |
| 4 | Conversation Note update/delete no subscription isolation | chatbot-nestjs | Added subscriptionUuid to WHERE clauses |
| 5 | XSS via unsanitized attachment URLs | datazen | Added isSafeUrl/safeUrl helper |
| 6 | Zalo webhook guard logs secret key material | chatbot-nestjs | Removed debug logging block |
| 7 | System prompt + PII logged at info level | chatbot-nestjs | Changed 15 logs to debug(), removed content |
| 8 | Internal controllers @Public() bypass auth | chatbot-nestjs | Removed @Public() from 4 controllers |

Additional P1 fixes included:
- DTO @IsString() now allows null for nullable fields (ValidateIf)
- Search query @MaxLength(255) added
- Content max-length aligned: Laravel 5000→10000 to match NestJS
- array_filter replaced with $request->has() checks for nullable field clearing
- Debug logging removed from webhook tenant middleware

### Hardening Audit Results (chatbot-nestjs)
| Priority | Count | Key Themes |
|----------|-------|------------|
| P0 | 3 | Auth bypass, log leaks (ALL FIXED) |
| P1 | 11 | SSL rejectUnauthorized, default Bull Board creds, CORS *, no Helmet, timing-safe token |
| P2 | 13 | Silent error swallowing, no DLQ, unsalted dedup hashes |

### Connect Page Sync — Architecture Designed
Full design ready: 4 phases, 30-44h total, MVP (Phase 1+2) ~20-28h.
No new Meta permissions needed. Existing idempotency handles dedup.

---

### Previous Steps (collapsed)

<details>
<summary>Step 1-3: Migration, Bug Fixes, E2E (all done)</summary>

#### Step 1: Migration — ✅ DONE
Inbox migration already ran on production (batch 29).

#### Step 2: Fix 4 Bugs — ✅ ALL DEPLOYED
| Bug | Fix |
|-----|-----|
| Real-time messages | Wrong artisan command → `chatbot:message-subscribe` |
| Human Takeover config | Migration 8/8 + seeding + API + Popover UI |
| Sidebar filter UI | Native `<select>` → Radix Vue Select |
| Connect page sync | 📋 deferred (NEW FEATURE ~17-25hrs) |

#### Bugs Found During Deploy
- PDO `?` → `??` for PostgreSQL
- Non-object config edge case
- Core tenancy config glob fix
- NestJS CLS context missing → `setTenantContext()`
- Type mismatch `assignedStaffId` string vs `currentUserId` number

#### Step 3: E2E Test — ✅ PASS (13/14)
All pass except FB Send API (token/platform issue, not code bug).

</details>

---

## 📊 datazen
`Laravel 12 · Vue 3 · Multi-tenant SaaS`

| Status | Feature | Notes |
|--------|---------|-------|
| | **Sprint 1 — Just Pushed** | |
| ✅ | Canned Responses UI | Picker + CRUD dialog + proxy routes |
| ✅ | Internal Notes UI | Tab + pin + inline edit + GDPR delete |
| ✅ | Notifications Phase A | Sound chime + tab title + sidebar badge |
| | **Active** | |
| ✅ | Message Management — Full Stack | Real-time + Takeover + Filter + Proxy + Inbox Page + Navigation + Docker |
| ✅ | Tenancy config fix | Core module glob in migration_parameters |
| | **Backlog** | |
| ⏳ | Connect page sync conversations | Meta Graph API → NestJS → datazen |
| ⏳ | Tenant Analytics Page | Dùng page-generator |
| | **Infrastructure** | |
| ✅ | Modular Monolith setup | 10+ modules active |
| ✅ | Multi-tenant DB isolation | Central + per-tenant DBs |
| ✅ | Real-time (Laravel Reverb) | WebSocket ready |
| ✅ | Artisan runner workflow | VPS ops via GitHub Actions |

---

## 🤖 chatbot-nestjs
`NestJS 11 · Multi-tenant · Facebook/Instagram`

| Status | Feature | Notes |
|--------|---------|-------|
| | **Sprint 1 — Just Pushed** | |
| ✅ | Canned Responses API | CRUD 5 endpoints + entity + migration |
| ✅ | Internal Notes API | CRUD 4 endpoints + GDPR soft-delete |
| ✅ | Orchestrator Context | Staff msg tagging + bot resume awareness |
| ✅ | CRM Subscription Fix | Cache invalidation + fresh lookup + TTL 15min |
| ✅ | DB Schema Docs | 38 files updated from production |
| | **Done** | |
| ✅ | Message Management Backend | 10 internal API endpoints, 82 tests |
| ✅ | Backfill Sender Profile | Facebook Graph API sender name/avatar |
| | **Backlog** | |
| ⏳ | Conversation Sync Service | Fetch historical conversations from Meta API |
| 🔄 | NestJS Hardening | 3 P0 FIXED, 11 P1 + 13 P2 remaining |

---

## Teammates Active
| Name | Role | Project | Status | Task |
|------|------|---------|--------|------|
| qa-datazen | QA Gate | datazen | 🔄 running | Pint + npm build |
| qa-chatbot | QA Gate | chatbot-nestjs | 🔄 running | pnpm build + prettier |

## Blockers
- None

## Recent Decisions
| When | Decision | Reasoning |
|------|----------|-----------|
| 2026-03-27 | P0 hotfix immediate | 8 P0 bugs found in code review — fix immediately, no CEO approval needed |
| 2026-03-27 | Remove @Public() from internal controllers | Security: was allowing unauthenticated access. Laravel proxy already sends API key |
| 2026-03-27 | Config cache: remove registerTenancyMigrationPaths() | Root cause of 3/10 modules in cached config. glob() in config/tenancy.php is sufficient |
| 2026-03-27 | Connect Page Sync: 4-phase design | 30-44h total, MVP 20-28h. Reuse existing MessagePersistService for idempotency |
| 2026-03-27 | Sprint 1 SHIPPED | All 3 features + orchestrator + CRM fix committed & pushed to main |

## Git Workflow (CEO directive)
- Feature branches cho development
- Cherry-pick individual commits vào main cho production
- KHÔNG merge branches vào main
- Main luôn clean, deployable
