# code-reviewer

Expert code review of a PR or local/staged changes, covering correctness, code
quality, maintainability, performance, type safety, accessibility, security,
test coverage, and pattern consistency.

> `SKILL.md` is the instruction file the AI follows. This README is the
> human-facing guide: what the skill does, how to run it, and how to customize it.

## What it does

- **Scope detection** — reviews a PR (via `gh` / `glab` / MCP), staged changes
  (`git diff --cached`), or all local changes vs. the merge base.
- **Severity-labeled findings** — Critical / Required / Nit / Optional / FYI,
  each paired with a concrete fix.
- **Conversational walkthrough** — goes file-by-file rather than dumping a wall
  of text.
- **Saved reports** — writes a markdown report to
  `~/.agents/artifacts/code-reviews/`:
  - `code-review_<date>_<time>.md` for local/staged reviews
  - `code-review_PR-<NUMBER>_<date>_<time>.md` for PRs

## How to use

```
# Slash command (after setup.sh — easiest):
/reviewer                         # reviews current changes
/reviewer review PR #123          # review a specific PR
/reviewer staged only             # review just staged changes

# Or point any tool at the skill file directly (works before syncing too):
Read ~/.agents/skills/code-reviewer/SKILL.md and follow it to review my staged changes.
```

## Customize for a repo (project profile)

The core skill is generic. To add repo-specific review dimensions, copy the
template to the git-ignored profile file and edit it:

```bash
cp ~/.agents/skills/code-reviewer/references/project-profile.example.md \
   ~/.agents/skills/code-reviewer/references/project-profile.md
```

The profile lets you define: git-host mapping, frameworks & rendering
performance, dependency-injection / service locators, feature flags &
configuration, analytics / telemetry, CI pre-flight checks, package boundaries &
imports, and high-signal build/test files. `project-profile.md` is git-ignored,
so your proprietary rules stay local.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Instructions the AI follows |
| `references/review-checklist.md` | Per-dimension patterns and examples |
| `references/output-format.md` | Report template + filename convention |
| `references/project-profile.example.md` | Template for repo-specific rules |
| `references/project-profile.md` | Your local, git-ignored customization (optional) |
