# Run brief

## Goal
<objective>

## Base branch
<base_branch>. The brain's branch. Workers never commit to it, merge into it, or push it; finished work reaches it only through a pull request that the user merges.

## Constraints
- <invariants, excluded work, budget limits, user-required models>

## Project rules
All workers read the same rules file regardless of host: <path to CLAUDE.md or AGENTS.md>.

## Decisions
<!-- coordinator only, append-only: date - decision - why. Over 30 lines: summarize and move old entries to archive/decisions.md -->

## File ownership
- `brief.md`, `ledger.json`: coordinator only (ledger through scripts/orca_run.py).
- `context/<topic>.md`, `tasks/<slug>.md`, `reports/<slug>.md`: only the worker assigned that topic or slug.
- `harness-notes.md`, `../project-notes.md`: only through `orca_run.py refine-add`; read both before starting.
- Never edit another worker's file. Never edit anything under `archive/`.

## Context file format
First line `Base: <commit sha>` (the HEAD you read). Cite code as `path:line - one line`. At most 80 lines.

## Report format
Write `reports/<slug>.md` with exactly these headings, in this order, then run
`python3 <skill>/scripts/orca_run.py check-report <file>` and fix until it prints `report ok`.
Write a report on failure too.

```
## Verdict
succeeded | failed | partial

## Commits
Branch: <branch>
<sha> <subject>
(or: none - <reason>, for read-only work)

## Changes
- path - one line

## Evidence
- command -> result (last lines only)

## Decisions made
- decision - why, including anything agreed directly with another worker

## Open issues
- issue - suggested owner

## Details
Anything longer. The coordinator does not read this section by default.
```

Sections above Details: at most 30 lines.
