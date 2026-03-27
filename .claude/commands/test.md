# /test -- Test Suite

Team Lead. Spawn test team. Testers cover each layer, share test fixtures + edge cases with each other.

## Input
$ARGUMENTS

## Execution
1. Determine scope -> spawn testers by layer (unit / integration / API / E2E)
2. Testers:
   - Follow existing test patterns in codebase
   - **Share edge cases:** "found boundary case X, have you covered it?"
   - **Share fixtures:** "created mock data at path Y, use it"
3. Lead aggregates results:
```
Total: X | Pass: Y | Fail: Z
Issues: [list with severity]
```
