#!/usr/bin/env bash
set -euo pipefail

# Claude Code Team Lead - Setup Script
# Run this once after cloning to verify prerequisites and initialize the workspace.

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${BOLD}=== Claude Code Team Lead - Setup ===${NC}"
echo ""

PASS=0
WARN=0
FAIL=0

check_pass() {
  echo -e "  ${GREEN}[PASS]${NC} $1"
  PASS=$((PASS + 1))
}

check_warn() {
  echo -e "  ${YELLOW}[WARN]${NC} $1"
  WARN=$((WARN + 1))
}

check_fail() {
  echo -e "  ${RED}[FAIL]${NC} $1"
  FAIL=$((FAIL + 1))
}

# --- Prerequisites ---
echo -e "${BOLD}Checking prerequisites...${NC}"

# Claude CLI
if command -v claude &> /dev/null; then
  CLAUDE_VER=$(claude --version 2>/dev/null || echo "unknown")
  check_pass "Claude CLI found: $CLAUDE_VER"
else
  check_fail "Claude CLI not found. Install: https://docs.anthropic.com/en/docs/claude-code"
fi

# Node.js
if command -v node &> /dev/null; then
  NODE_VER=$(node --version)
  check_pass "Node.js found: $NODE_VER"
else
  check_warn "Node.js not found. Required for JS/TS projects."
fi

# Git
if command -v git &> /dev/null; then
  GIT_VER=$(git --version)
  check_pass "Git found: $GIT_VER"
else
  check_fail "Git not found. Required for version control."
fi

# tmux
if command -v tmux &> /dev/null; then
  TMUX_VER=$(tmux -V)
  check_pass "tmux found: $TMUX_VER"
else
  check_warn "tmux not found. Recommended for agent teams split-pane. Install: brew install tmux"
fi

# GitHub CLI (optional)
if command -v gh &> /dev/null; then
  check_pass "GitHub CLI found"
else
  check_warn "GitHub CLI (gh) not found. Optional but useful. Install: brew install gh"
fi

echo ""

# --- Directory Structure ---
echo -e "${BOLD}Verifying directory structure...${NC}"

DIRS=(
  "knowledge/patterns"
  "knowledge/decisions"
  "knowledge/generators"
  "knowledge/research-cache"
  "knowledge/lessons"
  "templates"
  ".claude/commands"
  ".claude/agents"
)

for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    check_pass "$dir/"
  else
    mkdir -p "$dir"
    check_pass "$dir/ (created)"
  fi
done

echo ""

# --- Key Files ---
echo -e "${BOLD}Verifying key files...${NC}"

FILES=(
  "CLAUDE.md"
  "LESSONS.md"
  "PROGRESS.md"
  ".claude/settings.json"
  ".gitignore"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    check_pass "$file"
  else
    check_fail "$file missing"
  fi
done

echo ""

# --- Agent Teams Flag ---
echo -e "${BOLD}Checking Agent Teams configuration...${NC}"

if [ -f ".claude/settings.json" ]; then
  if grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" .claude/settings.json; then
    check_pass "Agent Teams flag enabled in settings.json"
  else
    check_warn "Agent Teams flag not found in settings.json. Add CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
  fi
else
  check_fail ".claude/settings.json not found"
fi

echo ""

# --- Git Init ---
echo -e "${BOLD}Checking git repository...${NC}"

if [ -d ".git" ]; then
  check_pass "Git repository already initialized"
else
  git init
  check_pass "Git repository initialized"
fi

echo ""

# --- Summary ---
echo -e "${BOLD}=== Setup Summary ===${NC}"
echo -e "  ${GREEN}Passed: $PASS${NC}"
if [ $WARN -gt 0 ]; then
  echo -e "  ${YELLOW}Warnings: $WARN${NC}"
fi
if [ $FAIL -gt 0 ]; then
  echo -e "  ${RED}Failed: $FAIL${NC}"
fi

echo ""
echo -e "${BOLD}=== Next Steps ===${NC}"
echo ""
echo "  1. Edit CLAUDE.md:"
echo "     - Fill in the Projects table with your actual projects"
echo "     - Fill in Architecture sections for each project"
echo "     - Fill in Code Standards for each project"
echo "     - Fill in Verification commands"
echo ""
echo "  2. Copy your project directories into this workspace"
echo "     (or symlink them if they live elsewhere)"
echo ""
echo "  3. Start Claude Code in this directory:"
echo "     cd $(pwd)"
echo "     claude"
echo ""
echo "  4. Run /setup inside Claude Code to auto-detect and configure"
echo ""
echo "  5. Use slash commands:"
echo "     /feature  - Full feature lifecycle"
echo "     /advisory - Feature analysis (no code)"
echo "     /scan     - System context scan"
echo "     /review   - Code review"
echo "     /debug    - Parallel debugging"
echo "     /test     - Test suite"
echo "     /retro    - Retrospective"
echo ""
echo -e "${GREEN}Setup complete. Happy building!${NC}"
echo ""
