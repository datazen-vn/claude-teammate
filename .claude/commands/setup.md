# /setup — First-Time Workspace Setup

Tech Lead. Chạy 1 lần khi bắt đầu workspace mới. Auto-detect environment, configure MCP, verify toolchain.

## Input
$ARGUMENTS
(Optional: project paths, special requirements)

## Execution

### Step 1: Detect Projects
- Scan thư mục hiện tại, tìm projects (package.json, composer.json, Cargo.toml, go.mod...)
- Xác định stack từng project (NestJS, Laravel, Next.js, etc.)
- Update CLAUDE.md: điền bảng Projects, Architecture overview, Code Standards, Verification commands
- Đọc CLAUDE.md/README/docs của từng project → extract conventions

### Step 2: Configure MCP (.mcp.json)
Detect và setup MCP servers phù hợp với workspace:

```
Nếu có .git → setup GitHub MCP:
  - Check: gh auth status (GitHub CLI)
  - Hoặc: đọc GITHUB_TOKEN từ env
  - Hoặc: hỏi user token 1 lần

Nếu có database (Prisma/TypeORM/Laravel migrations) → setup Postgres MCP:
  - Check: .env files cho DB connection strings
  - Hoặc: docker-compose.yml cho DB config

Nếu project phức tạp → setup Memory MCP:
  - Persistent knowledge graph cho cross-session context

Luôn setup Filesystem MCP:
  - Root = workspace directory
```

Tạo `.mcp.json` với servers detected. Bỏ qua servers không cần.

### Step 3: Verify Toolchain
Chạy checks:
```
- Node.js version
- npm/pnpm/yarn available
- PHP/Composer (nếu Laravel)
- Docker (nếu có docker-compose)
- Git configured
- tmux (cho split-pane agent teams)
- DB connection test (nếu setup Postgres MCP)
```

### Step 4: Scan Codebase Conventions
Cho mỗi project:
- Đọc existing CLAUDE.md trong project (nếu có)
- Scan code patterns: naming, imports, error handling, test framework
- Ghi nhận vào workspace CLAUDE.md

### Step 5: Verify Agent Team Ready
- Confirm settings.json có AGENT_TEAMS flag
- Confirm permissions đủ (Bash(*), Read(*), Write(*), Edit(*))
- Test spawn 1 subagent nhanh → verify hoạt động
- Confirm agents/ directory có subagents

### Step 6: Init LESSONS.md
- Tạo nếu chưa có
- Nếu đã có → đọc và summarize lessons cho user

### Output
```
## Workspace Setup Complete

Projects: [list với stack]
MCP Servers: [list configured]
Toolchain: [all checks pass/fail]
Agent Teams: [ready/issues]
LESSONS.md: [initialized/X existing lessons]

Ready to go. Dùng /feature, /scan, /review, /debug, /test.
```
