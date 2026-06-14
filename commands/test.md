---
title: "Workflow: Tester"
slug: /test
description: Run the Tester agent (04) — validate a task against tests and acceptance criteria.
tags: [command, workflow, agents, tester, validate, test]
---

# /test

Runs the **Tester** agent (stage 04 of the `~/.agents/workflow/` pipeline).
Tool-agnostic.

## What to do

1. **Read and follow** `~/.agents/workflow/04-tester.md` as the source of truth.
2. **Get the project and feature** from the input (`Project: <name>`,
   `Feature: <name>`); ask if either is missing.
3. Run all automated tests (unit, lint, typecheck), validate each acceptance
   criterion, and do exploratory edge-case checks.
4. Route by outcome via `status.md`:
   - **Pass** → set `REVIEWING_T{ID}`, hand off to the **Reviewer** (`/review`).
   - **Fail** → set `DEBUGGING_T{ID}`, hand off to the **Debugger** (`/debug`).

   (Or run `/feature` to auto-route.)

## Input

$ARGUMENTS
