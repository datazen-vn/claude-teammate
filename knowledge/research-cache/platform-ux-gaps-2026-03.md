# Platform UX Gaps Scan — March 2026

Date: 2026-03-27
Scanned: 241 Vue pages across all modules

## Top ROI Fixes
1. Analytics dashboard/Index.vue — empty page, renders nothing
2. Subscription migration/Pending.vue — no polling/auto-redirect
3. 8+ pages with bg-white hardcoded, no dark mode
4. ~65 DzDataView Index pages missing custom empty slots
5. 2 ChatBot pages missing fetch error handling

## Dark Mode Gaps (trivial: bg-white → bg-white dark:bg-neutral-950)
- Analytics: revenue/Index.vue, stayingGuest/Index.vue
- Auth: Login.vue
- CRM: customer/Edit.vue
- LegalConsent: documentVersion/Edit.vue
- ProjectManager: task/Show.vue, testCase/Show.vue, workflow/Show.vue
- ChatBot: fbReview/Messenger.vue, PagePosts.vue

## Missing Empty States (trivial: add template #empty slot)
- Auth: admin, permission, role, tenant Index pages (4)
- Subscription: appStore/Index.vue
- ALL DzDataView Index pages (~65 pages) — generic empty, no CTA

## Missing Error Handling
- ChatBot: WebhookLogs.vue, PagePosts.vue — fetch without try/catch

## Missing Polling
- Subscription: migration/Pending.vue — static waiting screen
