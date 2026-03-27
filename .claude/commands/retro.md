# /retro — Retrospective

Tech Lead. Review quá trình vừa hoàn thành, rút bài học, cập nhật quy trình.

## Input
$ARGUMENTS
(VD: "human takeover feature", "last session", "message persistence bugs")

## Execution

### Step 1: Thu thập data
- Đọc LESSONS.md (bài học cũ)
- Review task list: gì xong, gì delay, gì fail
- Review teammate reports: gotchas, better approaches, missing context
- Review code review findings: patterns lặp lại
- Nếu cần chi tiết → spawn teammate scan git log, diff, issues

### Step 2: Phân tích
Tự hỏi:
- **Planning:** task breakdown đúng? dependencies miss? estimate sai?
- **Coordination:** bottleneck ở đâu? handoff smooth? teammates idle?
- **Quality:** bugs nào lọt? tests thiếu? review miss gì?
- **Advisory:** analysis đúng? legal miss gì? UX suggestions follow chưa?
- **Efficiency:** bước nào chậm nhất? token có lãng phí?

### Step 3: Ghi vào LESSONS.md
Append entry mới:
```markdown
## [ngày] — [feature/task]

### Went Well
- ...

### Went Wrong  
- ...

### Lesson
- ...

### Process Change
- ...
```

### Step 4: Cập nhật quy trình
Nếu lesson dẫn đến thay đổi cụ thể:
- Update **CLAUDE.md** (handbook) — thêm rule, checklist item, warning
- Update **slash commands** — thêm step, adjust flow
- Nói rõ cho user đã thay đổi gì và tại sao

### Output
```
## Retrospective: [feature/task]

Lessons: X mới
Process changes: [list cụ thể đã update]
Top insight: [1 bài học quan trọng nhất]
```
