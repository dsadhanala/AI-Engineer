#!/usr/bin/env bash
set -euo pipefail

# Syncs commands from ~/.agents/commands/ into each AI tool's command/prompt
# directory as relative symlinks. Run after creating or updating any command.
#
# Usage:
#   ~/.agents/scripts/sync-commands.sh            # sync all commands
#   ~/.agents/scripts/sync-commands.sh --dry-run  # preview, make no changes
#   ~/.agents/scripts/sync-commands.sh --yes      # auto-replace standalone copies

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sync-common.sh
source "$SCRIPT_DIR/lib/sync-common.sh"

SOURCE="$HOME/.agents/commands"
# Each tool exposes *.md files in these dirs as slash commands / prompts.
TARGETS=(
  "$HOME/.claude/commands"
  "$HOME/.cursor/commands"
  "$HOME/.codex/prompts"
)
# Add other tools as you confirm their custom-command dirs, e.g.:
#   "$HOME/.augment/commands"
#   "$HOME/.factory/commands"

usage() { sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'; }

parse_sync_flags "$@"
[[ "$SYNC_SHOW_HELP" == true ]] && { usage; exit 0; }

echo -e "${BLUE}Syncing commands from ${SOURCE/#$HOME/~}${NC}"
sync_source "$SOURCE" files "$DRY_RUN" "$ASSUME_YES" "${TARGETS[@]}"
sync_summary
