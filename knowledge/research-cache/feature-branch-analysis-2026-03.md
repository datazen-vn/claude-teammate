# Feature Branch Analysis — March 2026

Date: 2026-03-27
Analyst: Feature Analyst (Explore agent)

## Summary
- 19 branches analyzed across chatbot-nestjs (12) and datazen (7)
- 9 ready to ship now, 4 next sprint, 4 backlog, 1 needs decision
- 4 merge conflict pairs identified

## Ship Now (9 branches)
chatbot-nestjs: orchestrator-guard, knowledge-callback, xlsx-upload, encrypt-cache, ig-comment, rag-sync
datazen: comment-optimize, fb-review, legal-consent

## Next Sprint (4 branches)
- zalo-oa-integration (6 commits, debugging phase)
- optimize-system-prompt (21 commits, 69 files — schema conflict risk)
- crm-inline-editable-table-v4 (16 commits, 208 files)
- workspace/w3 (52 commits, 583 files — integration workspace)

## Merge Conflicts
- optimize-prompt ↔ legal-consent-schema (prisma/schema.prisma)
- xlsx-upload ↔ quota-tracking (knowledge processor)
- crm-table-v4 ↔ workspace/w3 (multiple CRM files)
- workspace/w3 ↔ workspace/w8 (CRM components)

## Merge Order
chatbot-nestjs: rag-sync → encrypt-cache → knowledge-callback → ig-comment → xlsx-upload → orchestrator-guard
datazen: comment-optimize → fb-review → legal-consent → message-management

## Needs Decision
- schema-builder-field-config-ui: 148 commits, stale 82 days, no merge base — investigate or archive
- dev-crm: 80 files but 0 tests — needs test suite before merge
