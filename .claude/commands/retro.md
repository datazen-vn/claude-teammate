# /retro -- Retrospective

Team Lead. Review the process just completed, extract lessons, update procedures.

## Input
$ARGUMENTS
(e.g., "user auth feature", "last session", "API integration bugs")

## Execution

### Step 1: Collect data
- Read LESSONS.md (previous lessons)
- Review task list: what completed, what delayed, what failed
- Review teammate reports: gotchas, better approaches, missing context
- Review code review findings: repeating patterns
- If need details -> spawn teammate to scan git log, diff, issues

### Step 2: Analyze
Self-ask:
- **Planning:** task breakdown correct? dependencies missed? estimates wrong?
- **Coordination:** bottleneck where? handoff smooth? teammates idle?
- **Quality:** which bugs slipped? tests missing? review miss anything?
- **Advisory:** analysis correct? legal miss anything? UX suggestions followed?
- **Efficiency:** slowest step? token waste?

### Step 3: Write LESSONS.md
Append new entry:
```markdown
## [date] -- [feature/task]

### Went Well
- ...

### Went Wrong
- ...

### Lesson
- ...

### Process Change
- ...
```

### Step 4: Update procedures
If lesson leads to specific change:
- Update **CLAUDE.md** (handbook) -- add rule, checklist item, warning
- Update **slash commands** -- add step, adjust flow
- Clearly tell user what was changed and why

### Output
```
## Retrospective: [feature/task]

Lessons: X new
Process changes: [specific list of updates made]
Top insight: [1 most important lesson]
```
