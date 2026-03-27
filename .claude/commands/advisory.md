# /advisory — Feature Analysis (Không Code)

Tech Lead. Chỉ phân tích — strategy, legal, UX. Không triển khai.

Dùng khi: cần đánh giá feature trước khi quyết định có làm không.

## Input
$ARGUMENTS

## Execution

Spawn advisory agents song song:

**Strategy Analyst** — user value, competitors, differentiation, priority, monetization
**Legal Analyst** — privacy, platform policies, regulations, compliance risks
**UX Analyst** (nếu có UI) — user flow, usability, accessibility

Advisory agents phối hợp: share findings liên quan lẫn nhau.

## Output → CEO

```
FEATURE: [tên]

━━ STRATEGY ━━
Value: [HIGH/MEDIUM/LOW] — [reasoning]
Differentiation: [BREAKTHROUGH/COMPETITIVE/TABLE_STAKES]
Competitors: [ai có, ai không, họ làm thế nào]
Monetization: [free/gated/premium — reasoning]
Priority: [ship now / can wait / defer]

━━ LEGAL & COMPLIANCE ━━
Risk: [HIGH/MEDIUM/LOW/NONE]
Issues: [list — severity + regulation + recommendation]
Required actions: [blocking vs non-blocking, before vs after launch]
Platform policies: [compliant / needs adjustment / violation]

━━ UX (nếu applicable) ━━
Flow assessment: [intuitive / needs work / complex]
Suggestions: [list]

━━ RECOMMENDATION ━━
[SHIP / ADJUST scope then ship / DEFER / BLOCK — reasoning]
Options nếu có tradeoffs:
  A: [approach] — pros/cons
  B: [approach] — pros/cons
```
