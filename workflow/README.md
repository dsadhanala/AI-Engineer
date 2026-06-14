# workflow/

The **6-agent pipeline** that takes a feature from idea to production-ready code.
Each agent is a procedure (not a reference doc) with a distinct role, clear
inputs/outputs, and file-based handoffs via
`~/.agents/artifacts/{project}/{feature}/`. `status.md` is the single source of
truth for workflow state.

See [`../AGENTS.md`](../AGENTS.md) for status markers and design principles, and
[`../README.md`](../README.md#the-6-agent-workflow) for the full step-by-step
walkthrough.

## The agents

| # | Agent | Role | Input | Output |
|---|-------|------|-------|--------|
| 01 | [PM](01-pm.md) | Brainstorm, refine, write PRD | Your idea | `prd.md` |
| 02 | [Planner](02-planner.md) | Architecture, task breakdown | `prd.md` | `plan.md` + `tasks/T*.md` |
| 03 | [Builder](03-builder.md) | TDD implementation | Next pending task | Code + updated task file |
| 04 | [Tester](04-tester.md) | Validate, run tests | Completed task | Pass/fail verdict |
| 05 | [Debugger](05-debugger.md) | Root-cause analysis | Failed task | Debug findings for Builder |
| 06 | [Reviewer](06-reviewer.md) | Production-readiness review | Passing task | Approve or request changes |

## Flow

```
PM ─▶ Planner ─▶ Builder ─▶ Tester ─┬─ pass ─▶ Reviewer ─┬─ approve ─▶ next task / PR ready
                    ▲               │                    │
                    │               └─ fail ─▶ Debugger ─┘ changes ─▶ Debugger
                    └────────────── back to Builder ◀──────────────────┘
```

## Running it

The easiest way is the **commands** (see [`../commands/README.md`](../commands/README.md)):

```
/feature Project: {your-project}, Feature: {your-feature}    # start, then auto-route the loop

# or run a single stage directly:
/pm · /plan · /build · /test · /debug · /review
```

`/feature` starts a new feature at the PM agent, or resumes an in-progress one by
reading `status.md` and routing to whatever agent is next.

Without commands, point any tool at the agent file directly:

```
Read ~/.agents/workflow/01-pm.md and follow its instructions.
Project: {your-project}, Feature: {your-feature}

Here's my idea: {describe your idea}
```

Either way, follow each agent's handoff (recorded in `status.md`) through the
loop until `ALL_TASKS_DONE`. To resume later, read the feature's `status.md` — it
always records which agent to invoke next.
