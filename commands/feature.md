---
title: "Feature Workflow"
slug: /feature
description: Drive the 6-agent ideation→production workflow. Starts at PM for a new idea, or resumes to the next agent via status.md.
tags: [command, workflow, agents, feature, orchestrator, pm, plan, build, test, debug, review]
---

# /feature

Tool-agnostic orchestrator for the 6-agent workflow in `~/.agents/workflow/`.
It either starts a new feature at the PM agent or resumes an in-progress feature
by routing to whatever agent `status.md` says is next. Works in Cursor, Claude,
Codex, Augment, Droids, etc.

## What to do

1. **Determine the project and feature** from the input:
   - Look for `Project: <name>` and `Feature: <name>`.
   - If either is missing, ask the user before proceeding — they namespace the
     artifact directory `~/.agents/artifacts/{project}/{feature}/`.

2. **Check for existing state** at
   `~/.agents/artifacts/{project}/{feature}/status.md`:
   - **If it exists** — read it, find the `## Next Agent:` line, and **read and
     follow** the matching agent file (table below). After that agent finishes
     and updates `status.md`, continue routing to the next one.
   - **If it does not exist** — this is a new feature. **Read and follow**
     `~/.agents/workflow/01-pm.md` with the user's idea.

3. **Routing table** (`Next Agent` → file to read and follow):

   | Next Agent | File | Verb command |
   |------------|------|--------------|
   | PM (01) | `~/.agents/workflow/01-pm.md` | `/pm` |
   | Planner (02) | `~/.agents/workflow/02-planner.md` | `/plan` |
   | Builder (03) | `~/.agents/workflow/03-builder.md` | `/build` |
   | Tester (04) | `~/.agents/workflow/04-tester.md` | `/test` |
   | Debugger (05) | `~/.agents/workflow/05-debugger.md` | `/debug` |
   | Reviewer (06) | `~/.agents/workflow/06-reviewer.md` | `/review` |

4. **Respect the handoff contract**: every agent reads from and writes to
   `~/.agents/artifacts/{project}/{feature}/` and updates `status.md`, which is
   the single source of truth for state. Never skip ahead of what it says. Stop
   at the human-review checkpoints noted in `plan.md` / `status.md` and wait for
   approval before continuing.

5. **Direct invocation**: to run one stage instead of auto-routing, use the
   per-stage commands `/pm`, `/plan`, `/build`, `/test`, `/debug`, `/review`.

## Input

$ARGUMENTS
