---
name: fast-batch-grill
description: Resolve high-impact decisions in dependency-aware batches, using defaults for low-risk choices.
disable-model-invocation: true
---

# Fast Batch Grill

Interview the user until there is enough shared understanding to proceed
safely to specification, prototyping, or implementation.

Do not attempt to exhaust every possible branch of the decision tree.

## Decision tree

Map the subject as a decision tree.

A decision may only be asked when all decisions it depends on are settled.

The current frontier is the set of unresolved decisions whose prerequisites
are already settled.

## Facts and decisions

Facts that can be discovered from the environment are the agent's
responsibility.

Explore the repository, documentation, configuration, issue tracker, and
available tools instead of asking the user for discoverable facts.

Product choices, trade-offs, preferences, risk tolerance, and user-visible
behaviour are the user's decisions.

## Prioritisation

Score unresolved decisions by:

1. Whether they block implementation
2. User-visible impact
3. Cost of reversing the decision
4. Architectural impact
5. Degree of genuine uncertainty

Ask the highest-impact decisions first.

Do not ask low-impact questions when a safe and conventional default exists.

## Rounds

Work in dependency-aware rounds.

In each round:

1. Recompute the current frontier.
2. Select no more than 8 highest-impact decisions.
3. Number every question.
4. Give a recommended answer first.
5. Provide 2–4 concise options where useful.
6. Allow the user to provide a custom answer.
7. Allow compact responses such as:
   `1A 2推荐 3C 4自定义答案`

A decision whose answer depends on another unresolved decision belongs to a
later round.

## Defaults

Apply the recommended default without asking when all of the following are
true:

- the choice has low user-visible impact,
- it is inexpensive to reverse,
- it does not affect the current implementation seam,
- and a conventional default exists.

Record every adopted default explicitly.

## Composition

This skill owns interview cadence, frontier selection, prioritisation,
defaults, and stopping conditions.

When another skill supplies an active discipline, such as
`/domain-modeling`, keep that discipline active throughout every round.

Do not postpone another skill's required inline actions until the
completion summary.

## Round limit

Use at most 2 rounds by default.

A third round is allowed only when unresolved decisions would directly block:

- the specification,
- a prototype,
- the testing seam,
- implementation,
- or a hard-to-reverse architectural choice.

## Stop condition

Stop when:

- the next phase can begin safely,
- no unresolved decision blocks that phase,
- remaining uncertainty is low-impact or reversible,
- and all adopted assumptions have been recorded.

Do not require the entire decision tree to be exhausted.

## Completion output

Finish with:

### Settled decisions

The decisions explicitly made by the user.

### Defaults and assumptions

Low-risk choices adopted automatically.

### Out of scope

Capabilities or behaviours explicitly excluded.

### Unresolved risks

Important uncertainty that remains but does not block the next phase.

### Documentation status

List:

- domain terms updated during the session,
- ADRs created or proposed,
- documentation work still outstanding.

When no documentation discipline was active, list documentation
candidates instead of claiming that files were updated.

### Recommended next action

Choose exactly one:

- prototype,
- to-spec,
- implement,
- or stop and gather missing facts.

Do not begin implementation until the user confirms the summary.
