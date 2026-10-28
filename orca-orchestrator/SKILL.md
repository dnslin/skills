---
name: orca-orchestrator
description: >-
  Run a brain-and-workers setup on Orca from Claude Code, Codex, or OMP: the
  current session plans, dispatches, supervises, and accepts, while Orca workers
  write the code. Use when the user wants to delegate or orchestrate work, run
  parallel workers, split a feature across agents, or get an independent review
  through Orca (also 派发, 编排, 多 Agent). Passes context through files so the
  coordinator's context stays small. For an unsupervised ownership transfer,
  use Orca's orca-cli skill instead.
---

# Orca Orchestrator

You are the **brain**: the session the user talks to, on any host (Claude Code, Codex, OMP). Orca workers are the hands. Your context is the scarcest resource in the run: it holds goals, decisions, short summaries, and file paths. Everything bulky lives on disk and is read by workers.

`RUNPY` below means `python3 <this-skill-dir>/scripts/orca_run.py`.

## 1. Roles and rules

- **Worker check first.** If your prompt holds a live Orca preamble with Task and Dispatch IDs, you are a worker. Follow the preamble and Orca's worker contract, plus the `Read first`, ownership, and `Report` lines of your spec.
- **The brain does not write code.** Every code change, including one-line fixes, goes to a worker. The brain edits only `brief.md`, and the ledger only through `RUNPY`. The one exception is the user explicitly telling the brain to make an edit.
- **The base branch is the brain's branch.** Work reaches it only through a pull request that the user merges. No one, brain or worker, commits to it, merges into it, or pushes it.
- **Any host can dispatch any agent.** Pick workers with `--agent claude|codex|omp|…`. Workers run on this machine; do not use remote placement (`--on`).
- **Authority.** The user chooses which agent does which kind of work (section 5); the brain may then choose model and effort within that agent. Explicit user choices, budget limits, and project rules win. Ask before running more than 4 workers at once or more than one at maximum effort. Model choice never authorizes extra scope, releases, or deployments.
- **The user can talk to a worker directly.** The user's instruction wins; the worker tells the brain with `send` and records it under Decisions made.

## 2. Load Orca

1. Resolve the executable once, as Orca's `orchestration` skill says: `$ORCA_CLI_COMMAND` if set; else `orca-dev` in a dev checkout exposing `ORCA_DEV_REPO_ROOT`; else `orca-ide` on Linux outside an Orca terminal (bare `orca` there starts the GNOME screen reader); else `orca`. Below, `ORCA` means that executable. If it fails, report the exact error and stop.
2. Run `ORCA skills get orchestration` once and treat it as the protocol source of truth. Load its `--reference` files only at the gates it names (new worktrees: `placement-and-remote.md`).
3. `ORCA status --json`, then `ORCA orchestration run-create --objective "<objective>" --json`.
4. Workers use Orca's default permissions. A worker blocked by a permission prompt must `ask` the brain instead of waiting; treat it as a tool failure (section 6).

For an unsupervised handoff, use `ORCA skills get orca-cli` instead and stop here.

## 3. The run folder

```text
RUN=$(RUNPY init <workspace> <run_id> --objective "<one line>" [--base <branch>])
```

