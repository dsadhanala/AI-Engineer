#!/usr/bin/env bash
set -euo pipefail

# Syncs commands from ~/.agents/commands/ into each AI tool's command/prompt
# directory as relative symlinks. Run after creating or updating any command.
#
# Usage:
#   ~/.agents/scripts/sync-commands.sh            # sync all commands
#   ~/.agents/scripts/sync-commands.sh --dry-run  # preview, make no changes
#   ~/.agents/scripts/sync-commands.sh --yes      # auto-replace standalone copies
#   ~/.agents/scripts/sync-commands.sh --prune    # also remove dangling ~/.agents links

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sync-common.sh disable=SC1091
source "$SCRIPT_DIR/lib/sync-common.sh"

SOURCE="$HOME/.agents/commands"
# Each tool exposes *.md files in these dirs as slash commands / prompts.
# Only existing tool dirs are synced; missing ones are skipped automatically.
TARGETS=(
  "$HOME/.claude/commands"
  "$HOME/.cursor/commands"
  "$HOME/.codex/prompts"
  "$HOME/.augment/commands"
)
# NOTE: Factory/Droid has no documented user-level slash-command dir (it uses
# ~/.factory/droids for custom agents). Add "$HOME/.factory/commands" here if a
# future version supports it.

usage() { sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'; }

parse_sync_flags "$@"
[[ "$SYNC_SHOW_HELP" == true ]] && { usage; exit 0; }

echo -e "${BLUE}Syncing commands from ${SOURCE/#$HOME/~}${NC}"
sync_source "$SOURCE" files "$DRY_RUN" "$ASSUME_YES" "${TARGETS[@]}"
sync_summary
