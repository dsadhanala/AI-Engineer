# AI-Engineer
All about AI and agentic workflows to boost developer productivity

## ~/.agents — Portable AI Agent Toolkit

A tool-agnostic, model-agnostic toolkit you keep in version control and share
across machines and teammates. Author your AI skills, commands, and workflows
**once** here; the sync scripts wire them into every AI coding tool you use
(Claude Code, Cursor, Factory/Droid, Codex, Augment, …).

It bundles three capabilities:

- **Skills** (`skills/`) — reusable expert behaviors any tool can load and
  follow. Bring your own; some can be kept private (not shared via git).
- **Commands** (`commands/`) — slash commands that invoke a skill or a workflow
  stage with one keystroke.
- **Workflow** (`workflow/`) — a 6-agent pipeline that takes an idea from
  ideation to production-ready code with file-based handoffs.

## What's Inside

```
~/.agents/
├── README.md            # This file — usage guide
├── AGENTS.md            # Workflow system overview, status markers, design principles
├── setup.sh             # One-command install on a new machine (idempotent)
│
├── skills/              # Portable AI skills — synced into every tool
│   └── <name>/          #   each skill: SKILL.md (+ optional README.md, references/)
│
├── commands/            # Slash commands / prompts — synced into every tool
│   ├── feature.md       #   /feature  → workflow orchestrator (auto-routes via status.md)
│   ├── pm/plan/build/   #   /pm /plan /build /test /debug /review → workflow stages 01–06
│   │   test/debug/review.md
│   └── <name>.md        #   optional per-skill commands you add
│
├── workflow/            # 6-agent ideation→production pipeline
│   ├── 01-pm.md         #   PM / Ideation       → prd.md
│   ├── 02-planner.md    #   Planner / Architect  → plan.md + tasks/
│   ├── 03-builder.md    #   Builder (TDD)        → code
│   ├── 04-tester.md     #   Tester               → pass/fail
│   ├── 05-debugger.md   #   Debugger             → root-cause findings
│   └── 06-reviewer.md   #   Reviewer             → approve / changes
│
├── templates/           # Reusable templates (task.md, status.md)
│
├── docs/                # Supporting docs
│   ├── profile.md       #   canonical operating profile (→ each tool's memory file)
│   └── tool-integration.md  # how each tool consumes ~/.agents; native-agent mapping
│
├── scripts/             # Cross-tool sync tooling
│   ├── sync-all.sh      #   sync skills + commands into all tools
│   ├── sync-skills.sh   #   sync skills only
│   ├── sync-commands.sh #   sync commands only
│   └── lib/sync-common.sh  # shared symlink logic
│
└── artifacts/           # Runtime outputs (git-ignored, never committed)
    ├── code-reviews/    #   saved code-review reports
    └── {project}/{feature}/   # per-feature workflow state (prd/plan/tasks/status/review)
```

Every subdirectory has its own `README.md` with details:
[`skills/`](skills/README.md) · [`commands/`](commands/README.md) ·
[`workflow/`](workflow/README.md) · [`scripts/`](scripts/README.md) ·
[`templates/`](templates/README.md) · [`docs/`](docs/README.md).

A canonical **operating profile** (`docs/profile.md`) is symlinked to each tool's
global memory file (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
`~/.gemini/GEMINI.md`) so every tool starts with the same baseline context.
Personal/proprietary context goes in the git-ignored `docs/profile.local.md`.

Pick whichever capability fits the task — they're independent:

| You want to… | Use | Entry point |
|--------------|-----|-------------|
| Run a focused expert task (review, writing, etc.) | a **skill** you add | `/<command>` or "Read `~/.agents/skills/<name>/SKILL.md`…" |
| Build a feature end-to-end | the **workflow** | `/feature` or "Read `~/.agents/workflow/01-pm.md`…" |

## Install / Setup

**Prerequisites:** `bash`, `git`, `python3` (used by the sync scripts to compute
relative symlinks), and at least one supported AI tool installed. `gh` (GitHub)
or `glab` (GitLab) is optional but recommended for PR reviews.

This repo is meant to live at `~/.agents` (it's referenced by that path
everywhere). On a new machine:

```bash
# 1. If you already have a ~/.agents, back it up first:
[ -e ~/.agents ] && mv ~/.agents ~/.agents.backup-$(date +%Y%m%d-%H%M%S)

# 2. Clone the repo to ~/.agents
git clone <your-repo-url> ~/.agents

# 3. Wire skills + commands into every installed AI tool and create runtime dirs
~/.agents/setup.sh
```

