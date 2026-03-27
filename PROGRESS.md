# Progress Dashboard
Last updated: 2026-03-28

## Active Now
Round 2 fixes complete. 19 issues found, all fixed. Awaiting Owner verification.

---

## Inbox — ~75% (up from 50%)
### Fixed this round
- Zen AI /analyze DTO mismatch → fixed (was always 422)
- Staff list cross-tenant leak → fixed (tenant_id filter added)
- Takeover error handling → fixed (inverted default, type cast, null guard)
- Echo strips attachments/quickReplies → fixed (pass through from payload)
- Echo takeover_changed missing staff sync → fixed
- Page filter added (dropdown, filter by connected page)
- Page name shown in conversation list items
- Quick reply chips rendered in chat panel
- Dead useInboxRealtime.ts deleted
- CustomerSidebar duplication eliminated (−196 lines)
- View CRM Profile link added
- Empty Quick Actions header hidden

### Still needs work
- Filters still raw HTML (not DzSelect/DzFilterBar) — cosmetic but noticeable
- Takeover per-page config (currently global) — needs backend support
- Real-time daemon may not be running on production

## Quota Usage — ~60% (up from 20%)
### Fixed this round
- Empty chart/table/ZenAi sections hidden when no data
- Error handling: distinguish 404/500/no-subscription
- Guard against limit_value = 0

### Still needs work
- dailyUsage time-series needs backend table (currently empty)
- platformBreakdown needs NestJS data source (currently empty)
- zenAiStats needs feedback aggregation query

## Zen AI — ~65% (up from 30%)
### Fixed this round
- /analyze payload mismatch → works now
- Uses last USER message (not bot reply) for analysis
- Quota exceeded shows amber warning (not silent fail)
- Readiness states in sidebar (quota exceeded / no conversation / ready)
- Auth check on SSE proxy endpoint

### Still needs work
- AI readiness indicator showing what AI learned (knowledge docs count, topics)
- Draft streaming needs production verification
- Feedback logging needs cb_zen_ai_suggestions table created

## Knowledge Hub — ~55% (up from 40%)
- Connected to real API
- Notifications (Echo + polling) added
- Retry/Delete buttons show "not available yet" warning
- Needs: actual retry/delete API implementation

---

## Recovery Info
- **Identity**: Team Lead. Coordinate, not code. Brief teammates well.
- **Rule**: Only report done when tenant can use without issues
- **Spawn quality**: >80% usable first try (this round: 100%)
