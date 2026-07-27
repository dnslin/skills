---
name: fast-grill-with-docs
description: Resolve high-impact project decisions in dependency-aware batches while maintaining the domain glossary and architectural decisions.
disable-model-invocation: true
---

Run a `/fast-batch-grill` session using the `/domain-modeling` skill.

Before the first round:

1. Read the relevant `CONTEXT.md` or `CONTEXT-MAP.md`.
2. Read applicable ADRs.
3. Explore relevant code where the user's claims can be verified.

During every round:

- Use `/fast-batch-grill` to select and prioritise questions.
- Challenge terminology that conflicts with the existing glossary.
- Sharpen vague or overloaded terms before depending on them.
- Check important claims against the codebase.
- Update `CONTEXT.md` immediately when a domain term is settled.
- Offer an ADR only when the decision is hard to reverse,
  surprising without context, and the result of a real trade-off.

Do not defer domain-model updates until the completion summary.

Fall back to one-at-a-time `/grilling` when:

- one answer substantially changes every following question,
- terminology remains highly ambiguous,
- the user gives contradictory answers,
- or the decision is difficult to reverse.