This records the base branch (the brain's current branch unless `--base` is given; it fails on a detached HEAD), creates `<workspace>/.orca-run/<run_id>/` from the template, creates `.orca-run/project-notes.md` if this is the first run, and, in Git, adds `.orca-run/` to `.git/info/exclude`. Fill in `brief.md` (goal, constraints, the one project-rules file every worker must read: `CLAUDE.md` or `AGENTS.md`).

| File | Only writer | Holds |
| --- | --- | --- |
| `brief.md` | brain | Goal, constraints, project rules, decisions, file ownership, report format |
| `ledger.json` | `RUNPY` | Acceptance state per task: agent, why, model, branch, commits, report, result, rework count |
| `context/<topic>.md` | that topic's scout | Code map; first line `Base: <sha>` |
| `tasks/<slug>.md` | that slug's worker | Full plan |
| `reports/<slug>.md` | that slug's worker | Result in the report format |
| `harness-notes.md` | `RUNPY refine-add` | Refine notes for this run only |
| `../project-notes.md` | `RUNPY refine-add --scope project` | Refine notes kept across runs: commands, conventions, pitfalls |
| `../refine-log.jsonl` | `RUNPY` | Every refine change: trigger, note, scope, result, reverted |
| `archive/` | `RUNPY` | Finished tasks and old decisions |

Orca's `task-list` and `worker-list` are the source of truth for execution state; the ledger records only what Orca does not know (acceptance, rationale, paths). Give workers absolute paths.

**Ledger commands:** `RUNPY task-add --run $RUN --slug <s> --agent <a> --why "<one line>" --context <topics>`, `RUNPY task-set --run $RUN --slug <s> --status <planned|dispatched|review|accepted|rejected|failed> [--dispatch --model --branch --commits --report --pr --result --rework]`, `RUNPY show --run $RUN`.

**Budget rules for the brain:**

- Do not read source files, diffs, test logs, or transcripts. If you need to know something about the code, dispatch a scout.
- Do not load implementation or review skills (debugging, TDD, code review, planning) yourself. Name them on the spec's `Skills:` line; workers read them.
- Read reports by section: `sed -n '/^## Verdict/,/^## Decisions made/p' <report>`.
- Trim every command you run: `--json` with `jq`, or `| tail -n 20`. Use `task-list --ready --brief`; `worker-read --limit 20` only during recovery.

## 4. Split and specify

**Task size.** Every worker starts cold and reads the brief and context, so each dispatch has a fixed cost. Merge related small edits into one task; split only where a part can be accepted on its own. For a large effort, dispatch a planner worker to draft the task graph into `tasks/plan.md`, and show the user any graph over 8 tasks before starting.

**Spec by pointer** (about 12 lines; Orca requires Target, Change, Constraints, Ownership, Acceptance):

```text
Task: <slug> - <one-line change>
Intent: <at most 5 lines, including must / must-not>
Read first: <workspace>/.orca-run/project-notes.md, <RUN>/harness-notes.md, <RUN>/brief.md, <RUN>/context/<topic>.md[, <RUN>/reports/<slug>.md from the failed attempt]
Target: <files, component, or environment>
Constraints: <invariants, do-not-touch>
Ownership: may edit <paths>; write only <RUN>/tasks/<slug>.md and <RUN>/reports/<slug>.md
Placement: branch orca/<run_id>/<slug> from <base branch>; commit only there, never to the base branch
Acceptance: <command or evidence that proves completion>
Skills: <skill names or entry-point paths>
Plan gate: <required | skip>
Report: follow the report format in brief.md, pass RUNPY check-report, then worker_done
  with --report-path and --files-modified
```

**Scout (RLM-style reading).** The codebase is the external environment; the brain never loads it. A read-only scout writes `context/<topic>.md` (`Base: <sha>`, `path:line - one line`, interfaces, risks, open questions; at most 80 lines) and edits nothing. The brain reads only the `worker_done` summary and Open questions. For a large area the scout may start helpers through Orca's nested dispatch. Before reusing context in a later wave, run `RUNPY check-context --run $RUN`; re-scout any file it reports as stale.

**Exploration fan-out.** When the direction is open (an approach to choose, a root cause to find), dispatch several read-only scouts in parallel, each on a different direction, never the same task twice. Each writes `context/<topic>-<direction>.md`; compare their summaries and pick a direction, recording the choice under Decisions.

**Plan gate.** The worker expands the intent into `tasks/<slug>.md`. When the spec says `Plan gate: required` (default for anything beyond a small, clear change), it then sends an `ask` of at most 10 lines: approach, files to touch, any deviation from the intent, assumptions. It writes code only after the brain approves or redirects. The plan is judged against the intent's must / must-not lines and Acceptance, not against unstated wishes. For a large or ambiguous task, a separate planning worker may write the plan first.

## 5. Choose the agent and model

**Agent choice is confirmed by the user.**

1. Look for an `Agent defaults:` note in `project-notes.md`, such as `Agent defaults: implement=codex, scout=claude, review=claude`.
2. Before the first wave, show the user a dispatch plan, one line per task: `slug - kind - agent - model/effort - why`. Mark the agents taken from the defaults. If there are no defaults, ask which agent should do each kind of work, and propose an answer. Wait for confirmation or edits; do not start any worker before that.
3. When the user confirms or changes the mapping, record it: `RUNPY refine-add --run $RUN --scope project --trigger "user set agent defaults" --note "Agent defaults: ..."`. Revert the old note when it changes.
4. Later in the run, use the confirmed mapping without asking again. Ask again only for a kind of work it does not cover, or before deviating from it.
5. Always pass `--agent` explicitly; never rely on Orca's default agent. Check the launch receipt's agent; if it differs from the plan, stop that worker and report it. A retry that reuses a terminal may report no agent; record the agent of the original start.

Within the confirmed agent, choose model and effort in this order: **required access and tools → task capability → difficulty of verification → expected total time and cost.**

| Task | Preference |
| --- | --- |
| Bounded, routine, easy to check | Fast reliable model, low or normal effort |
| Standard feature with established patterns | Capable general model, normal effort |
| Unclear root cause, architecture trade-offs, complex interactions | Stronger reasoning, more effort |
| Scout, planner, or reviewer | A model able to read the whole area; for review, a different model from the implementer |

Record one sentence of rationale with `--why`. Compare `launch.effective` with `launch.requested` and record the effective model. If an automatically chosen model is unavailable, pick another within the same agent; if the confirmed agent or a user-required model is unavailable, ask the user instead of switching agents.

## 6. Dispatch and supervise

- **Isolation.** Every task that writes code, parallel or sequential, gets its own worktree (`--worktree new-child --name <slug> --setup run`) and branch `orca/<run_id>/<slug>`, cut from the base branch. The current worktree holds the base branch, so only read-only scouts and reviewers may use `--worktree current`.
- **Waves.** Register tasks with `RUNPY task-add` and Orca `task-create` (`--deps` only for real ordering). Start the whole independent wave before waiting, then loop on `check --wait` as Orca's guide describes.
- **Each delivery:** answer questions and plan gates with `reply`; validate `worker_done`; update the ledger with `task-set`; decide reuse, retain, or release; then `--ack`.
- **Steering.** Correct a running worker with `ORCA orchestration send --to dispatch:<id>`; workers read these at each checkpoint.
- **Worker-to-worker.** Workers sharing an interface may coordinate directly through Orca group addresses (`@all`, `@<agent>`, `@worktree:<id>`) within the Run, to keep the brain out of the loop. Every agreement they make goes under Decisions made in both reports. Helpers report to the worker that started them.
- **Repair by cause:** missing context → add a file and send its path; tool, auth, permission, or rate-limit failure → fix that cause; localized defect → follow-up to the same owner with the report path; repeated failure without new evidence → change approach, task boundary, or agent. A retry's spec always links the failed attempt's report.

## 7. Accept: the brain decides, workers inspect

Run these layers in order; any failure sends the task back.

1. **Worker self-check** (every task): the acceptance command's result is in Evidence and `check-report` passes. This is input, not acceptance.
2. **Brain gate** (every task): `RUNPY check-report <report>`; read Verdict, Commits, Changes, Evidence; rerun the acceptance command yourself if its output is short (do not write your own test scripts; put extra checks in the reviewer's spec); run `git diff --stat <base>..<branch>` and confirm only owned paths changed.
3. **Independent review** (when the change crosses modules, changes a public interface, touches security or data, is user-visible, was already reworked once, or you have doubts): dispatch a reviewer on another model with the branch, commit range, `tasks/<slug>.md`, and the intent. It writes `reports/<slug>-review.md` with a verdict and findings as `path:line - issue - how to reproduce`, and edits nothing.
4. **Pull request** (after the task or set of tasks is accepted): the brain never merges. A worker pushes a branch and opens a PR into the base branch; the user reviews and merges it.
   - **One accepted task:** its owner pushes `orca/<run_id>/<slug>` and opens the PR.
   - **Several accepted tasks that belong together:** an integration worker creates `orca/<run_id>/integration` from the latest base branch, merges the accepted branches into it in dependency order, runs the full test suite, then pushes and opens one PR. It resolves conflicts within the owned intent and lists them under Decisions made; a conflict that changes behavior goes back to the brain as an `ask`.
   - The PR body links the tasks and summarizes Evidence and review results. The worker records the URL in its report; the brain runs `task-set --pr <url>`, then confirms the PR's base is the base branch and that `git diff --stat <base>...<pr branch>` shows only owned paths.
   - No remote, no push access, or no `gh`: stop and ask the user. Do not fall back to a local merge.

**Closing the loop.** On rejection: `task-set --status rejected --rework`, then a follow-up to the same owner pointing at the review report. Keep the owner until its task is accepted; if it is gone, start a new worker on the same slug whose spec points at `tasks/<slug>.md`, its report, and the review report. After two rejections on the same issue, change approach, agent, or task boundary; after that, escalate to the user. If the owner disputes a finding, it answers in its report; settle disputes with a second reviewer or the user.

**On acceptance:** `task-set --status accepted --result "<one line>"` (acceptance means ready for a PR, not merged), then `RUNPY archive --run $RUN --slug <s>`, which moves the task's plan and reports into `archive/<slug>/` and archives context no open task uses. Keep a lone task's owner until its PR is open, then release it per Orca's completion accounting. Start dependent tasks only after accepting what they consume; because the base branch does not have that work until the PR merges, a dependent task branches from the accepted branch it consumes, and the chain ships through the integration branch.

## 8. Refine the harness

The harness is everything workers are given besides the code: brief, spec template, notes, skill choices. Refine improves it from evidence while the run continues, one small change at a time (after Continual Harness, arXiv:2605.09998).

- **Triggers:** a task rejected twice, the same mistake by two workers, a worker misreading the brief, a scout rediscovering something already found, and run close.
- **Read the trajectory without loading it.** Dispatch a read-only refine worker with the ledger path, the relevant reports and review reports, and the trigger. It returns one proposed note, at most 400 characters, with the trigger and the target scope. The brain decides whether to apply it.
- **One minimal change per step:** `RUNPY refine-add --run $RUN --trigger "<what happened>" --note "<one instruction>"`. Never rewrite SKILL.md, the brief template, or earlier notes during a run; only append supplementary notes.
- **Scope:** run scope (`harness-notes.md`) by default. Use `--scope project` (`project-notes.md`) only for facts true beyond this run, such as test commands, conventions, or pitfalls. Changes to the skill itself are proposed to the user, never applied by the brain.
- **Close the loop:** after the next relevant task, `RUNPY refine-result --id <id> --result "<helped | no effect | harmful: why>"`. Revert harmful or useless notes with `RUNPY refine-revert --id <id>`. `RUNPY refine-list --run $RUN --active` shows what is in force.

## 9. Keep the brain small over long runs

- `RUNPY show` warns when brief Decisions pass 30 lines: summarize old entries and move them to `archive/decisions.md`.
- **Brain handover.** All state lives in Orca and the run folder, so the brain is replaceable. When your context grows heavy (for example after about 20 deliveries), finish processing the current delivery, append a one-paragraph "Handover" note to `brief.md`, and tell the user. A fresh brain session then: loads this skill, runs `ORCA orchestration run-use --id <run_id> --json`, reads `brief.md` and `RUNPY show`, runs `worker-list --json`, and resumes the `check --wait` loop. Unacknowledged deliveries replay, so nothing is lost.

## 10. Close and report

When every task is accepted, failed, or archived: `RUNPY close --run $RUN` moves the run to `.orca-run/archive/<run_id>/`, lists runs beyond the newest 5 as deletion candidates (delete only with the user's approval), and lists run-scope refine notes not yet promoted. Promote the ones that helped and hold beyond this run with `RUNPY refine-promote --id <id>`.

Report per task: outcome, evidence, agent and verified model, review result, PR link, open issues. List PRs still waiting for the user to merge. Delete `orca/<run_id>/*` branches and worktrees only after their PR is merged or closed, and only with the user's approval. Mention missing skills or model changes that affected delivery. Skill selection for workers is in [references/skill-routing.md](references/skill-routing.md).
