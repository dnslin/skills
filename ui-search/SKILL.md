---
name: ui-search
description: Search and retrieve UI components from Aceternity UI, Magic UI, UI Layouts, and ReactBits component libraries. Triggers when the user needs frontend UI components, animations, effects, or layout elements. Use /ui-search for manual search or auto-triggers when discussing UI component needs during frontend development. Whenever the user mentions needing a specific UI effect, animation, background, text effect, card layout, or interactive component, this skill should activate to find matching components across all four libraries.
---

# UI Component Search

Search across Aceternity UI, Magic UI, UI Layouts, and ReactBits to find the best matching components for your frontend needs.

## When to Use

This skill triggers in two modes:

**Manual**: User invokes `/ui-search <description>`
- Example: `/ui-search 文字渐入动画`
- Example: `/ui-search particle background effect`

**Auto-trigger**: Activate when the conversation involves:
- Requesting UI components, animations, or visual effects
- Discussing frontend component selection
- Mentioning specific effects: particles, glitch, blur, 3D, parallax, gradient, etc.
- Needing hero sections, backgrounds, text animations, card layouts, buttons, or interactive elements

## Search Workflow

### Step 1: Fetch Component Catalogs

Fetch all four llms.txt files in parallel using WebFetch:

```
https://ui.aceternity.com/llms.txt
https://magicui.design/llms.txt
https://www.ui-layouts.com/llms.txt
https://reactbits.dev/llms.txt
```

For each URL, use the WebFetch tool with a prompt like:
> "Extract all component entries. For each component, return: component name, description, and documentation URL. Format as a structured list."

**Error handling**: If any single fetch fails, proceed with the remaining libraries. Note which library was unavailable in the output.

### Step 2: Match Components

Using the user's search description (in any language):

1. Translate Chinese keywords to English equivalents using the mapping in `references/libraries.md`
2. Match against component names, descriptions, and categories
3. Score relevance based on:
   - Exact name match (highest)
   - Description keyword match
   - Category/tag match
4. Sort by relevance score, deduplicate similar components across libraries

### Step 3: Present Results

Display the top 5-10 matching components in a table:

```markdown
| # | 组件名 | 来源库 | 描述 | 文档链接 |
|---|--------|--------|------|----------|
| 1 | Glitch Text | ReactBits | 文字故障效果动画 | [链接](url) |
| 2 | Text Reveal | Aceternity UI | 文字逐字显现效果 | [链接](url) |
| 3 | Blur Text | ReactBits | 文字模糊/清晰过渡 | [链接](url) |
```

### Step 4: Fetch Component Details

For the top 1-3 most relevant components, automatically fetch their documentation pages using WebFetch:

- Extract: installation command, core code snippet, required dependencies, props/API
- Format the code so it can be directly copied and used

Present each component's details in this structure:

```markdown
### [组件名] — [来源库]

**安装依赖：**
\`\`\`bash
npm install <packages>
\`\`\`

**核心代码：**
\`\`\`tsx
// Component code here
\`\`\`

**Props/API：**
| Prop | Type | Default | Description |
|------|------|---------|-------------|

**额外依赖：** framer-motion, gsap, three.js, etc.
```

### Step 5: Recommendation

End with a brief recommendation in Chinese:
- Which component best fits the user's needs and why
- Any important caveats (bundle size, peer dependencies, browser support)
- Suggest combinations if multiple components could work together

## Important Notes

- Always fetch fresh data from llms.txt — do not rely on cached or memorized component lists
- When presenting code, ensure it's complete and runnable
- If the user's description is vague, show a broader range of results (8-10) across categories
- If the user's description is specific, focus on 3-5 highly relevant matches
- Prioritize components that are well-documented and actively maintained

## References

For library metadata, categories, and keyword mappings, see:
- `references/libraries.md` - Complete library information and search keyword mapping
