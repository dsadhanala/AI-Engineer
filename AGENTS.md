# Agent System

A multi-agent development workflow for taking ideas from ideation to production-ready code. Each agent has a distinct role, clear inputs/outputs, and file-based handoff contracts.

## Directory Structure

```
~/.agents/
├── AGENTS.md                  # This file - system overview and conventions
├── workflow/                    # Agent definitions
│   ├── 01-pm.md               # Product Manager / Ideation
│   ├── 02-planner.md          # Planner / Architect
│   ├── 03-builder.md          # Engineer / Builder
│   ├── 04-tester.md           # Tester
│   ├── 05-debugger.md         # Debugger
│   └── 06-reviewer.md         # Reviewer
├── skills/                    # Portable AI skills (bring your own; synced into each tool)
│   └── <name>/                #   each skill: SKILL.md (+ optional README.md, references/)
├── commands/                  # Slash commands / prompts (synced into each tool)
│   ├── feature.md             #   /feature  (workflow orchestrator)
│   ├── pm|plan|build|test|debug|review.md   # workflow stages 01–06
│   └── <name>.md              #   optional per-skill commands you add
├── scripts/                   # Cross-tool sync tooling
│   ├── sync-all.sh
│   ├── sync-skills.sh
│   ├── sync-commands.sh
│   └── lib/sync-common.sh
├── setup.sh                   # One-command install on a new machine
├── templates/                 # Reusable templates
│   ├── task.md
│   └── status.md
└── artifacts/                 # Runtime artifacts (git-ignored, per-project/feature)
    └── {project}/
        └── {feature}/
            ├── prd.md         # PM output
            ├── plan.md        # Planner output
            ├── tasks/         # Individual task files (T001.md, ...)
            ├── status.md      # Current workflow status
            └── review.md      # Reviewer output
```

## Workflow

```
User (idea)
  │
  ▼
┌─────────┐     ┌──────────┐     ┌──────────┐     ┌─────────┐
│   PM    │────▶│ Planner  │────▶│ Builder  │────▶│ Tester  │
│ (01)    │     │ (02)     │     │ (03)     │     │ (04)    │
└─────────┘     └──────────┘     └──────────┘     └────┬────┘
  writes:         writes:          writes:              │
  prd.md          plan.md          code +          ┌────┴────┐
                  tasks/T*.md      updates T*.md   │ PASS?   │
                                                   └────┬────┘
                                                   yes  │  no
                                              ┌─────────┴─────────┐
                                              ▼                   ▼
                                        ┌──────────┐       ┌──────────┐
                                        │ Reviewer │       │ Debugger │
                                        │ (06)     │       │ (05)     │
                                        └────┬─────┘       └────┬─────┘
                                             │                   │
                                        ┌────┴────┐         findings
                                        │ PASS?   │         back to
                                        └────┬────┘         Builder
                                        yes  │  no             │
                                        ┌────┴────┐            │
                                        ▼         ▼            │
                                     PR Ready   Debugger ◀─────┘
                                                   │
                                              back to Builder
```

## Handoff Contract

Each agent reads from and writes to `~/.agents/artifacts/{project}/{feature}/`. The `status.md` file is the single source of truth for workflow state.

### Status Markers

| Status | Meaning |
|--------|---------|
| `PM_IN_PROGRESS` | PM is brainstorming with user |
| `PM_DONE` | PRD complete, ready for Planner |
| `PLANNING` | Planner is creating task breakdown |
| `PLAN_DONE` | Plan complete, ready for Builder |
| `BUILDING_T{ID}` | Builder is working on task {ID} |
| `TESTING_T{ID}` | Tester is validating task {ID} |
| `DEBUGGING_T{ID}` | Debugger is analyzing failure for task {ID} |
| `REVIEWING_T{ID}` | Reviewer is reviewing task {ID} |
| `TASK_DONE_T{ID}` | Task {ID} passed review |
| `ALL_TASKS_DONE` | All tasks complete, ready for PR |

## Project Context Discovery

