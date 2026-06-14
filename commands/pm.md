---
title: "Workflow: PM"
slug: /pm
description: Run the PM / Ideation agent (01) — brainstorm, refine, and write the PRD.
tags: [command, workflow, agents, pm, ideation, prd]
---

# /pm

Runs the **PM / Ideation** agent (stage 01 of the `~/.agents/workflow/` pipeline).
Tool-agnostic.

## What to do

1. **Read and follow** `~/.agents/workflow/01-pm.md` as the source of truth for
   the process. Do not improvise a different one.
2. **Get the project and feature** from the input (`Project: <name>`,
   `Feature: <name>`); ask if either is missing.
3. Brainstorm with the user, then write
   `~/.agents/artifacts/{project}/{feature}/prd.md` and update `status.md` to
   `PM_DONE`.
4. When done, hand off to the **Planner** — run `/plan` (or `/feature` to
   auto-route).

## Input

$ARGUMENTS
