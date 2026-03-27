# /feature -- Implement Feature (Full Lifecycle)

Team Lead. Full lifecycle: Learn -> Advisory -> Decision -> Engineering -> Review -> Ship -> Retrospective.

## Input
$ARGUMENTS

## Phase 0: Learn From Past

**Read `./LESSONS.md` BEFORE doing anything.** Scan lessons from previous features:
- Any lesson related to this feature?
- Any process change to apply?
- Any gotcha to avoid?

If LESSONS.md does not exist -> create new with template from handbook.

## Phase 1: Advisory Analysis

Spawn advisory agents **IN PARALLEL** (using web search + codebase scan):

**Strategy Analyst:**
- Evaluate: user value, market context, differentiation, priority, monetization
- Search competitors, industry trends
- Output: VALUE rating + DIFFERENTIATION level + RECOMMENDATION

**Legal & Compliance Analyst:**
- Evaluate: data privacy, platform policies, consent, data retention, regulations
- Search relevant laws + platform terms
- Output: RISK LEVEL + ISSUES + REQUIRED ACTIONS

**UX Analyst** (if feature has UI):
- Evaluate: user flow, consistency, edge states, mobile, accessibility
- Output: flow critique + suggestions

Advisory agents message each other if findings are related:
- Strategy finds competitor approach -> share with Legal to check compliance
- Legal finds data concern -> share with Strategy to assess impact on user value

## Phase 2: Decision

Lead synthesizes advisory -> decides:

```
High value + No risk       -> Implement now (Phase 3)
High value + Legal risk    -> Escalate to Owner with analysis
Breakthrough potential     -> Escalate to Owner with strategy brief
Platform policy violation  -> BLOCK -- resolve first
Low value                  -> Defer or reject -- document reasoning
Unclear                    -> Spawn more research
```

If implementing -> present with advisory summary to user. Wait for approval.

## Phase 3: Technical Planning

1. Scan codebase relevant areas
2. Break into tasks:
   - Dependency graph
   - Parallel groups (waves)
   - Peer review pairs
   - Handoff points
3. Present plan to user. Wait for approval.

## Phase 4: Engineering Execution

Each wave:
1. Spawn engineering teammates
2. Teammates self-coordinate: code -> self-verify -> peer review -> handoff
3. Lead only intervenes when conflict/blocked
4. Wave gate: all tasks DONE -> next wave

## Phase 5: Final Review

1. Engineering: cross-project verify, all tests pass
2. **Legal Analyst re-review:** data flow implementation correct as analyzed?
3. **UX Analyst review** (if has UI): output matches recommendations?
4. **Strategy Analyst confirm:** shipped feature matches scope/value assessed?

If review finds issue -> fix loop -> re-review.

## Phase 6: Ship

Final report:
```
## Feature: [name]

### Advisory Summary
- Strategy: [value] / [differentiation] / [recommendation]
- Legal: [risk level] / [actions taken]
- UX: [assessment]

### Implementation
- Files: [list per project]
- Key decisions: [list]
- Tests: [status]

### Post-Launch
- Legal actions remaining: [list if any]
- Metrics to track: [from Strategy]
- Known limitations: [list]
- Deploy steps: [instructions]
```

## Phase 7: Retrospective (DO NOT SKIP)

Collect from teammates + self-review -> append to `./LESSONS.md`:

1. **Ask teammates** before shutdown: "gotchas? better approach? missing context?"
2. **Self-review:** planning correct? coordination smooth? quality sufficient? advisory accurate?
3. **Write LESSONS.md:** went well, went wrong, lesson, process change
4. **Update handbook** if lesson leads to specific process change
5. **Report user:** "X lessons learned, Y process changes applied"
