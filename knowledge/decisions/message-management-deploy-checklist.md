# Production Deploy Checklist: Message Management Inbox

Date: 2026-03-27
Feature: feat/message-management (datazen + chatbot-nestjs)

---

## Pre-Deploy

### Database Migrations (MUST run on each tenant DB)

```sql
-- 1. Canned Responses table (run on EACH tenant database)
-- File: chatbot-nestjs/database_structures/migrations/canned_responses_setup.sql

CREATE TABLE IF NOT EXISTS cb_canned_responses (
  id BIGSERIAL PRIMARY KEY,
  subscription_uuid VARCHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  shortcut VARCHAR(50) NULL,
  category VARCHAR(100) NULL,
  tags JSONB NOT NULL DEFAULT '[]',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_by VARCHAR(255) NOT NULL,
  created_by_name VARCHAR(255) NULL,
  updated_by VARCHAR(255) NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  deleted_at BIGINT NULL
);
CREATE INDEX IF NOT EXISTS idx_canned_sub ON cb_canned_responses (subscription_uuid);
CREATE INDEX IF NOT EXISTS idx_canned_sub_category ON cb_canned_responses (subscription_uuid, category);
CREATE INDEX IF NOT EXISTS idx_canned_sub_active ON cb_canned_responses (subscription_uuid, is_active);
CREATE UNIQUE INDEX IF NOT EXISTS uq_canned_sub_shortcut ON cb_canned_responses (subscription_uuid, shortcut) WHERE deleted_at IS NULL AND shortcut IS NOT NULL;


-- 2. Conversation Notes table (run on EACH tenant database)
-- File: chatbot-nestjs/database_structures/migrations/conversation_notes_setup.sql

CREATE TABLE IF NOT EXISTS cb_conversation_notes (
  id BIGSERIAL PRIMARY KEY,
  conversation_id BIGINT NOT NULL,
  subscription_uuid VARCHAR(36) NOT NULL,
  content TEXT NOT NULL,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  created_by VARCHAR(255) NOT NULL,
  created_by_name VARCHAR(255),
  updated_by VARCHAR(255),
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  deleted_at BIGINT
);
CREATE INDEX IF NOT EXISTS idx_conv_note_conv ON cb_conversation_notes (conversation_id);
CREATE INDEX IF NOT EXISTS idx_conv_note_sub ON cb_conversation_notes (subscription_uuid);
CREATE INDEX IF NOT EXISTS idx_conv_note_pinned ON cb_conversation_notes (conversation_id, is_pinned, created_at) WHERE deleted_at IS NULL;
```

### Laravel Migration (Central DB)
```bash
cd datazen && php artisan migrate
# Runs: 2026_03_26_120000_add_inbox_menu_items.php
# Adds "Inbox" menu item to ChatBot sidebar
```

### Start Redis Subscriber Daemon
```bash
# New daemon required for real-time messaging
php artisan chatbot:message-subscribe
# Run with supervisor for auto-restart
# Has reconnection logic with exponential backoff
```

---

## Deploy Steps

### 1. datazen (Laravel + Vue)
```bash
git checkout main
git merge feat/message-management
npm install && npm run build    # Build Vue frontend
php artisan migrate             # Run menu migration
php artisan config:cache        # Clear config cache
php artisan route:cache         # Clear route cache
```

### 2. Start daemon
```bash
# Add to supervisor config:
[program:inbox-subscriber]
command=php artisan chatbot:message-subscribe
autostart=true
autorestart=true
stderr_logfile=/var/log/inbox-subscriber.err.log
stdout_logfile=/var/log/inbox-subscriber.out.log
```

### 3. chatbot-nestjs (if not already deployed)
- Backend APIs already on main — no deploy needed
- Only run tenant DB migrations (canned_responses + conversation_notes)

---

## Post-Deploy Smoke Tests

### Page Load
- [ ] Navigate to {tenant}/app/chatbot/inbox — page loads
- [ ] 2-panel layout visible (conversation list + messages)
- [ ] "Inbox" appears in sidebar navigation
- [ ] Empty state shows when no conversations

### Conversation List
- [ ] Conversations display with avatars, names, timestamps
- [ ] Platform badges show (Facebook, Instagram, Zalo)
- [ ] Unread count badges display
- [ ] State badges show (bot_active, human_active)
- [ ] Scroll pagination loads more

### Filters
- [ ] Filter by state works (All/Bot Active/Human Active)
- [ ] Filter by platform works (All/Facebook/Instagram/Zalo)
- [ ] Search filters conversations
- [ ] Clear filters resets all

### Messaging
- [ ] Select conversation → messages load
- [ ] Messages show role badges, timestamps, sent-via
- [ ] Attachments display (images inline, files as links)
- [ ] Load older messages works

### Send Message (requires human_active conversation)
- [ ] Message input visible when human_active
- [ ] Send message → appears in chat
- [ ] Optimistic update shows immediately
- [ ] Failed message shows retry + dismiss

### Takeover / Release
- [ ] Takeover button visible on bot_active conversation
- [ ] Takeover → state changes to human_active
- [ ] Release → state returns to bot_active

### Transfer
- [ ] Transfer button visible when human_active
- [ ] Dialog opens with ARIA attributes
- [ ] Staff search input works (or manual fallback)
- [ ] Escape closes dialog

### Canned Responses
- [ ] "/" in message input opens picker
- [ ] Search filters responses
- [ ] Select inserts text
- [ ] CRUD: create, edit, delete

### Conversation Notes
- [ ] Tab switch Messages/Notes works
- [ ] Create note
- [ ] Pin/unpin
- [ ] Delete note

### Customer Context Sidebar
- [ ] Toggle button shows/hides sidebar
- [ ] CRM data displays if available
- [ ] Empty state if no CRM data
- [ ] Responsive on mobile (overlay)

### Real-time
- [ ] New message from user appears without refresh
- [ ] Typing indicator shows
- [ ] State changes reflect in real-time
- [ ] Polling fallback works (every 15s)

### Notifications
- [ ] Unread count in page title
- [ ] Sound on new message
- [ ] Toast notifications for actions

### Responsive
- [ ] Mobile: single panel view
- [ ] Back button navigates list ↔ chat
- [ ] Sidebar is overlay on mobile

### UX Polish
- [ ] Scroll-to-bottom button appears when scrolled up
- [ ] Images lazy load
- [ ] Toast shows on takeover/release/transfer
- [ ] Empty states have icons and helpful text

---

## Rollback Plan

If critical issues found:
```bash
git revert HEAD    # Revert merge commit
npm run build      # Rebuild without inbox
php artisan migrate:rollback --step=1   # Remove menu item
# Stop supervisor inbox-subscriber
```

---

## Monitor After Deploy

- Check Laravel logs: `storage/logs/laravel.log`
- Check daemon logs: `/var/log/inbox-subscriber.err.log`
- Check Redis connection: `redis-cli ping`
- Check NestJS health: `curl http://nestjs:3000/health`
- Monitor: error rate, response time, WebSocket connections
