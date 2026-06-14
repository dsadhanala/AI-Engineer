# commands/

Tool-agnostic **slash commands** — thin wrappers that invoke a [skill](../skills/README.md)
or a [workflow](../workflow/README.md) stage with one keystroke. Authored once
here and synced into every tool (see [`../scripts/`](../scripts/)). Each `.md`
file becomes a slash command in the tools that support them.

## Skill commands

Each [skill](../skills/README.md) can have a thin command that invokes it with
one keystroke. This repo ships without bundled skill commands — add one alongside
each skill you create (see [Adding a command](#adding-a-command)). Some are kept
private, so your local checkout may have skill commands that aren't in git.

```
/<command>       # runs the matching skill; anything after it is passed as $ARGUMENTS
```

## Workflow commands

Drive the 6-agent [workflow](../workflow/README.md). `/feature` is the
orchestrator; the verb commands run a single stage directly. All take
`Project: <name>` and `Feature: <name>` (they namespace
`~/.agents/artifacts/{project}/{feature}/`).

| Command | Agent | What it does |
|---------|-------|--------------|
| `/feature` | orchestrator | Starts a new feature at PM, or resumes by routing to whatever agent `status.md` says is next. |
| `/pm` | [01 PM](../workflow/01-pm.md) | Brainstorm and write the PRD. |
| `/plan` | [02 Planner](../workflow/02-planner.md) | Architecture decisions + TDD task breakdown. |
| `/build` | [03 Builder](../workflow/03-builder.md) | TDD implementation of the next pending task. |
| `/test` | [04 Tester](../workflow/04-tester.md) | Validate against tests and acceptance criteria. |
| `/debug` | [05 Debugger](../workflow/05-debugger.md) | Root-cause analysis for a failed/rejected task. |
| `/review` | [06 Reviewer](../workflow/06-reviewer.md) | Production-readiness review of a passing task. |

```
/feature Project: my-app, Feature: dark-mode    # start (or resume) the whole loop
/build   Project: my-app, Feature: dark-mode    # run just the Builder stage
```

Anything you type after a command is passed through as `$ARGUMENTS`.

> Note: `/review` here is the **workflow stage** (reviews a task that just passed
> testing). If you add a separate standalone code-review skill, give its command
> a distinct slug (e.g. `/reviewer`) to avoid confusion.

## Anatomy of a command

A command is a small Markdown file with frontmatter (`title`, `slug`,
`description`, `tags`) and a body that tells the tool to **read and follow** a
skill's `SKILL.md` by its `~/.agents/...` path. Referencing the skill by
absolute path is what makes commands work in any tool, regardless of model.

## Adding a command

```bash
$EDITOR ~/.agents/commands/<name>.md   # usually a thin wrapper pointing at a skill
~/.agents/scripts/sync-all.sh          # make it available in every tool
```

## Keeping a command private (don't share via git)

To keep a command local-only (never committed/pushed), add its line to
[`../.gitignore`](../.gitignore), e.g. `commands/<name>.md`. It still syncs into
your tools; it just isn't shared.
