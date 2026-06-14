# skills/

Portable AI **skills** — reusable expert behaviors any tool can load and follow.
Authored once here and synced into every AI tool (see
[`../scripts/`](../scripts/)). Each skill lives in its own folder with a
`SKILL.md` (the instructions the AI follows) and a `README.md` (human-facing
docs).

## Layout

Each skill is a folder:

```
skills/<name>/
├── SKILL.md       # instructions the AI follows (required)
├── README.md      # human-facing docs (optional but encouraged)
└── references/    # optional supporting files the skill loads
```

This repo ships without bundled skills — add your own (below). Some skills are
kept private (see [Keeping a skill private](#keeping-a-skill-private-dont-share-via-git)),
so your local checkout may contain skill folders that aren't in git.

## Using a skill

```
# Slash command (after setup.sh — easiest), where <name> has a matching command:
/<command>

# Or point any tool at the skill file directly (works before syncing too):
Read ~/.agents/skills/<name>/SKILL.md and follow it.
```

## Adding a skill

```bash
mkdir -p ~/.agents/skills/<name>
$EDITOR ~/.agents/skills/<name>/SKILL.md     # instructions for the AI
$EDITOR ~/.agents/skills/<name>/README.md    # human-facing docs (optional but encouraged)
~/.agents/scripts/sync-all.sh                # make it available in every tool
```

Only folders containing a `SKILL.md` are treated as skills by the sync scripts,
so a `README.md`-only folder (like this one) is ignored.

## Keeping a skill private (don't share via git)

Every skill still works locally and still syncs into your tools — "private" only
means it isn't committed/pushed to the shared repo. To keep a skill local-only,
add its folder to [`../.gitignore`](../.gitignore):

```gitignore
skills/<name>/
# and the command that invokes it, if any:
commands/<name>.md
```

That whole skill folder is then excluded from git, so it's never shared with
teammates who clone the repo. New skills you create are committed normally unless
you add them here.
