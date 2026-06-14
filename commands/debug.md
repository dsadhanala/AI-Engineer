---
title: "Workflow: Debugger"
slug: /debug
description: Run the Debugger agent (05) — root-cause analysis for a failed or rejected task.
tags: [command, workflow, agents, debugger, root-cause, debug]
---

# /debug

Runs the **Debugger** agent (stage 05 of the `~/.agents/workflow/` pipeline).
Tool-agnostic.

## What to do

1. **Read and follow** `~/.agents/workflow/05-debugger.md` as the source of truth.
2. **Get the project and feature** from the input (`Project: <name>`,
   `Feature: <name>`); ask if either is missing.
3. Apply Stop-the-Line: reproduce the failure, trace to the **root cause** (not
   symptoms), assess blast radius, and write debug findings with a recommended
   fix and regression test. Set `status.md` to `BUILDING_T{ID}`.
4. When done, hand off to the **Builder** to implement the fix — run `/build`
   (or `/feature` to auto-route).

## Input

$ARGUMENTS
