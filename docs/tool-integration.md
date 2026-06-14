# Tool Integration & Overlaps

`~/.agents` is the **single source of truth**. Each AI tool then exposes that
content through its own native mechanism. This doc maps the tool-native concepts
to the canonical toolkit so the two don't drift.

## How each tool consumes `~/.agents`

| Tool | Skills | Commands / prompts | Global memory file | Native "agents" |
|------|--------|--------------------|--------------------|-----------------|
| Claude | `~/.claude/skills/*` → symlink | `~/.claude/commands/*` → symlink | `~/.claude/CLAUDE.md` | subagents |
| Cursor | `~/.cursor/skills/*` → symlink | `~/.cursor/commands/*` → symlink | (project rules) | — |
| Codex | `~/.codex/skills/*` → symlink | `~/.codex/prompts/*` → symlink | `~/.codex/AGENTS.md` | — |
| Factory (Droid) | `~/.factory/skills/*` → symlink | (no user command dir) | — | `~/.factory/droids/*` |
| Augment | `~/.augment/skills/*` → symlink | `~/.augment/commands/*` → symlink | `~/.augment/rules/*` | `~/.augment/specialists/*` |
| Gemini | — | — | `~/.gemini/GEMINI.md` | — |

Skills and commands are kept in sync by `scripts/sync-skills.sh` and
`scripts/sync-commands.sh`. The global memory files share one canonical profile
(see `profile.md`).

## The canonical workflow vs. tool-native agents

The canonical pipeline lives in `~/.agents/workflow/` (PM → Planner → Builder →
Tester → Debugger → Reviewer) and is invoked tool-agnostically via the
`/feature`, `/pm`, `/plan`, `/build`, `/test`, `/debug`, `/review` commands.

Some tools also ship their own "agent" abstraction. These overlap with the
workflow stages. To avoid maintaining the same logic twice, treat the workflow
files as the source of truth and make tool-native agents **thin pointers** where
they map cleanly (as `~/.augment/specialists/code-reviewer.md` now does).

### Augment specialists → workflow mapping

| Augment specialist | Closest canonical equivalent |
|--------------------|------------------------------|
| `code-reviewer` | `skills/code-reviewer` (now defers to it) |
| `Coordinator` (spec-writer) | `workflow/01-pm.md` + `workflow/02-planner.md` |
| `Developer` | `workflow/02-planner.md` + `workflow/03-builder.md` |
| `Implementor` | `workflow/03-builder.md` |
| `Verifier` | `workflow/04-tester.md` + `workflow/06-reviewer.md` |
| `Ralph` (work/test loop) | `workflow/03-builder.md` ↔ `04-tester.md` loop |
| `UI Designer` | no 1:1 — keep tool-specific (UI-only focus) |

### Factory droids → workflow mapping

| Factory droid | Closest canonical equivalent |
|---------------|------------------------------|
| `worker` | `workflow/03-builder.md` |
| `scrutiny-feature-reviewer` | `workflow/06-reviewer.md` + `skills/code-reviewer` |
| `user-testing-flow-validator` | `workflow/04-tester.md` (E2E flavor) |

## Guidance

- **Edit logic once**, in `~/.agents/skills/` or `~/.agents/workflow/`. Re-run
  the sync scripts to propagate.
- For tool-native agents that require their own frontmatter (Augment
  specialists, Factory droids), keep the body a short "read and follow
  `~/.agents/...`" pointer instead of copying the logic.
- Agents with no canonical equivalent (e.g. `UI Designer`) can stay fully
  tool-specific — just don't duplicate workflow logic into them.
- Run `scripts/sync-all.sh --dry-run --prune` periodically to spot dangling
  symlinks left behind when a skill source is renamed or removed.
