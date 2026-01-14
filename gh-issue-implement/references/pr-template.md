# PR Template

## Standard PR Body

```markdown
## Summary
[Brief description of what was implemented]

Closes #{issue_number}

## Changes
- [Change 1]
- [Change 2]
- [Change 3]

## Test Plan
- [ ] [Test item 1]
- [ ] [Test item 2]
```

## PR Title Format

```
[#{issue_number}] {issue_title}
```

Examples:
- `[#123] Add user authentication`
- `[#456] Fix login page styling`

## Linking Keywords

| Keyword | Effect |
|---------|--------|
| `Closes #xxx` | Auto-close Issue when PR merges |
| `Fixes #xxx` | Same as Closes, implies bug fix |
| `Refs #xxx` | Reference only, no auto-close |
