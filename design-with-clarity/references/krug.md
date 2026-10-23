# Krug: from first understanding to next action

Based on the main text of *Don't Make Me Think, Revisited*, 3rd edition. The scenarios and instructions below are original applications; chapters and reading evidence are in [sources](sources.md#krug).

## Predict what people will take it for

People scan with their own task in mind, try the first reasonable entry they meet, and stick with whatever worked. Designers know how the system works; users only see the cues in front of them. The first interpretation they form shapes everything they read after.

When designing a homepage, set aside your product knowledge and look only at the page name, the most prominent content, and the primary action: what do they promise together? Does the landing page keep that promise? When reviewing entry points, also look for **the wrong entry that looks most like the right answer**.

Example: a library homepage centered on "Post an idea" and an editor may be read as a creation platform. If the goal is discovering existing material, show real material and its uses first. Adding "you can also browse here" usually helps less than changing the priority between entry and content.

## Put choices where people have grounds to choose

A choice is hard because of uncertainty. Order steps so people gain the basis for each decision as they go; for repeated tasks, also count round trips and waiting.

Example: an export page that first asks "Standard / Advanced mode" makes users guess an internal category. Show what they will get instead: the finished output as seen, or editable data. Then reveal the matching options. If an operator does the same export daily, proceed with the existing choice.

What should change is how the question is phrased and when it appears. Splitting one hard question into more pages may only postpone the confusion.

## Let every step show where you are

Navigation explains the product's structure, the current location, and where you can go. Trace the same thing across entry, page name, object, and action result; someone arriving at a detail page from outside should still recognize what it is and where it belongs.

Example: entering "Download" from an album, the key is distinguishing a single photo, the selection, and the whole album. Putting the object and count next to the action is more reliable than asking users to remember the previous page's selection. If the page name differs from the entry label, check whether the same object now looks like a different thing.

## Put help where the question arises

Copy does the work of identifying, distinguishing, prompting action, or recovering. Make structure and naming understandable first, then add the explanation needed at that moment. Welcome text restating the page's purpose can give way to content; conditions that change a decision belong next to that decision.

If an action named "Merge" actually only appends, it should say it appends and how duplicates are handled. Simplifying copy is about removing guesswork, not shrinking a key distinction into a shorter, vaguer word.

## Novel forms must be learnable and recognizable

Conventions let people reuse what they know; new forms can enable better exploration or expression. When comparing options, look at how a first-time user starts, how actions are discovered, and whether it is still usable after time away.

Example: a relationship map suits discovering unknown connections; looking up a known name needs a stable entry. Giving each task a fitting path guides implementation better than declaring "maps beat lists".

## Let real tasks settle disagreements

Turn "the button isn't obvious enough" into an observable task: "Stop sharing this file publicly but keep the file." Watch where people start, how they read the result, and when they notice they went wrong. If people only succeed after the designer explains, the interface is not yet doing the explaining.

Fix problems that cause outright task failure or wrong understanding first. Minor detours that recover quickly are worth fixing depending on frequency. Record observed behavior separately from your guesses, then test the revision with the same task.
