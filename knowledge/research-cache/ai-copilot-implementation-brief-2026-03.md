# AI Copilot Implementation Brief — March 2026

Date: 2026-03-27
Researcher: AI Copilot Researcher

## Architecture

```
Inbox Vue → POST /copilot/analyze (NestJS, non-streaming)
              → parallel: sentiment + summary + KB articles → JSON

Inbox Vue → GET /copilot/draft (NestJS, SSE streaming)
              → embed messages → pgvector search → OpenAI stream → SSE tokens
```

## 3 NestJS Endpoints
1. `POST /copilot/analyze` — sentiment, urgency, summary, KB articles (batch, non-streaming)
2. `GET /copilot/draft` — reply draft via SSE streaming (OpenAI stream: true)
3. `POST /copilot/feedback` — acceptance rate tracking

## UX: Collapsible Sidebar (not ghost text)
- Sidebar panel with: sentiment badge, summary, draft area, KB article cards
- Toggle via wand icon button, persist in localStorage
- Reply draft in separate textarea with "Use this reply" button
- Streaming: append tokens to reactive ref, blinking cursor, action buttons on complete

## Ship Sequence (by risk/value)
1. KB article suggestions — zero hallucination, high acceptance
2. Reply draft with streaming — highest agent value
3. Sentiment badge — quick visual triage
4. Conversation summary — least urgent

## Competitor Reference
- Intercom Fin: sidebar panel, RAG across KB + past conversations, 31% more closures
- Freshdesk Freddy: ghost text injection, accept/rephrase/tone change
- Tidio Lyro: inline panel, powered by Claude

## Metrics
| Metric | Target | Alert |
|---|---|---|
| Acceptance rate | >40% | <20% for 3 days |
| Time-to-first-reply | -30% | +10% regression |
| Hallucination rate | <3% | >5% weekly |
| Draft TTFT p95 | <800ms | >2s |
| Usage rate | >60% of human_active | <30% |

## Pitfalls
- Filter KB chunks by subscription_uuid — never leak cross-tenant
- Truncate messages to 3000 tokens max
- SSE keepalive every 10s, 30s timeout
- Call NestJS directly from Vue (not through Laravel proxy) for streaming
- Rate limit: 1 draft/conversation/5s
- Re-embed KB on document update

## Prompt Strategy
Context order: last 10 messages → CRM summary → top 3 KB chunks → persona
System: "Draft helpful reply. Cite sources. Don't invent information."

## New DB Table
```sql
cb_copilot_suggestions (id, conversation_id, subscription_uuid, suggestion_type,
  draft_id, action, kb_chunks_used, response_time_ms, created_at)
```
