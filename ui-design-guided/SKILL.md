---
name: ui-design-guided
description: "Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, dashboards, React/Next.js components, or HTML/CSS layouts. Also supports UI code review for accessibility/UX compliance when explicitly requested (e.g., 'review my UI', 'check accessibility')."
---

# UI Design Guided

Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

**Output language**: Match the user's language.

## Design Thinking

Before coding, understand the context and commit to a **BOLD** aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work—the key is intentionality, not intensity.

## Frontend Aesthetics Guidelines

Focus on:

- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial, Inter, Roboto, system fonts. Pair a distinctive display font with a refined body font.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, and grain overlays.

## Anti-Patterns (Never Use)

- Overused font families (Inter, Roboto, Arial, system fonts, Space Grotesk)
- Cliched color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

## Implementation

Match implementation complexity to the aesthetic vision:

- **Maximalist designs**: Elaborate code with extensive animations and effects
- **Minimalist designs**: Restraint, precision, careful attention to spacing, typography, and subtle details

Elegance comes from executing the vision well.

---

## Review Mode (Optional)

When the user explicitly requests a review (e.g., "review my UI", "check accessibility", "audit this component"), apply the Web Interface Guidelines below.

**Trigger**: Only when user explicitly asks for review/audit. Do not auto-trigger on normal design requests.

### Review Process

1. Read the specified files
2. Check against the rules below
3. Output findings in `file:line` format, grouped by file
4. Mark passing files with `✓ pass`

### Web Interface Guidelines

#### Accessibility

- Icon-only buttons need `aria-label`
- Form controls need `<label>` or `aria-label`
- Interactive elements need keyboard handlers (`onKeyDown`/`onKeyUp`)
- `<button>` for actions, `<a>`/`<Link>` for navigation (not `<div onClick>`)
- Images need `alt` (or `alt=""` if decorative)
- Decorative icons need `aria-hidden="true"`
- Async updates need `aria-live="polite"`
- Use semantic HTML before ARIA
- Headings hierarchical `<h1>`–`<h6>`; include skip link

#### Focus States

- Interactive elements need visible focus: `focus-visible:ring-*` or equivalent
- Never `outline-none` without focus replacement
- Use `:focus-visible` over `:focus`

#### Forms

- Inputs need `autocomplete` and meaningful `name`
- Use correct `type` (`email`, `tel`, `url`, `number`) and `inputmode`
- Never block paste
- Labels clickable (`htmlFor` or wrapping control)
- Errors inline next to fields; focus first error on submit
- Warn before navigation with unsaved changes

#### Animation

- Honor `prefers-reduced-motion`
- Animate `transform`/`opacity` only (compositor-friendly)
- Never `transition: all`—list properties explicitly
- Animations interruptible

#### Typography

- `…` not `...`
- Curly quotes `"` `"` not straight `"`
- Non-breaking spaces: `10&nbsp;MB`, `⌘&nbsp;K`
- `font-variant-numeric: tabular-nums` for number columns
- `text-wrap: balance` or `text-pretty` on headings

#### Content Handling

- Text containers handle long content: `truncate`, `line-clamp-*`, or `break-words`
- Flex children need `min-w-0` to allow truncation
- Handle empty states

#### Images

- `<img>` needs explicit `width` and `height` (prevents CLS)
- Below-fold: `loading="lazy"`
- Above-fold: `priority` or `fetchpriority="high"`

#### Performance

- Large lists (>50 items): virtualize
- No layout reads in render (`getBoundingClientRect`, `offsetHeight`)
- Prefer uncontrolled inputs
- `<link rel="preconnect">` for CDN domains

#### Navigation & State

- URL reflects state—filters, tabs, pagination in query params
- Links use `<a>`/`<Link>` (Cmd/Ctrl+click support)
- Destructive actions need confirmation or undo

#### Touch & Interaction

- `touch-action: manipulation`
- `overscroll-behavior: contain` in modals/drawers
- `autoFocus` sparingly—desktop only

#### Dark Mode

- `color-scheme: dark` on `<html>` for dark themes
- `<meta name="theme-color">` matches page background

#### Hydration Safety

- Inputs with `value` need `onChange` (or use `defaultValue`)
- Guard date/time rendering against hydration mismatch

### Anti-patterns to Flag

- `user-scalable=no` or `maximum-scale=1`
- `onPaste` with `preventDefault`
- `transition: all`
- `outline-none` without focus-visible replacement
- `<div>` or `<span>` with click handlers (should be `<button>`)
- Images without dimensions
- Large arrays `.map()` without virtualization
- Form inputs without labels
- Icon buttons without `aria-label`
- Hardcoded date/number formats (use `Intl.*`)

### Review Output Format

```text
## src/Button.tsx

src/Button.tsx:42 - icon button missing aria-label
src/Button.tsx:18 - input lacks label
src/Button.tsx:55 - animation missing prefers-reduced-motion

## src/Modal.tsx

src/Modal.tsx:12 - missing overscroll-behavior: contain
src/Modal.tsx:34 - "..." → "…"

## src/Card.tsx

✓ pass
```

State issue + location. Skip explanation unless fix non-obvious. No preamble.