Agents are project-agnostic by default. They discover project conventions by reading:
1. `CLAUDE.md` or `AGENTS.md` at the project root
2. `README.md` for project overview
3. `package.json`, `BUILD.bazel`, `Makefile`, etc. for build system
4. Existing code patterns in the relevant directories
5. `.cursor/rules/`, `.claude/rules/` for tool-specific conventions

**Two layers of context, both consulted:**
- **Per-repo (primary):** the target repo's own `CLAUDE.md`/`AGENTS.md` and the
  files above. This is the source of truth for build/test commands and
  conventions specific to that codebase, and it travels with the code.
- **Personal defaults:** `~/.agents/docs/profile.md` (and `profile.local.md` if
  present) carry your default stack, build/test commands, and habits. Consult
  them so direct stage invocation inherits the same context as a tool that loads
  its memory file. When reviewing code, also apply the review lenses in
  `~/.agents/skills/code-reviewer/references/project-profile.md` if it exists.

Per-repo context wins on conflict; personal defaults fill the gaps.

## How to Use

1. **Start a feature**: Tell the PM agent your idea. It will create the artifact directory and `prd.md`.
2. **Plan**: Invoke the Planner agent. It reads `prd.md` and creates `plan.md` + task files.
3. **Build**: Invoke the Builder agent. It picks up the next pending task and implements it.
4. **Test**: Builder signals completion. Invoke the Tester agent to validate.
5. **Debug** (if needed): On test failure, invoke the Debugger. It writes findings for Builder.
6. **Review**: On test pass, invoke the Reviewer. It either approves or sends back to Debugger.
7. **Repeat** steps 3-6 for each task until `ALL_TASKS_DONE`.

Each step can be invoked with a **command** (`commands/`, synced into every tool)
or by referencing the agent file directly.

### Quick Start

```
# Easiest — use the commands:
/feature Project: {your-project}, Feature: {your-feature}   # start, then auto-route the loop
#   or run a single stage:  /pm  /plan  /build  /test  /debug  /review

# Or, with any AI tool, reference the agent file directly:
# "Read ~/.agents/workflow/01-pm.md and follow its instructions.
#  Project: {your-project}, Feature: {your-feature}"
```

## Design Principles

Every agent in this system follows these principles, adapted from production engineering best practices:

### Process, Not Prose
Agents follow workflows with steps, checkpoints, and exit criteria. They are not reference docs to read -- they are procedures to execute.

### Anti-Rationalization
Every agent includes a table of common excuses for skipping steps (e.g., "I'll add tests later") with documented counter-arguments. This prevents the most common agent failure mode: taking shortcuts.

### Verification is Non-Negotiable
Every agent ends with a verification checklist. "Seems right" is never sufficient. Evidence is required: tests passing, build output, documented results.

### Chesterton's Fence
Before removing or changing existing code, understand why it exists. Check git blame, check callers, understand the original context. Only then decide if the reason still applies.

### Stop-the-Line
When anything unexpected happens (test failure, build break, unexpected behavior), STOP all forward progress. Preserve evidence, diagnose, fix, guard against recurrence, then resume.

### Scope Discipline
Each agent touches only what its role requires. Adjacent improvements are documented as "NOTICED BUT NOT TOUCHING" and handled in separate tasks.

### Simplicity First
Before writing any code: "What is the simplest thing that could work?" Three similar lines of code is better than a premature abstraction. Implement the naive, obviously-correct version first.

### Severity Labels
Review findings are labeled (Critical / required / Nit / Optional / FYI) so everyone knows what's blocking vs. optional. Every "no" comes with a "here's how to fix it."

### Feasibility Before Architecture
When the plan proposes reusing shared infrastructure (shared modules, clients, services/stores), the Planner must trace the full dependency chain in the target surface before committing. "Works in surface A" does not mean "works in surface B." A standalone 150-line implementation is better than a 50-line facade around shared infra that brings 5 unverified transitive dependencies. Resolve HIGH risks during planning — deferring to implementation is not mitigation.

### Layer Budget
Count the abstraction layers between "user action" and "system effect." Target ≤ 3. Every additional layer adds integration surface, failure modes, and debugging complexity. If the architecture has 4+ layers, challenge whether each is earning its keep.
