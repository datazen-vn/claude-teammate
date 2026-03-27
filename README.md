# Claude Code Team Lead

A reusable Claude Code setup that turns Claude into an autonomous **Engineering VP / Team Lead** who coordinates agent teammates to build features end-to-end.

Instead of one Claude instance doing everything, this setup creates a **team structure**: the Lead plans and coordinates while spawned teammates write code, review, test, and analyze in parallel.

## What This Is

This repository provides:

- **CLAUDE.md** -- A comprehensive engineering handbook that defines the Lead's identity, team protocols, security rules, quality standards, and growth systems
- **Slash commands** (`/feature`, `/review`, `/debug`, etc.) -- Pre-built workflows for common engineering tasks
- **Agent definitions** -- Specialized agents (Strategy Analyst, Legal Analyst, Code Reviewer, QA Gate, generators) that can be spawned as teammates
- **Knowledge system** -- A structured directory for accumulating patterns, generators, decisions, and research
- **Templates** -- Ready-to-use formats for progress tracking, lessons learned, and retrospectives

## How It Works

```
Owner gives request
    |
    v
Lead (Claude) reads handbook + lessons + codebase
    |
    v
Lead spawns advisory agents (Strategy, Legal, UX) -- in parallel
    |
    v
Lead synthesizes analysis -> decides to proceed or escalate
    |
    v
Lead spawns engineering teammates -- in parallel waves
    |
    v
Teammates code -> self-verify -> peer review -> handoff
    |
    v
Lead spawns QA gate + code reviewer
    |
    v
Ship -> Retrospective -> Extract patterns -> Update knowledge
```

## Prerequisites

| Requirement | Required | Notes |
|------------|----------|-------|
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | Yes | The core tool |
| Agent Teams feature | Yes | Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json (already configured) |
| Git | Yes | Version control |
| Node.js | Recommended | For JS/TS projects |
| tmux | Recommended | For split-pane agent teams view |
| GitHub CLI (`gh`) | Optional | For GitHub integration |

## Quick Start

```bash
# 1. Clone the repo
git clone <this-repo-url> my-workspace
cd my-workspace

# 2. Run setup to verify prerequisites
chmod +x setup.sh
./setup.sh

# 3. Edit CLAUDE.md -- fill in YOUR project details
#    - Projects table
#    - Architecture sections
#    - Code Standards
#    - Verification commands

# 4. Copy/symlink your project directories into this workspace
#    my-workspace/
#    +-- my-api/        <- your project
#    +-- my-frontend/   <- your project
#    +-- CLAUDE.md      <- team handbook
#    +-- ...

# 5. Start Claude Code
claude

# 6. Run /setup inside Claude to auto-detect and configure
```

## Slash Commands

| Command | Purpose | When To Use |
|---------|---------|-------------|
| `/setup` | First-time workspace setup | Once, when starting a new workspace |
| `/feature` | Full feature lifecycle (advisory -> plan -> build -> review -> ship -> retro) | Building any new feature |
| `/advisory` | Feature analysis only (strategy + legal + UX) | Evaluating whether to build something |
| `/scan` | System context scan across projects | Understanding codebase state |
| `/review` | Parallel code review | Before merging significant changes |
| `/debug` | Parallel debugging with hypothesis testing | Investigating bugs |
| `/test` | Parallel test suite creation | Adding test coverage |
| `/retro` | Retrospective with lesson extraction | After completing any feature/task |

## Agent Types

### Advisory Agents (Analysis, No Code)

| Agent | Role | Tools |
|-------|------|-------|
| **Strategy Analyst** | Product/business evaluation: user value, competitors, differentiation, monetization | Read, Web Search |
| **Legal Analyst** | Compliance evaluation: GDPR, CCPA, platform policies, AI regulations | Read, Web Search |
| **Researcher** | Deep research: technology, best practices, competitor analysis, API docs | Read, Web Search |

### Engineering Agents (Read + Write Code)

| Agent | Role | Tools |
|-------|------|-------|
| **Page Generator** | Generate full-stack pages from description | Read, Write, Edit, Bash |
| **CRUD Generator** | Generate complete CRUD modules from entity definition | Read, Write, Edit, Bash |
| **Chart Generator** | Generate chart/visualization components | Read, Write, Edit |

### Quality Agents (Read-Only Verification)

| Agent | Role | Tools |
|-------|------|-------|
| **Code Reviewer** | Review code for logic, security, performance, patterns | Read only |
| **QA Gate** | Verify build, lint, types, tests, patterns, regression | Read + Bash |
| **Browser Tester** | GUI verification: rendering, interactions, responsive, accessibility | Read + Bash |

## The Team Lead Role

The Lead (Claude) operates as an **Engineering VP**:

