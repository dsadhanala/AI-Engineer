# AI-Engineer
All about AI and agentic workflows to boost developer productivity

## Multi-Agent Development Workflow

A 6-agent system that takes from ideation to production-ready code. Works with any AI coding tool (Claude Code, Cursor, Factory/Droid, Codex, etc.).

## Quick Reference

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
  └── my-project/                  # project name
      └── my-feature/              # feature name
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

## Cross-Tool Skill Syncing

This directory also serves as the canonical source for personal AI skills shared across tools.

### Convention

1. **Create skills here**: `~/.agents/skills/<skill-name>/SKILL.md`
2. **Never create directly** in `~/.cursor/skills/`, `~/.claude/skills/`, or `~/.codex/skills/`
3. **Run sync** after adding or removing a skill:

```bash
~/.agents/scripts/sync-skills.sh          # sync all skills
~/.agents/scripts/sync-skills.sh --dry-run # preview changes
```

### How Syncing Works

```
~/.agents/skills/          <- canonical source of truth
  ├── code-reviewer/
  ├── writing-editor/
  ├── ...
  │
  ├── symlinked into:
  │   ├── ~/.claude/skills/    (Claude Code)
  │   ├── ~/.cursor/skills/    (Cursor)
  │   └── ~/.codex/skills/     (Codex)
  │
  └── NOT linked into (different formats):
      ├── ~/.factory/droids/   (Factory -- uses droids/, not skills/)
      └── ~/.gemini/           (Gemini -- uses GEMINI.md, no skills dir)
```

| Tool | Skills Dir | Managed Skills (don't touch) |
|------|-----------|------------------------------|
| Cursor | `~/.cursor/skills/` | `~/.cursor/skills-cursor/` (built-in) |
| Claude | `~/.claude/skills/` | -- |
| Codex | `~/.codex/skills/` | `~/.codex/skills/.system/` (built-in) |
| Factory | `~/.factory/droids/` | Mission-specific, not portable |
| Gemini | `~/.gemini/GEMINI.md` | No skills infrastructure |

### Recommended Additional Skills

The skills bundled in this repo (`code-reviewer`, `writing-editor`) are the ones authored here. Several other skills pair well with this workflow but live in upstream public repos — install them separately into `~/.agents/skills/` and then run `~/.agents/scripts/sync-skills.sh`:

| Skill | Source |
|-------|--------|
| `skill-creator` | [anthropics/skills](https://github.com/anthropics/skills) |
| `mcp-builder` | [anthropics/skills](https://github.com/anthropics/skills) |
| `webapp-testing` | [anthropics/skills](https://github.com/anthropics/skills) |
| `frontend-design` | [anthropics/skills](https://github.com/anthropics/skills) |
| `doc-coauthoring` | [anthropics/skills](https://github.com/anthropics/skills) |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills) |
