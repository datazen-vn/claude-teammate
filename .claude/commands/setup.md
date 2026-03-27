# /setup -- First-Time Workspace Setup

Team Lead. Run once when starting a new workspace. Auto-detect environment, verify toolchain, configure settings.

## Input
$ARGUMENTS
(Optional: project paths, special requirements)

## Execution

### Step 1: Detect Projects
- Scan current directory for projects (package.json, composer.json, Cargo.toml, go.mod, pyproject.toml...)
- Determine stack for each project (NestJS, Laravel, Next.js, Django, Rails, etc.)
- Update CLAUDE.md: fill in Projects table, Architecture overview, Code Standards, Verification commands
- Read CLAUDE.md/README/docs of each project -> extract conventions

### Step 2: Configure MCP (.mcp.json)
Detect and setup MCP servers appropriate for workspace:

```
If .git exists -> setup GitHub MCP:
  - Check: gh auth status (GitHub CLI)
  - Or: read GITHUB_TOKEN from env
  - Or: ask user for token once

If database exists (Prisma/TypeORM/Laravel migrations/Django models) -> setup Postgres MCP:
  - Check: .env files for DB connection strings
  - Or: docker-compose.yml for DB config

If project is complex -> setup Memory MCP:
  - Persistent knowledge graph for cross-session context

Always setup Filesystem MCP:
  - Root = workspace directory
```

Create `.mcp.json` with detected servers. Skip servers not needed.

### Step 3: Verify Toolchain
Run checks:
```
- Node.js version
- npm/pnpm/yarn available
- PHP/Composer (if Laravel/PHP project)
- Python/pip (if Python project)
- Docker (if docker-compose exists)
- Git configured
- tmux (for split-pane agent teams)
- DB connection test (if setup Postgres MCP)
```

### Step 4: Scan Codebase Conventions
For each project:
- Read existing CLAUDE.md in project (if exists)
- Scan code patterns: naming, imports, error handling, test framework
- Record in workspace CLAUDE.md

### Step 5: Verify Agent Team Ready
- Confirm settings.json has AGENT_TEAMS flag
- Confirm permissions are sufficient (Bash(*), Read(*), Write(*), Edit(*))
- Test spawn 1 subagent quickly -> verify working
- Confirm agents/ directory has subagents

### Step 6: Init LESSONS.md
- Create if does not exist
- If exists -> read and summarize lessons for user

### Output
```
## Workspace Setup Complete

Projects: [list with stacks]
MCP Servers: [list configured]
Toolchain: [all checks pass/fail]
Agent Teams: [ready/issues]
LESSONS.md: [initialized/X existing lessons]

Ready to go. Use /feature, /scan, /review, /debug, /test.
```