- **Plans** -- breaks features into tasks with dependency graphs
- **Spawns** -- creates specialized teammates for each task
- **Coordinates** -- lets teammates self-organize, intervenes only when blocked
- **Reviews** -- ensures quality before shipping
- **Learns** -- runs retrospectives, extracts patterns, improves processes

The Lead **never writes code directly**. All code is produced by spawned teammates.

### Why This Matters

- **Parallelism**: Multiple agents working simultaneously instead of sequentially
- **Specialization**: Each agent has a focused role with appropriate tools
- **Quality**: Multi-layer verification (self-verify -> peer review -> code review -> QA gate)
- **Learning**: Every feature shipped feeds back into improved processes and generators

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | The engineering handbook -- team identity, protocols, standards, security rules |
| `PROGRESS.md` | Live dashboard -- current state of all work, updated at every milestone |
| `LESSONS.md` | Team memory -- lessons from every feature, read before starting new work |
| `knowledge/README.md` | Catalog of accumulated patterns, generators, decisions, research |

## Knowledge System (Exponential Growth)

The knowledge system creates compound growth across 3 tiers:

### Tier 1: Patterns
After shipping a feature, extract the repeating structure into `knowledge/patterns/`. Next time, teammates reference the pattern instead of figuring it out from scratch.

### Tier 2: Generators
When 2+ features follow the same pattern, create a generator agent in `.claude/agents/`. The generator takes a description and produces most of the code automatically.

### Tier 3: Self-Evolving
Generators improve with every use. Teammate feedback updates the generator, so each subsequent feature requires less manual work: 60% auto -> 85% auto -> 95% auto.

## Customization

### Adding Your Projects

Edit `CLAUDE.md` and fill in the placeholder sections:
1. **Projects table** -- your actual projects with paths and stacks
2. **Architecture** -- how each project is structured
3. **Code Standards** -- linting, formatting, patterns per project
4. **Verification** -- build and test commands

### Adding Custom Agents

Create a new `.md` file in `.claude/agents/`:

```markdown
---
name: my-custom-agent
description: "What this agent does"
tools: Read, Write, Edit, Bash
---

# Agent Name

Instructions for the agent...
```

### Adding Custom Commands

Create a new `.md` file in `.claude/commands/`:

```markdown
# /my-command -- Description

## Input
$ARGUMENTS

## Execution
Steps the Lead should follow...
```

## Security

The handbook includes strict security rules:
- Never hardcode credentials
- Never copy secrets between projects
- `.env` files always in `.gitignore`
- Production data treated as sensitive by default
- Credentials never appear in PROGRESS.md, LESSONS.md, or any tracked file

## Directory Structure

```
claude-teammate/
+-- README.md                    # This file
+-- CLAUDE.md                    # Engineering handbook (customize this)
+-- LESSONS.md                   # Team memory (grows over time)
+-- PROGRESS.md                  # Live dashboard (auto-updated)
+-- setup.sh                     # First-time setup script
+-- .gitignore
+-- .claude/
|   +-- settings.json            # Agent Teams config + permissions
|   +-- commands/
|   |   +-- setup.md             # /setup command
|   |   +-- feature.md           # /feature command
|   |   +-- advisory.md          # /advisory command
|   |   +-- retro.md             # /retro command
|   |   +-- scan.md              # /scan command
|   |   +-- review.md            # /review command
|   |   +-- debug.md             # /debug command
|   |   +-- test.md              # /test command
|   +-- agents/
|       +-- strategy-analyst.md  # Product strategy analysis
|       +-- legal-analyst.md     # Legal/compliance analysis
|       +-- code-reviewer.md     # Code review (read-only)
|       +-- researcher.md        # Deep research (read-only)
|       +-- qa-gate.md           # Quality gate verification
|       +-- browser-tester.md    # GUI testing
|       +-- page-generator.md    # Page code generation
|       +-- crud-generator.md    # CRUD module generation
|       +-- chart-generator.md   # Chart component generation
+-- templates/
|   +-- progress-index.md        # Template for PROGRESS.md
|   +-- lesson-entry.md          # Template for lesson entries
|   +-- self-improvement-entry.md # Template for self-improvement entries
+-- knowledge/
    +-- README.md                # Knowledge base catalog
    +-- patterns/                # Extracted patterns from shipped features
    +-- generators/              # Generator documentation
    +-- decisions/               # Architecture decision records
    +-- research-cache/          # Cached advisory research
    +-- lessons/                 # Consolidated lessons by topic
```

## Contributing

To improve this setup:

1. **After using it on a real project**, run `/retro` and capture what worked and what did not
2. **Update CLAUDE.md** with process improvements from lessons learned
3. **Add new agents** for specialized roles your team needs
4. **Add new commands** for workflows specific to your domain
5. **Extract patterns** from your projects into `knowledge/patterns/`
6. **Create generators** when you see repeating patterns across features

The goal is compound improvement: every project you run through this system makes the system better for the next one.

## License

MIT
