# Feature Status: {feature}

## Status: {PM_IN_PROGRESS | PM_DONE | PLANNING | PLAN_DONE | BUILDING_T{ID} | TESTING_T{ID} | DEBUGGING_T{ID} | REVIEWING_T{ID} | TASK_DONE_T{ID} | ALL_TASKS_DONE}

## Last Updated: {timestamp}

## Project: {project}

## Feature: {feature}

## Next Agent: {PM (01) | Planner (02) | Builder (03) | Tester (04) | Debugger (05) | Reviewer (06)}

## Summary: {one-line summary of current state}

## Task Progress
| Task | Title | Status | Type |
|------|-------|--------|------|
| T001 | {title} | PENDING | FEATURE |
| T002 | {title} | PENDING | CLEANUP |

## Checkpoints
- [ ] Checkpoint 1: {description} - After T{NNN}
- [ ] Checkpoint 2: {description} - After T{NNN}

## Artifacts
- PRD: `~/.agents/artifacts/{project}/{feature}/prd.md`
- Plan: `~/.agents/artifacts/{project}/{feature}/plan.md`
- Tasks: `~/.agents/artifacts/{project}/{feature}/tasks/`
- Review: `~/.agents/artifacts/{project}/{feature}/review.md`
