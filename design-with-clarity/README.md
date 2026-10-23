# design-with-clarity

Combines user understanding, visual organization, concrete revision, and interaction experience into one design skill.

- Krug: predict first understanding, find the wrong entry that looks right, place choices where people have grounds to make them.
- Williams: decide the visual promise and focal point; build composition with space, type, and variation.
- ZaynHao: guide AI iteration with real exemplars and concrete prompts.
- Honkish: grow personality and response from actions, relationships, and product character.

[SKILL.md](SKILL.md) is the entry point: a five-step process, references read per design decision, and output formats for design, review, and prompt tasks. Editions and reading scope are in [sources.md](references/sources.md).

## Usage

```text
Use $design-with-clarity to design the recommendation page for this independent bookshop.
Visitors want to discover a book to read tonight, with the warmth of a staff member handing over a card.
Existing features: random pick, browse all, save. Build the actual page and interactions.
```

```text
Use $design-with-clarity to revise this interface and write an executable prompt for a coding agent.
Say which relationship must change, how to express it, and how to observe the result.
```

Full combined examples are in [worked-examples.md](references/worked-examples.md). Maintainers can use the [behavior and trigger cases](evals/cases.json) to check whether the skill actually changes design decisions and triggers when it should; they are not day-to-day design checks. Results are in the [eval record](evals/results-2026-10-23.md).
