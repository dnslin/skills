# ZaynHao: hand design judgment to AI for execution

Based on 16 directly read main posts and some of their images and video frames; see [per-post sources](sources.md#zaynhao). The prompts here are original rewrites showing how to turn design judgment into concrete instructions; they do not reproduce the author's ten original prompts.

## Give the AI one exemplar that works

An approved real implementation carries choices adjectives cannot convey: heading-to-description relationship, icon weight, control density, action placement. First read the exemplar and its relevant states, and extract the relationships that transfer this time. Without an exemplar, build one representative area with real content, then extend to similar areas.

Example:

> Using the existing notification settings as the exemplar, build a complete group of sync settings. Keep the label/helper-text hierarchy, form-row rhythm, and save placement. Sync includes the last result and the next scheduled run; place them near the related setting, and distinguish applied state from unsaved changes. Show this group first, then extend to the rest.

This lets the AI inherit concrete decisions while letting content differences produce layout differences.

## Describe the relationship to change

"Make it more premium" makes the model guess a style again. A more effective next instruction says: **which object, what relationship it shows now, what it should become, and what to look at afterward.**

Example: a changelog page repeats the same thing in title, description, and tag:

> Organize each update as one "object — change — impact" line, with the date as a shared group header. Keep the version and conditions that affect upgrade decisions; give space taken by text restating the page's purpose to actual entries. Test with existing long titles and multiple same-day entries: can the updates that need action still be found quickly?

What changes is the information structure. How many words get cut is a result, not the goal.

## Map visual vocabulary to roles

First separate content, helper text, interaction states, and primary actions, then give each role a stable expression. When hierarchy is weak, coordinate weight, position, and space; when many near-identical styles appear, first check whether they really play different roles.

For small labels above headings, decide by the [eyebrow information test](williams.md#eyebrows-must-add-information) and build hierarchy through heading/body typesetting.

The author's ten prompts contain personal parameters. When transferring, keep the problem each solves: a mature color system reduces arbitrary colors; a limited type scale reduces false hierarchy; lighter dividers keep from competing with content. Use an existing system well first; actual size and display conditions decide final values.

| Specific practice in the source | Judgment needed when applying it |
| --- | --- |
| Radix Colors | Choose scales by purpose; does the existing theme already solve this? |
| 0.5px borders | Do they separate clearly on the target display? The author's reply admits low-DPI screens were not considered |
| Three to four type sizes, 12px | Do content roles and reading conditions allow it? Not a universal cap or passing bar |
| ease-out, 250ms | Does it suit this change's distance, direction, and frequency as a starting point? |
| Fewer separator dots, shadows, radii | Do separation, depth, or brand expression actually serve a purpose? |

These are source examples, not global replacement commands for the skill. Read current official docs when using a specific library.

## Trust visual weight over bounding boxes

Equal bounding boxes do not make a circle, triangle, and arrow look equally heavy. At final display size, check visible area, center of gravity, and adjacent text, then adjust size, outline, or position. For nested shapes, check that inner and outer curves form an even gap.

> Put this set of tool icons back into the real toolbar. Compare the visual weight of the arrow, cursor, and clipboard; first fix outlines that are too heavy and arrow tails that are too long, then correct the baseline against adjacent text. Compare screenshots at the same size and keep each action recognizable.

## Time things by intent

The tooltip case separates passing by from continuous exploration; the keyboard list case keeps spatial cues for the next item and group. They care about how the user is operating, not about one animation value for every control.

> On first hover over the toolbar, wait to judge intent to linger; once a tooltip is showing, hand off quickly between adjacent tools in the same group. After leaving, restore the first-hover wait. Test the rhythm with three runs: passing quickly, inspecting item by item, and returning after leaving.

The 600ms first / 0s continuous values come from the post's description, not video measurement. Before implementing, check how the existing component supports continuous triggering, then choose parameters.

## Let feedback express both the object and the change

The screenshot-pointer case puts the target's identity and the action where attention already is; the cleanup preview puts the expected freed space into the existing capacity display. When transferring, find objects and graphics users already understand and express the change there.

> After selecting cleanup candidates, distinguish current usage from expected freed space in the existing capacity bar; the expected value in the action area matches the same selection. Update in sync when candidates change, and update real capacity only after the operation completes.

The zoom-dial case grows an interaction metaphor from lens adjustment. Similar designs should keep action, value, and result in correspondence; tasks that need precise input still need a path suited to precision.

Finally, go back to concrete differences and keep revising. The author's follow-up explicitly treats the ten prompts as baseline adjustments; exemplars and prompts both need real results to verify them.
