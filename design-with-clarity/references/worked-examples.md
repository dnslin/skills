# From material to work: two full derivations

Both are original hypothetical projects, not cases from the books and not user-test results. They show how to combine lenses; the concrete form changes with content and task.

## A small bookshop's "What to read tonight"

**Material.** The page has three features: "Recommend me a random book", browse all, and save. Regulars want to occasionally discover unfamiliar books; the owner wants a feel of paper, annotations, and hand-numbering. Each book has title, author, cover, a one-line staff recommendation, and estimated reading time.

**Claim.** It should feel like receiving a recommendation card from a staff member: drawn in by the one-line pick first, then learning what the book is and whether it is worth reading tonight.

**First understanding.** If the first screen shows only a mysterious pattern and "Begin the journey", visitors must guess the result. Label the entry "Give me a book for tonight" and show a real recommendation card nearby, so the object and content of the random pick are predictable. Browse all still goes straight to the catalog. This uses Krug's understanding lens.

**Composition.** The staff's one-line pick is the reading start; title and author form an identity unit; reading time and save sit near the decision area. One shared starting line connects the pick and the book info. Handwritten annotation carries only the staff voice; steady body text carries book info; a small number repeats across card, catalog, and saved state. Williams's visual means work together to set focus and character.

**Interaction.** On pressing recommend, a card is drawn from a visible stack, with cover and pick appearing together. On save, a bookmark settles on the same card; browse all adds no reveal delay. This borrows Honkish's way of growing experience from existing actions: discovery can have build-up, directed search stays direct. Sound is not required for the design to work.

**Instruction to the implementation agent.**

> Using existing data, build one recommendation card and the recommend and save actions. Let the pick lead; title and author form a tight identity group; reading time sits near save. Keep the paper color and hand-numbering; echo the number in catalog entries. Recommend triggers a card reveal; save feedback happens on the current card. Try this area first with the longest title, a two-line pick, and repeated book switching, then extend to the remaining entries.

This uses ZaynHao's exemplar and concrete-revision approach. "Bookshop style, add motion" cannot convey the same decisions.

**How the judgment changes.** If the main users become staff looking up known titles daily, the first screen should shift to search and list, with the card demoted to an exploration entry. The brand can carry over; visual lead and rhythm must be reallocated.

**Verification.** When rendered, check the order of pick, title, and action. When operating, check that switching books still acts on the current card and that save actually takes effect. Only giving a stranger the task "find a book for tonight and keep it for later" can observe their understanding; designer self-checks are not that observation.

## One talk, two valid directions

**Material.** "City Night Walk: capturing street light with your phone", photographer Lin Lan, Saturday 19:00, 90 minutes, livestream, free. Goals: attract the photographer's existing followers, or attract beginner photographers who don't know her.

**Direction A: spend a night with this photographer.** Portrait and name form the entry; the topic is what she will bring. Time, format, and registration form a stable info group. Her work's cropping style can become the series trait.

**Direction B: shoot the night clearly and with mood.** A night scene and the problem to solve grab the eye first; the photographer's name and credentials then build credibility. Time and registration stay easy to locate. Heading/body differences support a topic-led page without letting the portrait take focus back.

The two versions change the visual promise and content grouping; swapping colors alone cannot deliver either direction. If users must compare several speakers, focus should shift to the comparison.

**Concrete revision.** First build both first screens from exactly the same material; each picks one lead and lets size, weight, space, and image support it together. Give the implementation agent the chosen version as the exemplar for later talk pages, stating which relationships carry over and which follow content.

**Verification.** Zoomed out, can each version's lead be recognized? At actual size, can time, duration, and registration be found? Both must hold for the direction to be delivered. Which direction better attracts the target audience still needs that audience's feedback.
