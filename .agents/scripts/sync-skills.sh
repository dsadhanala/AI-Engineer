#!/usr/bin/env bash
set -euo pipefail

# Syncs skills from ~/.agents/skills/ into each AI tool's skills directory as
# relative symlinks. Run after creating or updating any skill.
#
# Usage:
#   ~/.agents/scripts/sync-skills.sh            # sync all skills
#   ~/.agents/scripts/sync-skills.sh --dry-run  # preview, make no changes
#   ~/.agents/scripts/sync-skills.sh --yes      # auto-replace standalone copies

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sync-common.sh
source "$SCRIPT_DIR/lib/sync-common.sh"

SOURCE="$HOME/.agents/skills"
TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.cursor/skills"
  "$HOME/.codex/skills"
)
# NOTE: Cursor loads user skills from ~/.cursor/skills-cursor (Cursor-managed,
# has its own manifest). We intentionally do NOT write there to avoid clobbering
# Cursor's management. If you confirm ~/.cursor/skills is unused by your Cursor
# version, switch the target above to ~/.cursor/skills-cursor.

usage() { sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'; }

parse_sync_flags "$@"
[[ "$SYNC_SHOW_HELP" == true ]] && { usage; exit 0; }

echo -e "${BLUE}Syncing skills from ${SOURCE/#$HOME/~}${NC}"
sync_source "$SOURCE" dirs "$DRY_RUN" "$ASSUME_YES" "${TARGETS[@]}"
sync_summary
