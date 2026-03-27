# /test — Test Suite

Tech Lead. Spawn test team. Testers cover từng layer, share test fixtures + edge cases với nhau.

## Input
$ARGUMENTS

## Execution
1. Xác định scope → spawn testers theo layer (unit / integration / API / E2E)
2. Testers:
   - Follow existing test patterns trong codebase
   - **Share edge cases:** "found boundary case X, bạn cover chưa?"
   - **Share fixtures:** "tạo mock data ở path Y, dùng chung"
3. Lead aggregate results:
```
Total: X | Pass: Y | Fail: Z
Issues: [list with severity]
```
