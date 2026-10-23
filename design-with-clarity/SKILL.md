---
name: design-with-clarity
description: Use for UI and interaction design - new pages or components, redesigns and visual polish ("make it look more premium / clearer"), layout, typography and visual hierarchy, motion and interaction feedback, design reviews, and writing actionable UI change prompts for design or coding agents. Also for Chinese requests such as 改稿、排版、层级、更高级、交互反馈、设计评审. Not for front-end bugs, performance, or refactors that leave visuals and interaction unchanged.
---

# Design with Clarity

Help people see what matters at a glance, know how to act, and feel the product's character while using it.

Four lenses, each for a kind of decision: Krug explains how people understand and try things; Williams explains how a composition is organized and what it expresses; ZaynHao shows how to hand concrete judgments to an AI and iterate; Honkish shows how coherent interaction grows from one intended experience. Pick the lens the current decision needs and let it change the solution. Do not apply them as a checklist.

## Process

### 1. State the design claim

Read the real content, interface, and product behavior. Write one sentence: **what this person is trying to do right now, what should catch their eye first, and what the experience should feel like.**

- Existing brand traits and features the user explicitly likes are design material; keep them by default.
- New designs also start from content. If the user gave none, ask for it; if you must proceed, use realistic content clearly labeled as sample (real-length titles, multi-line descriptions, real counts). No Lorem ipsum.
- Example: for a photo exhibition page aimed at first-time visitors, let the work spark interest first, then make dates, venue, and booking easy to find. For the entry page of a ticket holder, the ticket and entrance location are the focus. Both can share a brand while their layouts center on different things.

### 2. Read only the references this decision needs

| Decision being made | Read |
| --- | --- |
| How a homepage explains the product, how entries are named, how choices and multi-page flows are ordered | [Krug: understanding and action](references/krug.md) |
| Where the eye starts, grouping, type pairing, heading hierarchy, building a distinct yet unified look | [Williams: visual organization](references/williams.md) |
| Concrete revisions to an existing design, instructions for coding agents, iterating icons and timing details | [ZaynHao: concrete revisions and exemplars](references/zaynhao.md) |
| Giving actions personality, making people feel a response, exploratory and expressive moments | [Honkish: experience and interaction](references/honkish.md) |

Read only matching rows. For a local issue, one reference is enough. For overall visual design, start with Williams; for first-time understanding, start with Krug. Add Honkish when the user asks for strong personality or playful interaction; add ZaynHao when the work will be handed to another agent.

### 3. Find the relationship to change

Name the one relationship that decides success: what an entry promises vs. what the landing page delivers, a heading vs. its supporting info, members of a series vs. distinct roles, a gesture vs. its response.

- **Visual:** settle the focal point and reading path first, then use proximity, alignment, repetition, and contrast together so they all support the same hierarchy.
- **Interaction:** write the before, during, and after states of one action; decide what responds instantly and which moments deserve a pause.
- **Explain trade-offs by task:** professionals comparing data repeatedly need stable columns and a compact view; an exploratory page can make discovery itself the experience. Continuous data entry should move fast; drawing a "today's reading card" can have a brief reveal; a novel entry point still needs a recognizable cue on first use.
- **Delight and personality:** when the user asks for them, treat them as a goal. State which action carries them and which high-frequency path they must not slow down. Bold type, whitespace, or motion must have a clear answer to "whose attention does this serve?"

Do not cover every scenario with one fixed style. When the lenses conflict, decide by the claim from step 1.

### 4. Build a representative piece, then extend

- **Design or implementation:** build one representative area with real text and states, including the longest title, multi-line descriptions, and the empty, error, or loading states relevant to the task. Once the relationships hold, say how the rest of the interface reuses them.
- **Review or prompt writing:** do not build anything. Write the relationship change as located, actionable edits (format below).

### 5. Verify and deliver

Run the checks that fit the task:

- **Composition:** zoomed out, you can name the focal point in one sentence; at actual size, the primary action and required info are easy to find. Both must pass.
- **Revisions:** compare before and after with the same content and the same state.
- **Interaction:** actually operate trigger, change, and result, including repeated actions and undo.
- **Understanding by newcomers:** can only be observed by giving real users a concrete task. If that was not done, say so; designer self-checks and automated runs are not a substitute.

When delivering, state the trade-offs that actually shaped the result and what was and was not verified. Done means the deliverable embodies the claim from step 1 and the step 5 checks have results.

## Output formats

**Design or implementation**

1. Claim: one sentence.
2. Composition: focal point, groups, reading order.
3. Key interaction: trigger → change → result.
4. The design or code.
5. Verification: which checks ran, which did not.

**Review or revision:** one line per issue. List issues that cause task failure or misunderstanding first, minor ones after.

> Location · current relationship · change to · how to verify
>
> Example: Settings "Save" button · arrow icon's bounding box is centered but its visible weight sits left · align by visible outline, not the box · compare against adjacent text in a screenshot at actual size

**Prompts for other agents:** state the object, the change, constraints (what to keep, what not to add), and observation conditions (which content or actions to test with). "Make it more premium" or "add animation" makes the model guess a style again. See the [ZaynHao reference](references/zaynhao.md#describe-the-relationship-to-change) for patterns and examples.

## Further reading

- How the four lenses jointly change one solution: [worked examples](references/worked-examples.md).
- Authors' views, editions, and what was actually read: [sources](references/sources.md). Day-to-day use does not require revisiting the books.
