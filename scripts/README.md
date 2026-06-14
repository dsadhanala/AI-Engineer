# scripts/

Cross-tool **sync tooling**. Skills and commands are authored once in
[`../skills/`](../skills/) and [`../commands/`](../commands/); these scripts
symlink them into each installed AI tool so every tool sees the same definitions.

## Scripts

| Script | What it does |
|--------|--------------|
| `sync-all.sh` | Runs both `sync-skills.sh` and `sync-commands.sh`. The usual entry point. |
| `sync-skills.sh` | Symlinks each skill folder (any dir with a `SKILL.md`) into every tool's skills dir. |
| `sync-commands.sh` | Symlinks each command `.md` into every tool's commands/prompts dir. |
| `lib/sync-common.sh` | Shared symlink logic (see [lib/README.md](lib/README.md)). |

## Usage

```bash
~/.agents/scripts/sync-all.sh            # sync skills + commands into all tools
~/.agents/scripts/sync-all.sh --dry-run  # preview, make no changes
~/.agents/scripts/sync-all.sh --yes      # non-interactive (auto-replace stray copies)

# or individually:
~/.agents/scripts/sync-skills.sh
~/.agents/scripts/sync-commands.sh
```

Run after adding, updating, or removing any skill or command. The scripts are
idempotent and self-healing: they create missing symlinks, repair broken or
wrong ones, and report standalone copies that need attention.

## Targets

| Tool | Skills dir | Commands/prompts dir |
|------|-----------|----------------------|
| Cursor | `~/.cursor/skills/` | `~/.cursor/commands/` |
| Claude | `~/.claude/skills/` | `~/.claude/commands/` |
| Codex | `~/.codex/skills/` | `~/.codex/prompts/` |

Add more tools by editing the `TARGETS` array in the relevant sync script.

> **Note (Cursor):** some Cursor versions manage their own skills under
> `~/.cursor/skills-cursor/`. The scripts intentionally target `~/.cursor/skills/`
> and do not touch the managed dir.
