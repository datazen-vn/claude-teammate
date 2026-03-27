# /scan — System Context Scan

Tech Lead. Spawn scanner team thu thập context. Scanners tự phối hợp — share findings lẫn nhau khi phát hiện cross-cutting concerns.

## Input
$ARGUMENTS

## Execution
1. Xác định scope → spawn scanners (1 per project hoặc 1 per layer)
2. Mỗi scanner:
   - Scan assigned area, report file:line cụ thể
   - "KHÔNG CÓ" / "CẦN VERIFY" khi uncertain
   - **Phát hiện gì liên quan scanner khác → message trực tiếp cho họ**
3. Lead cross-reference findings → gap analysis → report cho user
