# Team Lessons Learned

Every entry is a lesson from the implementation process.
Lead + Teammates read this file BEFORE starting any new task.

---

## Entry Types

### Feature Retrospective

```markdown
## [date] -- [feature/task name]

### Went Well
- [what worked well, keep doing]

### Went Wrong
- [what went wrong, root cause]

### Lesson
- [specific, actionable lesson]

### Process Change
- [specific process change for next time]

### Velocity Tracking
- Feature: [name]
- Time: [how long]
- Generator used: [which, % auto-generated code]
- Manual code: [% hand-written]
- Comparison to similar previous feature: [how much faster %]
- New generator created/improved: [what]
- New pattern extracted: [what]
- Research cached: [what]
```

### Self-Improvement Entry

```markdown
## [date] -- SELF-IMPROVEMENT

### Trigger
[pattern detected -- specific]

### Change Applied
[file + section + before/after]

### Expected Impact
[what this prevents in future]
```

---

## 2026-03-27 -- Message Management Inbox (Session 1)

### Went Well
- Parallel teammate spawning highly effective — 2 Frontend Engineers + 1 Backend Engineer + 1 Code Reviewer ran simultaneously
- Code Reviewer found 3 P0 bugs before merge — saved production incidents (fatal import, daemon crash, missing validation)
- Advisory agents (UX + Strategy) provided comprehensive analysis — 31 UX issues + competitor feature gap matrix
- Knowledge extraction during wait time — 3 patterns, 1 decision, 2 research caches created
- Backend Engineer fixed all P0s + P1s in single commit with clean separation

### Went Wrong
- Frontend Engineer B hit API 529 overloaded — lost work, had to respawn
- Scanner-datazen timed out — need shorter, more focused scans for large codebases
- CLAUDE.md had placeholder architecture data — teammates had to scan codebase from scratch every time
- Projects (chatbot-nestjs, datazen) not in .gitignore — could have been accidentally committed to claude-teammate repo
- Strategy Analyst found Canned Responses/Notes UI "missing" because it looked at main branch instead of feat branch — misleading finding

### Lesson
- Always scan codebase BEFORE spawning engineering teammates — populate CLAUDE.md with real architecture so teammates don't waste tokens re-scanning
- When spawning advisory/research agents, specify which branch to analyze — default is main, feature work is on feature branches
- API overload (529) will happen — design tasks so work isn't lost (commit early, smaller batches)
- Large monorepo scans (datazen) should be split into module-specific scans — one agent per major module
- Code Review before merge is non-negotiable — found InboxDataService fatal import that would crash production

### Process Change
- NEW: Update CLAUDE.md architecture sections with real data BEFORE first feature session
- NEW: Add .gitignore entries for project dirs immediately on setup
- NEW: Code Reviewer must specify branch to review (not just "the branch")
- NEW: Split large codebase scans into focused module scans (max 5-10 files per scan)
- NEW: When agent hits 529/timeout, respawn with smaller scope instead of same prompt

### Velocity Tracking
- Feature: Message Management Inbox (completion)
- Time: ~1 session (setup + 2 waves + advisory + knowledge extraction)
- Generator used: None (0% auto-generated)
- Manual code: 100% hand-written by teammates
- New pattern extracted: inbox-realtime-page, laravel-nestjs-proxy, nestjs-crud-with-softdelete
- New decision documented: multi-tenant-realtime-bridge
- Research cached: competitor-analysis (7 competitors), ux-audit (31 issues)

---

## 2026-03-27 -- SELF-IMPROVEMENT

### Trigger
CLAUDE.md had placeholder "example-api" and "example-web" — every teammate had to scan codebase from scratch, wasting tokens and time.

### Change Applied
- File: CLAUDE.md, sections: Projects, Architecture, Code Standards, Verification
- Before: Generic placeholder text ("example-api", "Describe the main patterns")
- After: Real architecture data from deep scan (25 modules, dual DB, BullMQ queues, specific patterns)

### Expected Impact
- Teammates start with full architecture context — no re-scanning needed
- Faster feature delivery — teammates understand patterns before coding
- Better code quality — teammates follow documented conventions instead of guessing
