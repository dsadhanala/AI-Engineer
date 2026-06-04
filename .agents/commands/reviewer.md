---
title: "Code Reviewer"
slug: /reviewer
description: Expert code review of a PR or local/staged changes, backed by the code-reviewer skill.
tags: [command, review, code-review, pr, staged, quality]
---

# /reviewer

Tool-agnostic command that runs an expert code review using the canonical
`code-reviewer` skill. Works in Cursor, Claude, Codex, Augment, Droids, etc.

## What to do

1. **Read and follow** `~/.agents/skills/code-reviewer/SKILL.md`
   (and its `references/` files) as the source of truth for the workflow,
   review dimensions, and output format. Do not improvise a different process.

2. **Determine the review scope** from the input after the command:
   - A **PR number or URL** (e.g. `277917`, or a `github.com` URL)
     → PR review via the matching GitHub MCP, per the skill's "Getting the Diff → Option A".
   - **"staged"** or no input → **staged changes only** (`git diff --cached`).
     This is the default. Do not widen scope to the whole branch.
   - **"branch" / "my changes" / "local"** → whole-branch diff vs `main`.
   - If ambiguous, run `git status -s` and confirm before proceeding.

3. **Apply the review** exactly as the skill specifies, including the
   repo-specific dimensions.

4. **Output** per the skill: always give the conversational, file-by-file
   walkthrough (what changed, why, findings by severity). Write the full
   report to `~/.agents/artifacts/code-reviews/` only when the
   review is PR-scale / large / many findings, using the skill's filename
   scheme:
   - PR: `code-review_PR-${NUMBER}_${date}_${time}.md`
   - Local/staged: `code-review_${date}_${time}.md`

## Input

$ARGUMENTS