`setup.sh` is **idempotent** — safe to re-run any time. It:

1. Makes the scripts executable.
2. Ensures runtime dirs exist (`artifacts/code-reviews`).
3. Wires each installed tool's global memory file (`CLAUDE.md`, `codex/AGENTS.md`,
   `gemini/GEMINI.md`) to `docs/profile.md` (won't clobber a non-empty file).
4. Runs `scripts/sync-all.sh` to symlink every skill and command into each
   installed tool.

Useful flags (forwarded to the sync scripts):

```bash
~/.agents/setup.sh --dry-run   # preview what would change, make no changes
~/.agents/setup.sh --yes       # non-interactive (auto-replace stray copies)
```

**Verify the install** — every tool should now see the skills and commands:

```bash
~/.agents/scripts/sync-all.sh --dry-run   # expect "OK" for each, nothing to fix
ls -l ~/.cursor/commands/feature.md       # should be a symlink into ~/.agents/commands/
```

Re-run `setup.sh` (or `scripts/sync-all.sh`) whenever you add or change a skill
or command. `artifacts/` is git-ignored and never committed.

---

## Skills

Reusable expert behaviors. Any tool loads one by reading its `SKILL.md` and
following it; after `setup.sh` they're also native skills in each tool. This repo
ships without bundled skills — **add your own** (see below). Full docs in
**[`skills/README.md`](skills/README.md)**.

```
/<command>                              # if the skill has a command
Read ~/.agents/skills/<name>/SKILL.md and follow it.   # works for any skill
```

> **Keeping a skill private:** to keep a skill local-only (works + syncs, but
> never shared via git), add its folder to [`.gitignore`](.gitignore) — e.g.
> `skills/<name>/` (and `commands/<name>.md` for its command). See
> [skills/README.md](skills/README.md#keeping-a-skill-private-dont-share-via-git).

## Commands

Thin, tool-agnostic wrappers that invoke a skill or workflow stage with one
keystroke. Full docs in **[`commands/README.md`](commands/README.md)**.

**Workflow commands** (shipped) — `/feature` orchestrates the whole loop; the verbs run one stage:

| Command | Stage |
|---------|-------|
| `/feature` | Orchestrator — start at PM, or resume to the next agent via `status.md` |
| `/pm` · `/plan` · `/build` · `/test` · `/debug` · `/review` | The 6 agents (01–06), run directly |

**Skill commands** (bring your own) — add a `commands/<name>.md` wrapper alongside
each skill you create. If you add a standalone code-review skill, give its command
a distinct slug (e.g. `/reviewer`) so it doesn't clash with the workflow's
`/review` stage.

### Add your own skill or command

Author once here, then sync — never create files directly in a tool's own dir:

```bash
mkdir -p ~/.agents/skills/<name> && $EDITOR ~/.agents/skills/<name>/SKILL.md  # new skill
$EDITOR ~/.agents/commands/<name>.md                                          # new command
~/.agents/scripts/sync-all.sh                                                 # make it available everywhere
```

See [Cross-Tool Skill & Command Syncing](#cross-tool-skill--command-syncing) for
the full convention, and each subdirectory's `README.md` for details.

---

## The 6-Agent Workflow

A pipeline that takes a feature from idea to production-ready code. Each agent has
a distinct role, clear inputs/outputs, and file-based handoffs via
`~/.agents/artifacts/{project}/{feature}/`, with `status.md` as the single source
of truth for state. See `AGENTS.md` for status markers and design principles.

### Quick Reference

| # | Agent | Role | Input | Output |
|---|-------|------|-------|--------|
| 01 | **PM** | Brainstorm, refine, write PRD | Your idea | `prd.md` |
| 02 | **Planner** | Architecture, task breakdown | `prd.md` | `plan.md` + `tasks/T*.md` |
| 03 | **Builder** | TDD implementation | Next pending task | Code + updated task file |
| 04 | **Tester** | Validate, run tests | Completed task | Pass/fail verdict |
| 05 | **Debugger** | Root cause analysis | Failed task | Debug findings for Builder |
| 06 | **Reviewer** | Production-readiness review | Passing task | Approve or request changes |

---

## Step-by-Step: Running the Full Workflow

### Step 1: Start with the PM Agent

Tell your AI tool to load the PM agent and give it your idea.

**Claude Code / Cursor / Codex:**
```
Read ~/.agents/workflow/01-pm.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

Here's my idea: {describe your idea}
```

**Factory/Droid:**
```
Read ~/.agents/workflow/01-pm.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

Here's my idea: {describe your idea}
```

**What happens:**
- PM asks you clarifying questions (who, what, why, out of scope)
- You iterate back and forth until requirements are clear
- PM writes `~/.agents/artifacts/{project}/{feature}/prd.md`
- PM updates `status.md` to `PM_DONE`

**When done, PM will say:** "PRD is ready. Invoke the Planner agent."

---

### Step 2: Plan with the Planner Agent

Start a new session (or continue) and load the Planner.

```
Read ~/.agents/workflow/02-planner.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

The PRD is at ~/.agents/artifacts/{project}/{feature}/prd.md
```

**What happens:**
- Planner reads the PRD and explores the codebase
- Analyzes codebase health (dead code, redundancy, maintainability)
- Creates architecture decisions
- Breaks work into small, TDD-driven tasks with vertical slicing
- Adds checkpoints every 2-3 tasks for human review
- Writes `plan.md` and individual `tasks/T001.md`, `T002.md`, etc.
- Updates `status.md` to `PLAN_DONE`

**When done, Planner will say:** "Plan is ready with N tasks. Review plan.md before starting."

**YOU SHOULD:** Read `plan.md`, review the task list and codebase health findings, then approve or ask for changes before proceeding.

---

### Step 3: Build with the Builder Agent

Load the Builder to start implementing tasks one at a time.

```
Read ~/.agents/workflow/03-builder.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

The plan is at ~/.agents/artifacts/{project}/{feature}/plan.md
```

**What happens:**
- Builder picks up the first `PENDING` task whose dependencies are met
- Applies Simplicity First check before writing code
- Writes tests first (TDD: red -> green -> refactor)
- Implements the minimum code to pass tests
- Documents any adjacent issues as "NOTICED BUT NOT TOUCHING"
- Updates the task file with implementation notes
- Updates `status.md` to `TESTING_T{ID}`

**When done, Builder will say:** "Task T{ID} is implemented. Invoke the Tester agent."

---

### Step 4: Test with the Tester Agent

```
Read ~/.agents/workflow/04-tester.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

Task T{ID} is ready for testing.
```

**What happens:**
- Tester runs all automated tests (unit, lint, typecheck)
- Validates each acceptance criterion individually
- Performs exploratory edge-case testing
- Spot-checks code quality

**Two possible outcomes:**

**If tests PASS:**
- Updates `status.md` to `REVIEWING_T{ID}`
- Says: "Task T{ID} passed. Invoke the Reviewer agent."
- **Go to Step 6 (Reviewer)**

**If tests FAIL:**
- Updates `status.md` to `DEBUGGING_T{ID}`
- Says: "Task T{ID} failed. Invoke the Debugger agent."
- **Go to Step 5 (Debugger)**

---

### Step 5: Debug with the Debugger Agent (only if tests failed)

```
Read ~/.agents/workflow/05-debugger.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

Task T{ID} failed testing. Analyze the failures.
```

**What happens:**
- Debugger applies Stop-the-Line: all forward work halts
- Reproduces the failure
- Traces execution to find root cause (not just symptoms)
- Assesses blast radius (does this pattern exist elsewhere?)
- Writes debug findings with recommended fix and regression test
- Updates `status.md` to `BUILDING_T{ID}`

**When done, Debugger will say:** "Debug analysis complete. Invoke the Builder agent to implement the fix."

**Go back to Step 3 (Builder)** -- Builder reads the debug findings and implements the fix, then hands off to Tester again.

---

### Step 6: Review with the Reviewer Agent

```
Read ~/.agents/workflow/06-reviewer.md and follow its instructions.
Project: {your-project-name}, Feature: {feature-name}

Task T{ID} passed testing and is ready for review.
```

**What happens:**
- Reviewer evaluates code across 5 axes: Correctness, Readability, Architecture, Security, Performance
- Labels findings with severity: Critical / required / Nit / Optional / FYI
- Checks for dead code, change sizing, TypeScript quality

**Two possible outcomes:**

**If APPROVED:**
- Marks task as `DONE`
- If more tasks remain: "Task T{ID} approved. Invoke the Builder for the next task."
  - **Go back to Step 3 (Builder)** for the next task
- If all tasks done: "All tasks complete -- ready for PR."
  - Writes `review.md` with full feature summary
  - **You're done!**

**If CHANGES REQUESTED:**
- Updates `status.md` to `DEBUGGING_T{ID}`
- Says: "Task T{ID} needs changes. Invoke the Debugger agent."
- **Go to Step 5 (Debugger)**

---

## The Loop Visualized

```
          ┌──────────────────────────────────────────────────┐
          │                                                  │
Step 1    │  PM ──────► Planner ──────► Builder ──► Tester   │
          │  (01)       (02)           (03)        (04)      │
          │                                          │       │
          │                              ┌───────────┤       │
          │                              │ PASS  FAIL│       │
          │                              ▼           ▼       │
Step 6    │                          Reviewer    Debugger    │
          │                           (06)        (05)       │
          │                              │           │       │
          │                     ┌────────┤      back to      │
          │                     │ PASS   │FAIL  Builder      │
          │                     ▼        ▼                   │
          │                  PR Ready  Debugger              │
          │                              │                   │
          │                         back to Builder          │
          └──────────────────────────────────────────────────┘

Repeat Steps 3-6 for each task until ALL_TASKS_DONE.
```

---

## Checkpoints

The Planner inserts human review checkpoints every 2-3 tasks. When you reach a checkpoint:

1. Review the work completed so far
2. Verify the direction is still correct
3. Approve to continue, or adjust the plan

Checkpoints are documented in `plan.md` and `status.md`.

---

## Resuming Work

If you stop mid-workflow and come back later, check the status file:

```
Read ~/.agents/artifacts/{project}/{feature}/status.md

What is the current status and what agent should I invoke next?
```

The status file always records which agent to invoke next.

---

## File Locations

All artifacts are stored at `~/.agents/artifacts/{project}/{feature}/`:

```
~/.agents/artifacts/
  └── {project}/                   # project name
      └── {feature}/               # feature name
          ├── prd.md               # PM output
          ├── plan.md              # Planner output
          ├── status.md            # Current workflow state
          ├── review.md            # Reviewer final summary
          └── tasks/
              ├── T001.md          # Individual task files
              ├── T002.md
              └── T003.md
```

---

## Cross-Tool Skill & Command Syncing

This directory is the canonical source for portable AI **skills** and **commands**
shared across tools. You edit them here; the sync scripts symlink them into each
tool so every tool sees the same definitions.

### Convention

1. **Create here**: `~/.agents/skills/<skill-name>/SKILL.md` and
   `~/.agents/commands/<command>.md`.
2. **Never create directly** in a tool's own skills/commands dir.
3. **Run sync** after adding, updating, or removing a skill or command:

```bash
~/.agents/scripts/sync-all.sh            # sync skills + commands into all tools
~/.agents/scripts/sync-all.sh --dry-run  # preview changes
~/.agents/scripts/sync-all.sh --yes      # non-interactive (auto-replace stray copies)

# or individually:
~/.agents/scripts/sync-skills.sh
~/.agents/scripts/sync-commands.sh
```

### How Syncing Works

```
~/.agents/skills/    +  ~/.agents/commands/    <- canonical source of truth
  ├── <skill-a>/            ├── feature.md
  └── <skill-b>/            ├── pm.md, plan.md, …  (workflow)
                            └── <name>.md          (your skill commands)
        │
        ├── skills symlinked into:    ~/.claude/skills, ~/.cursor/skills, ~/.codex/skills
        └── commands symlinked into:  ~/.claude/commands, ~/.cursor/commands, ~/.codex/prompts
```

| Tool | Skills dir | Commands/prompts dir |
|------|-----------|----------------------|
| Cursor | `~/.cursor/skills/` | `~/.cursor/commands/` |
| Claude | `~/.claude/skills/` | `~/.claude/commands/` |
| Codex | `~/.codex/skills/` | `~/.codex/prompts/` |

Add more tools by editing the `TARGETS` array in the relevant sync script.
Each command/skill references its source by an `~/.agents/...` path, so it works
in any tool that can read files and call tools, regardless of model.

> **Note (Cursor):** some Cursor versions manage their own skills under
> `~/.cursor/skills-cursor/`. The sync scripts intentionally target
> `~/.cursor/skills/` and do not touch the managed dir.
