#!/usr/bin/env bash
set -euo pipefail

# One-command setup for the ~/.agents toolkit on a new machine.
#
# Assumes this repo is checked out at ~/.agents (clone it there first; see
# README.md). Idempotent: safe to re-run any time.
#
# Usage:
#   ~/.agents/setup.sh            # wire everything up
#   ~/.agents/setup.sh --dry-run  # preview, make no changes
#   ~/.agents/setup.sh --yes      # non-interactive (auto-replace stray copies)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY=false
for a in "$@"; do [[ "$a" == "--dry-run" || "$a" == "-n" ]] && DRY=true; done

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== ~/.agents setup ===${NC}"

# Warn (don't fail) if not located at ~/.agents, since paths assume that.
if [[ "$SCRIPT_DIR" != "$HOME/.agents" ]]; then
  echo -e "${YELLOW}Note:${NC} this repo is at '$SCRIPT_DIR', not '~/.agents'."
  echo -e "      Skills/commands reference '~/.agents/...'; clone or symlink to ~/.agents for them to resolve."
fi

# 1. Make scripts executable.
echo -e "\n${BLUE}1/4 Making scripts executable${NC}"
chmod +x "$SCRIPT_DIR/setup.sh" \
         "$SCRIPT_DIR/scripts/sync-all.sh" \
         "$SCRIPT_DIR/scripts/sync-skills.sh" \
         "$SCRIPT_DIR/scripts/sync-commands.sh" 2>/dev/null || true
echo -e "  ${GREEN}done${NC}"

# 2. Ensure runtime dirs exist (git-ignored).
echo -e "\n${BLUE}2/4 Ensuring runtime dirs${NC}"
mkdir -p "$SCRIPT_DIR/artifacts/code-reviews"
echo -e "  ${GREEN}artifacts/code-reviews ready${NC}"

# 3. Wire each installed tool's global memory file to the canonical profile.
# Only links when the tool is installed (parent dir exists) and won't clobber a
# non-empty existing file.
echo -e "\n${BLUE}3/4 Wiring tool memory files to docs/profile.md${NC}"
link_profile() {  # $1 = path under $HOME
  local f="$HOME/$1" target="../.agents/docs/profile.md"
  [[ -d "$(dirname "$f")" ]] || { echo "  ${f/#$HOME/~}: tool not installed — skipped"; return; }
  if [[ -L "$f" ]]; then echo -e "  ${GREEN}ok${NC} ${f/#$HOME/~}"; return; fi
  if [[ -e "$f" && -s "$f" ]]; then echo -e "  ${YELLOW}skip${NC} ${f/#$HOME/~} (non-empty, not clobbering)"; return; fi
  if [[ "$DRY" == true ]]; then echo -e "  ${YELLOW}would link${NC} ${f/#$HOME/~}"; return; fi
  rm -f "$f"; ln -s "$target" "$f"; echo -e "  ${GREEN}linked${NC} ${f/#$HOME/~}"
}
link_profile .claude/CLAUDE.md
link_profile .codex/AGENTS.md
link_profile .gemini/GEMINI.md

# 4. Sync skills + commands into all installed tools.
echo -e "\n${BLUE}4/4 Syncing skills + commands into tools${NC}"
"$SCRIPT_DIR/scripts/sync-all.sh" "$@"

echo -e "\n${GREEN}Setup complete.${NC}"
echo -e "Next: start the workflow with ${BLUE}/feature${NC} (or ${BLUE}~/.agents/workflow/01-pm.md${NC}),"
echo -e "and add your own skills under ${BLUE}~/.agents/skills/${NC}."
