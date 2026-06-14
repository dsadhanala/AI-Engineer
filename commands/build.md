---
title: "Workflow: Builder"
slug: /build
description: Run the Builder agent (03) — TDD implementation of the next pending task.
tags: [command, workflow, agents, builder, tdd, implement]
---

# /build

Runs the **Builder** agent (stage 03 of the `~/.agents/workflow/` pipeline).
Tool-agnostic.

## What to do

1. **Read and follow** `~/.agents/workflow/03-builder.md` as the source of truth.
2. **Get the project and feature** from the input (`Project: <name>`,
   `Feature: <name>`); ask if either is missing. The plan and tasks are under
   `~/.agents/artifacts/{project}/{feature}/`.
3. Pick up the next `PENDING` task whose dependencies are met (or implement the
   fix from a Debugger's findings). Apply Simplicity First, write tests first
   (red → green → refactor), update the task file, and set `status.md` to
   `TESTING_T{ID}`.
4. When done, hand off to the **Tester** — run `/test` (or `/feature` to
   auto-route).

## Input

$ARGUMENTS
