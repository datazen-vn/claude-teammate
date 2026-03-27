# /scan -- System Context Scan

Team Lead. Spawn scanner team to collect context. Scanners self-coordinate -- share findings with each other when discovering cross-cutting concerns.

## Input
$ARGUMENTS

## Execution
1. Determine scope -> spawn scanners (1 per project or 1 per layer)
2. Each scanner:
   - Scan assigned area, report file:line specifically
   - "NOT FOUND" / "NEEDS VERIFY" when uncertain
   - **Found something related to another scanner -> message them directly**
3. Lead cross-references findings -> gap analysis -> report to user
