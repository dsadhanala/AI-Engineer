---
title: "Workflow: Planner"
slug: /plan
description: Run the Planner / Architect agent (02) — architecture decisions and TDD task breakdown.
tags: [command, workflow, agents, planner, architect, plan]
---

# /plan

Runs the **Planner / Architect** agent (stage 02 of the `~/.agents/workflow/`
pipeline). Tool-agnostic.

## What to do

1. **Read and follow** `~/.agents/workflow/02-planner.md` as the source of truth.
2. **Get the project and feature** from the input (`Project: <name>`,
   `Feature: <name>`); ask if either is missing. The PRD is at
   `~/.agents/artifacts/{project}/{feature}/prd.md`.
3. Read the PRD, explore the codebase, make architecture decisions, and break the
   work into small TDD tasks with checkpoints. Write `plan.md` and
   `tasks/T001.md`, `T002.md`, … and update `status.md` to `PLAN_DONE`.
4. When done, ask the user to review `plan.md` before building, then hand off to
   the **Builder** — run `/build` (or `/feature` to auto-route).

## Input

$ARGUMENTS
