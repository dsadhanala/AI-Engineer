---
title: "Workflow: Reviewer"
slug: /review
description: Run the workflow Reviewer agent (06) — production-readiness review of a passing task.
tags: [command, workflow, agents, reviewer, production-readiness, review]
---

# /review

Runs the **Reviewer** agent (stage 06 of the `~/.agents/workflow/` pipeline).
Tool-agnostic.

> `/review` is the **workflow stage** that reviews a task which just passed
> testing. If you add a standalone code-review skill, give its command a distinct
> slug (e.g. `/reviewer`) so it doesn't clash with this one.

## What to do

1. **Read and follow** `~/.agents/workflow/06-reviewer.md` as the source of truth.
2. **Get the project and feature** from the input (`Project: <name>`,
   `Feature: <name>`); ask if either is missing.
3. Review the passing task across the axes in the agent file and label findings
   by severity.
4. Route by outcome via `status.md`:
   - **Approved, more tasks remain** → hand off to the **Builder** for the next
     task (`/build`).
   - **Approved, all tasks done** → set `ALL_TASKS_DONE`, write `review.md`. Done.
   - **Changes requested** → set `DEBUGGING_T{ID}`, hand off to the **Debugger**
     (`/debug`).

   (Or run `/feature` to auto-route.)

## Input

$ARGUMENTS
