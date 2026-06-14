# scripts/lib/

Shared shell library for the sync scripts. Not meant to be run directly — it's
sourced by [`../sync-skills.sh`](../sync-skills.sh) and
[`../sync-commands.sh`](../sync-commands.sh).

## `sync-common.sh`

Provides the common symlink logic so the sync scripts stay small and consistent:

- `parse_sync_flags` — parses `--dry-run`, `--yes`, and `--help`.
- `_relpath` — computes a correct **relative** symlink target via
  `python3 os.path.relpath`, so links stay valid regardless of directory depth
  or where the repo is checked out.
- `sync_one` — creates, repairs, or replaces a single symlink (handles missing
  links, broken links, wrong targets, and standalone copies).
- `sync_source` — syncs an entire source dir (skills or commands) into all
  configured targets and prints a summary (`Created / OK / Fixed / Needs attention`).

Behavior is controlled by the `DRY_RUN` and `ASSUME_YES` flags set by the
sourcing script.
