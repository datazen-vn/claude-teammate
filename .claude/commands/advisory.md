# /advisory -- Feature Analysis (No Code)

Team Lead. Analysis only -- strategy, legal, UX. No implementation.

Use when: need to evaluate a feature before deciding whether to build it.

## Input
$ARGUMENTS

## Execution

Spawn advisory agents in parallel:

**Strategy Analyst** -- user value, competitors, differentiation, priority, monetization
**Legal Analyst** -- privacy, platform policies, regulations, compliance risks
**UX Analyst** (if has UI) -- user flow, usability, accessibility

Advisory agents coordinate: share related findings with each other.

## Output -> Owner

```
FEATURE: [name]

== STRATEGY ==
Value: [HIGH/MEDIUM/LOW] -- [reasoning]
Differentiation: [BREAKTHROUGH/COMPETITIVE/TABLE_STAKES]
Competitors: [who has it, who does not, how they do it]
Monetization: [free/gated/premium -- reasoning]
Priority: [ship now / can wait / defer]

== LEGAL & COMPLIANCE ==
Risk: [HIGH/MEDIUM/LOW/NONE]
Issues: [list -- severity + regulation + recommendation]
Required actions: [blocking vs non-blocking, before vs after launch]
Platform policies: [compliant / needs adjustment / violation]

== UX (if applicable) ==
Flow assessment: [intuitive / needs work / complex]
Suggestions: [list]

== RECOMMENDATION ==
[SHIP / ADJUST scope then ship / DEFER / BLOCK -- reasoning]
Options if tradeoffs exist:
  A: [approach] -- pros/cons
  B: [approach] -- pros/cons
```
