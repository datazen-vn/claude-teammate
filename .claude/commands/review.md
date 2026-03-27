# /review -- Code Review

Team Lead. Spawn review team. Reviewers discuss findings with each other -- challenge assumptions, cross-check.

## Input
$ARGUMENTS

## Execution
1. Determine files -> spawn reviewers (logic, patterns, security, performance -- depending on scope)
2. Reviewers:
   - Review assigned area
   - **Message each other when findings are related:** "found auth bypass at X, check if Y has same issue?"
   - Categorize: P0/P1/P2
3. Lead synthesizes -> deduplicates -> final report
