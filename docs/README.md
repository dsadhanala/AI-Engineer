# docs/

Supporting documentation for the `~/.agents` toolkit.

| File | What it covers |
|------|----------------|
| `tool-integration.md` | How each AI tool consumes `~/.agents`, and how tool-native agents (Augment specialists, Factory droids) map to the canonical workflow — so they don't drift. |
| `profile.md` | The canonical personal operating profile. Wired into each tool's global memory file (`CLAUDE.md`, `codex/AGENTS.md`, `gemini/GEMINI.md`) so every tool starts with the same baseline context. |

Edit logic once here (or in `skills/` / `workflow/`) and re-run
`scripts/sync-all.sh` to propagate.
