# Code Review Report — Output Template

Write results to `Code-Review.md` in the workspace root using this structure.

---

```markdown
# Code Review

| Field | Value |
|-------|-------|
| **PR** | #<number> (or "local changes") |
| **Title** | <PR title or branch name> |
| **Author** | <author> |
| **Files Reviewed** | <count> |
| **Risk Level** | Low / Medium / High / Critical |

## Summary

<2-4 sentence overview: what the change does, overall quality assessment, top concern if any.>

## Highlights

<Optional. 1-3 things done well — good abstractions, thorough tests, clean refactoring. Keep brief.>

## Findings

### Critical

> Items that must be fixed before merge.

#### <N>. <Short title> — `<file>:<line>`

**Category**: <dimension name>
**Code**:
\`\`\`typescript
<exact code from diff>
\`\`\`
**Issue**: <what's wrong and why it matters>
**Suggested fix**:
\`\`\`typescript
<concrete fix>
\`\`\`

---

### Major

> Items that should be fixed — performance, maintainability, missing tests.

#### <N>. <Short title> — `<file>:<line>`

**Category**: <dimension name>
**Code**:
\`\`\`typescript
<exact code from diff>
\`\`\`
**Issue**: <explanation>
**Suggested fix**: <description or code>

---

### Minor

> Optional improvements — readability, style alignment.

#### <N>. <Short title> — `<file>:<line>`

**Category**: <dimension name>
**Issue**: <brief explanation>
**Suggestion**: <brief suggestion>

---

### Pre-existing Issues

> Issues in unchanged code surrounding the diff. Awareness only — not blocking merge.

#### <N>. <Short title> — `<file>:<line>`

**Category**: <dimension name>
**Issue**: <brief explanation>

---

## Unused & Redundant Code

| Item | File | Type | Recommendation |
|------|------|------|----------------|
| <name> | `<file>` | Dead export / Unused import / Redundant util / etc. | Remove / Replace with X |

## Verdict

**<PASS / PASS WITH SUGGESTIONS / NEEDS CHANGES>**

<1-2 sentence final assessment summarising blocking items and recommended next step.>
```

---

## Risk Level Rubric

| Level | Criteria |
|-------|----------|
| **Low** | Small change, well-tested, no public API impact |
| **Medium** | Moderate scope, some missing tests or minor pattern drift |
| **High** | Large scope, public API changes, performance implications, incomplete tests |
| **Critical** | Security issues, data integrity risks, breaking changes without migration |
