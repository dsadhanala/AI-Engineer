# templates/

Reusable templates the workflow agents copy into a feature's artifact directory
(`~/.agents/artifacts/{project}/{feature}/`). They define the canonical shape of
the files agents read and write, so handoffs stay consistent.

## Templates

| Template | Used by | Becomes |
|----------|---------|---------|
| `task.md` | Planner / Builder | Each `tasks/T{NNN}.md` — title, status, type, description, acceptance criteria, test plan. |
| `status.md` | All agents | The feature's `status.md` — current status marker, next agent, and task progress (the single source of truth for workflow state). |

These are filled-in placeholders (`{feature}`, `T{NNN}`, status markers like
`PLAN_DONE` / `BUILDING_T{ID}`). See [`../AGENTS.md`](../AGENTS.md) for the full
list of status markers and the handoff contract.
