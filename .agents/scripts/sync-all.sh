#!/usr/bin/env bash
set -euo pipefail

# Syncs both skills and commands into all AI tool directories.
# Forwards any flags (--dry-run, --yes) to both sync scripts.
#
# Usage:
#   ~/.agents/scripts/sync-all.sh
#   ~/.agents/scripts/sync-all.sh --dry-run
#   ~/.agents/scripts/sync-all.sh --yes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/sync-skills.sh" "$@"
"$SCRIPT_DIR/sync-commands.sh" "$@"
