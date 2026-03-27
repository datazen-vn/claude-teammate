# Inbox Competitor Analysis — 2026-03-27

## Current State: DataZen Inbox v1 (~60% feature parity)

Core inbox, human takeover, real-time, state management, search, filters, CRM linkage — solid foundation.
Missing: collaboration layer + operational intelligence layer.

## Competitor Matrix Summary

Analyzed: Chatwoot, Intercom, Zendesk, Freshchat, Tidio, Crisp + Hospitality: HiJiffy, Myma

## CRITICAL GAPS (ALL competitors have these)

| # | Feature | Effort | Impact |
|---|---------|--------|--------|
| 1 | **Canned Responses** (shortcode `/keyword`) | LOW | HIGH |
| 2 | **Internal/Private Notes** (staff-only messages) | LOW | HIGH |
| 3 | **Sound + Desktop Notifications** | LOW | HIGH |
| 4 | **Customer Typing Indicator** (inbound) | LOW | MEDIUM-HIGH |
| 5 | **File/Media Sending from Staff** | MEDIUM | HIGH |
| 6 | **Agent Online/Offline Presence** | MEDIUM | HIGH |
| 7 | **Conversation Labels/Tags** | LOW | MEDIUM-HIGH |

## HIGH VALUE GAPS

| # | Feature | Effort | Impact |
|---|---------|--------|--------|
| 8 | **Auto-Assign / Round-Robin** | MEDIUM | HIGH |
| 9 | **Basic Analytics Dashboard** | MEDIUM-HIGH | HIGH |
| 10 | **CSAT Surveys** (post-conversation) | MEDIUM | HIGH |
| 11 | **AI Reply Suggestions** (Copilot — leverages existing infra) | MEDIUM | HIGH |
| 12 | **SLA Policies** | MEDIUM-HIGH | MEDIUM |
| 13 | **Conversation Priority** | LOW (4hr) | MEDIUM |
| 14 | **Conversation Resolve action** | LOW (4hr) | MEDIUM |

## QUICK WINS (< 1 day each)

1. Conversation Priority — add column + sort (~4hr)
2. Resolve/Close action — add state + button (~4hr)
3. Unread badge in sidebar/header (~2hr)
4. "Waiting for X minutes" indicator (~2hr)
5. Keyboard shortcuts: `/` canned, Ctrl+Enter send (~2hr)

## Recommended Roadmap

### Sprint 1 (1-2 weeks): Foundation
- P0: Canned Responses, Internal Notes, Notifications, Customer Typing

### Sprint 2 (2-3 weeks): Collaboration
- P1: File/media sending, Agent presence, Labels, @mentions, Collision detection

### Sprint 3 (3-4 weeks): Intelligence & Analytics
- P2: Analytics dashboard, Auto-assign, CSAT, Snooze, Saved filters, Bulk actions

### Sprint 4+ (Future): Scale & Differentiation
- P3: AI Copilot, SLA management, WhatsApp, Live chat widget, Sentiment analysis

## DataZen Structural Advantage

Unlike standalone tools (Chatwoot, Intercom), DataZen IS the lodging management platform.
Staff context includes booking data, room assignments, payment history — all in same system.
This moat only works if inbox quality approaches competitors.

## Architectural Notes (from codebase scan)

- `ConversationEntity.metadata` JSONB column — currently empty, can leverage for labels/priority short-term
- `MessageEventType` needs expansion: 'resolved', 'sla_breach', 'note_added', 'label_changed'
- `ConversationState` missing: 'resolved', 'snoozed'
- `SendMessageDto` only supports text — needs attachment support
- Message roles missing: 'note' (internal), 'system' (auto-generated)
- No `firstResponseAt` tracking — essential for SLA
- Subscription feature gating already in place — new features can be tiered

## Monetization

| Tier | Features |
|------|----------|
| Free | Basic inbox, takeover/release, search, filters |
| Standard | + Canned responses, labels, notes, priority, resolve, AI suggest |
| Premium | + SLA, CSAT, automation rules, macros, analytics, round-robin |
| Enterprise | + Audit logs, custom SLA, API access, SSO |

## Sources
Chatwoot, Intercom, Zendesk, Freshchat, Tidio, Crisp official docs + HiJiffy, Myma AI
