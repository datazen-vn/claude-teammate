# UX Audit: Inbox Page — March 2026

Analyzed by: UX Analyst
Date: 2026-03-27

---

## Summary

31 issues found: 3 CRITICAL, 7 HIGH, 11 MEDIUM, 10 LOW

## Critical Issues (Must Fix Before Production)

1. **Transfer Dialog uses raw Staff ID input** — must be searchable dropdown
2. **No retry for failed messages** — user must retype
3. **No empty state when transfer has no available staff**

## High Issues (Fix Soon)

1. Mobile navigation — no breadcrumb, back button too small
2. No keyboard shortcuts (Cmd+S send, Cmd+T takeover)
3. Polling has no visual feedback
4. Transfer dialog has no focus trap / ARIA labels
5. Mark Read button disappears without confirmation

## Key Recommendations (Prioritized)

### Phase 1 — Before Production
- Replace transfer staff input with searchable dropdown
- Add retry button for failed messages
- Add ARIA labels + focus management to dialogs

### Phase 2 — Polish
- Virtualize conversation list (for 100+ items)
- Add "scroll to bottom" button
- Keyboard navigation for conversation list items
- Toast notifications for actions (takeover, release, transfer)

### Phase 3 — Nice to Have
- Lazy load image attachments
- Message search within conversation
- Conversation sorting options
- Mark all as read
- Conversation archiving

## Testing Checklist

- [ ] Transfer dialog with 0, 1, 10+ staff members
- [ ] Failed message send + retry flow
- [ ] Mobile responsive on iPhone SE, iPad, desktop
- [ ] Keyboard Tab/Enter/Escape navigation
- [ ] Screen reader (VoiceOver/NVDA)
- [ ] Color contrast WCAG AA for all badges
- [ ] 500+ conversations — performance
- [ ] Very long names, messages, URLs
- [ ] Dark mode contrast
- [ ] Slow network (3G throttle)
