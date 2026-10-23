---
name: orca-orchestrator
description: >-
  Supervise coding agents through Orca across Claude Code, Codex, and OMP,
  with automatic task-based model selection and evidence-based acceptance.
  Use for supervised delegation, parallel workers, or independent review
  through Orca. For an unsupervised ownership transfer, use Orca's handoff guide.
---

# Orca Orchestrator

Act as Coordinator: scope work, choose execution settings, delegate, supervise, and accept results. Role, agent harness, and model are separate choices.

## 1. Establish authority and protocol

This workflow carries the user's **standing authorization to select worker harnesses, models, and reasoning effort per task without repeated confirmation**. Explicit user choices, budget limits, and applicable project or host constraints take precedence. Use per-launch settings; preserve global defaults. Model selection does not authorize additional scope, releases, or deployments.

This authorization replaces Orca's default policy of overriding models only when the user names one. Orca's supported capabilities and execution protocol still apply.

- A live Task / Dispatch preamble identifies a worker. Follow that preamble; request assistance from the Coordinator rather than delegating further.
- For supervision, resolve the CLI through the local `orchestration` skill, then read `skills get orchestration` through that executable. Reuse it throughout and load conditional references when directed.
- Use Orca for launch, placement, messaging, lifecycle, recovery, and cleanup. Confirm runtime access; report missing capabilities without substituting another agent system.
- For ownership transfer without supervision, use Orca's handoff guide.

**Done:** Role and runtime are established; the Coordinator owns execution decisions under the user's constraints.

## 2. Scope the smallest complete tasks

Read relevant implementation, project instructions, and existing plans. Define the required result and observable acceptance; reuse sufficient existing material.

Start with one implementation worker for a complete, verifiable change. Add workers for independent work, a distinct design question, or justified independent review. Keep coupled changes together and coordination flat.

Assign modification boundaries before parallel work, including shared interfaces or runtime resources when relevant. For work requiring integration, name its owner, target workspace, and final checks. Follow Orca's placement guidance; a new worker does not imply a new worktree.

**Done:** Each task has an owner, result, acceptance method, and any required integration responsibility.

## 3. Select the execution combination

Discover supported harnesses, models, tools, and launch options on the execution host. Reuse confirmed information until availability or task needs change.

Select in this order: **required access/tools → task capability → verification difficulty → expected total time and cost**.

| Task | Selection preference |
| --- | --- |
| Bounded, routine, easily checked | A reliable fast model with low or normal effort |
| Standard feature with established patterns | A capable general model with normal effort |
| Unclear root cause, architecture tradeoffs, complex interactions | Stronger reasoning; increase effort as needed |
| Independent review | A model able to assess the whole candidate; use a different model when its perspective adds value |

These are decision cues, not fixed roles or a model registry. Include context preparation, coordination, and likely rework in the tradeoff. Do not fragment cohesive work to fit a cheaper model or default every task to maximum effort. Where comparative evidence is missing, use a known suitable combination and state the uncertainty.

Give one sentence explaining each selection. Verify actual settings from Orca's launch evidence; requested settings alone do not prove the active model. Report unknowns and claim savings only from measured data.

If an automatically selected model is unavailable, choose another suitable authorized combination through Orca's recovery protocol. If a user-required model is unavailable, report the blocker rather than silently replacing it.

**Done:** The selected combination can perform the task, its rationale is clear, and effective settings are verified or explicitly unknown.

## 4. Dispatch self-contained work

Select and apply skills using [references/skill-routing.md](references/skill-routing.md). Extend Orca's task contract with the context needed by the receiving session:

```text
Target / Change: Scope and required behavior or artifact
Context:         Relevant files, decisions, input artifacts, accessible locations
Constraints:     Invariants and excluded work
Ownership:       Writable scope, workspace, coordination and integration boundaries
Acceptance:      Checks, expected results, evidence
Skills / Tools:  Required skills, readable entry points, necessary capabilities
Handoff:         Changes, actual checks, remaining issues, artifact locations
```

Write key decisions into the brief and link larger materials. Workers may lack conversation history or other workspaces' uncommitted changes; make required inputs accessible before dispatch. Preserve existing user work.

**Done:** The worker can begin independently with the required context and capabilities.

## 5. Supervise and adjust from evidence

Follow Orca's current coordinator loop for questions, updates, completion, and recovery. Let Orca own lifecycle state; this workflow supplies delivery decisions:

- Missing context or misunderstanding: clarify the brief.
- Tool, authentication, permission, or rate-limit failure: address that cause.
- Localized defect: dispatch a bounded repair and verify it.
- Repeated failure on the same issue without new evidence: change the diagnostic approach, task boundary, or execution combination.
- Evidence invalidates the plan: reassess; ask only for decisions outside existing authorization.

Choose repairs by cause, not a fixed retry count. Respect Orca's retry limits. Change models through a supported new attempt or follow-up after resolving the current attempt; never create competing editors to escape an uncertain state.

## 6. Accept, integrate, and close

**Orca settlement ends an execution attempt; Coordinator acceptance establishes that its result meets the task contract.** Check actual diffs/artifacts and verification evidence. Record the acceptance conclusion in the existing task record or handoff, without a second lifecycle system.

Dispatch work that consumes an upstream result only after accepting the parts it depends on. Task completion or readiness alone is insufficient. Unrelated work may continue. For complex dependency plans, use a verification task when useful rather than adding one to every task.

Use independent review for high-impact changes, cross-module changes, or unresolved correctness doubts. Keep the candidate stable during review and recheck affected behavior after repairs. A settled task's repair is fresh follow-up work; use Orca's failed-attempt retry path only when applicable. Route fixes to the assigned owner; review findings do not expand edit authority.

The integration owner combines accepted results and checks the resulting version. Separate worker checks do not establish integrated behavior.

Follow Orca's protocol for acknowledgment, reuse, retention, release, and outstanding work. Report the result and artifact locations, actual harnesses and verified models, checks and outcomes, applied skills, and unresolved or unverified work. Mention model changes or missing skills when they affect delivery.

**Done:** The final result meets acceptance, or incomplete work and its cause are explicit; Orca's completion and resource obligations are satisfied.
