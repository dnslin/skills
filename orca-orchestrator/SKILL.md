---
name: orca-orchestrator
description: >-
  Coordinate and supervise coding agents through Orca across Claude Code, Codex,
  and OMP. Use when the user requests multi-agent orchestration, supervised
  delegation, model-aware task routing, parallel workers, independent review,
  or task-specific skill handoffs with Orca. For an unsupervised one-way
  handoff, follow Orca's ordinary handoff guidance instead.
---

# Orca Orchestrator

Act as Orca **Coordinator**: define goals, select execution settings, delegate, supervise, and accept results. Claude Code, Codex, and OMP can each coordinate or execute; **role, harness, and model are separate choices**.

## 1. Establish role and protocol

1. A valid Orca Task / Dispatch preamble makes this session a **worker**. Follow its execution, question, and reporting protocol; do not create another Run or replace the Coordinator.
2. For ownership transfer without supervision, waiting, or acceptance, use Orca's ordinary handoff guidance.
3. For supervised work, locate the local Orca CLI, read its `orchestration` skill, then run `skills get orchestration` through **that same executable**. Follow the returned version-specific guide and load branch-specific references as directed.
4. Verify runtime availability and session permissions. Report missing capabilities as blockers; other subagents, background scripts, or guessed commands do not establish Orca execution.

**Done:** Role is established and execution matches the installed Orca capabilities.

## 2. Discover and apply skills

Before planning, inspect the harness's accessible skills, repository `AGENTS.md` / `CLAUDE.md`, and existing conventions. Read [references/skill-routing.md](references/skill-routing.md) and select skills by **task triggers**, loading only relevant ones.

- The **session responsible for each phase must read and apply** matching, automatically invocable skills. Naming a skill, loading it only in the Coordinator, or mentioning it in a dispatch does not establish worker application.
- Respect invocation restrictions: `disable-model-invocation: true` requires explicit user invocation. Check other applicable policies through the routing guide.
- Verify that workers can access required skill bodies, references, and tools. Share authorized materials with sources or block the affected task. **Sharing text does not supply browsers, MCP services, or credentials.**
- If an optional skill is unavailable, use an appropriate basic method and report it as unused.

**Done:** Each required skill has a trigger, owner, readable entry point, and availability status; user-required skills are accounted for.

## 3. Scope work and select execution

Establish goals, project state, constraints, and observable acceptance criteria. Use the fewest tasks needed: keep coupled changes together; parallelize only independently verifiable work with clear ownership.

Choose workers from available **(agent harness, model, effort)** combinations:

- Clear scope and runnable acceptance: prefer a proven, lower-cost combination.
- Architectural tradeoffs, complex diagnosis, or demonstrated capability gaps: strengthen execution or narrow the problem.
- Authentication, rate limits, missing tools, or incomplete prompts: fix the actual cause before blaming model capability.

Check supported models and launch options; pass selections per the current Orca guide. **A requested model is not a verified active model**; record unknowns. Respect user model, budget, approval, and harness constraints.

**Done:** Every task has an owner, workspace, goal, acceptance method, and verified execution settings or explicit unknowns.

## 4. Dispatch and supervise

Use the installed Orca supervised-worker workflow. Each dispatch must stand alone and include:

```text
Target:       Files, components, or environment
Change:       Required observable behavior or artifact
Constraints:  Required compatibility, security boundaries, preserved behavior
Ownership:    Writable paths, workspace/branch, boundaries with other tasks
Acceptance:   Checks, expected results, evidence
Skills:       Required/optional skills, accessible entry points, tools
Handoff:      Changes, actual checks, remaining issues, evidence locations
```

Workers may lack Coordinator history and other worktrees' uncommitted files. Provide accessible paths, commits, or summaries; preserve user changes. Start with one implementation worker by default. Give parallel workers separate modification boundaries; nested workers require explicit Coordinator authorization.

Handle questions and `worker_done` through Orca messaging/waits. Before stopping, retrying, abandoning, or releasing, require positive evidence under the version guide. Timeouts, silence, and idle terminals do not prove exit.

**Done:** Orca records support each Dispatch state; artifacts identify their task and worker.

## 5. Accept, repair, and close

Check actual diffs/artifacts, test commands, outputs, and coverage gaps against the task contract. Worker completion is a **report**, not acceptance evidence. Use independent review when warranted by cross-module changes, permission/security boundaries, non-runnable acceptance, or correctness doubts. Keep the review candidate stable.

For a localized in-scope defect, request one targeted repair and verify it. On another failure, replan, split, or strengthen execution. Follow user authorization for scope/architecture changes, dangerous actions, privilege escalation, releases, and merges.

Follow the version guide for acknowledgments, worker retention/reuse/release, and outstanding-task checks. Release is not cancellation; missing messages do not justify duplicate editors.

Report results, actual harnesses and verified models, applied skills, changes/artifacts, checks, and unresolved issues. Report costs or savings only from real data.

**Done:** All in-scope tasks have conclusions and evidence; exceptions remain traceable; Orca resources are handled per protocol.
