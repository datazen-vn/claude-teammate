# /feature — Triển Khai Feature (Full Lifecycle)

Tech Lead. Full lifecycle: Learn → Advisory → Decision → Engineering → Review → Ship → Retrospective.

## Input
$ARGUMENTS

## Phase 0: Learn From Past

**Đọc `./LESSONS.md` TRƯỚC KHI làm bất kỳ gì.** Scan bài học từ features trước:
- Có lesson nào liên quan feature này không?
- Có process change nào cần apply?
- Có gotcha nào cần tránh?

Nếu LESSONS.md chưa tồn tại → tạo mới với template từ handbook.

## Phase 1: Advisory Analysis

Spawn advisory agents **SONG SONG** (dùng web search + codebase scan):

**Strategy Analyst:**
- Đánh giá: user value, market context, differentiation, priority, monetization
- Search competitors, industry trends
- Output: VALUE rating + DIFFERENTIATION level + RECOMMENDATION

**Legal & Compliance Analyst:**
- Đánh giá: data privacy, platform policies, consent, data retention, regulations
- Search relevant laws + Meta Platform Terms
- Output: RISK LEVEL + ISSUES + REQUIRED ACTIONS

**UX Analyst** (nếu feature có UI):
- Đánh giá: user flow, consistency, edge states, mobile, accessibility
- Output: flow critique + suggestions

Advisory agents message nhau nếu findings liên quan:
- Strategy thấy competitor có cách làm hay → share Legal check compliance
- Legal thấy data concern → share Strategy đánh giá impact lên user value

## Phase 2: Decision

Lead tổng hợp advisory → quyết định:

```
High value + No risk       → Triển khai ngay (Phase 3)
High value + Legal risk    → Escalate CEO kèm analysis
Breakthrough potential     → Escalate CEO kèm strategy brief
Platform policy violation  → BLOCK — resolve trước
Low value                  → Defer hoặc reject — document reasoning
Unclear                    → Spawn thêm research
```

Nếu triển khai → present kèm advisory summary cho user. Chờ approve.

## Phase 3: Technical Planning

1. Scan codebase relevant areas
2. Break thành tasks:
   - Dependency graph
   - Parallel groups (waves)
   - Peer review pairs
   - Handoff points
3. Present plan cho user. Chờ approve.

## Phase 4: Engineering Execution

Mỗi wave:
1. Spawn engineering teammates
2. Teammates tự phối hợp: code → self-verify → peer review → handoff
3. Lead chỉ intervene khi conflict/blocked
4. Wave gate: all tasks DONE → next wave

## Phase 5: Final Review

1. Engineering: cross-project verify, all tests pass
2. **Legal Analyst re-review:** data flow implementation đúng như analyzed?
3. **UX Analyst review** (nếu có UI): output match recommendations?
4. **Strategy Analyst confirm:** shipped feature đúng scope/value đã assess?

Nếu review phát hiện issue → fix loop → re-review.

## Phase 6: Ship

Final report:
```
## Feature: [tên]

### Advisory Summary
- Strategy: [value] / [differentiation] / [recommendation]
- Legal: [risk level] / [actions taken]
- UX: [assessment]

### Implementation
- Files: [list per project]
- Key decisions: [list]
- Tests: [status]

### Post-Launch
- Legal actions remaining: [list nếu có]
- Metrics to track: [từ Strategy]
- Known limitations: [list]
- Deploy steps: [instructions]
```

## Phase 7: Retrospective (KHÔNG SKIP)

Thu thập từ teammates + self-review → append vào `./LESSONS.md`:

1. **Hỏi teammates** trước khi shutdown: "gotchas? better approach? missing context?"
2. **Self-review:** planning đúng? coordination smooth? quality đủ? advisory accurate?
3. **Ghi LESSONS.md:** went well, went wrong, lesson, process change
4. **Update handbook** nếu lesson dẫn đến thay đổi quy trình cụ thể
5. **Report user:** "X lessons learned, Y process changes applied"
