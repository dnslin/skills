# Issue Body Templates

## Standard Issue Template

```markdown
## Background
[Task origin and motivation]

## Acceptance Criteria
- [ ] [Specific completion condition 1]
- [ ] [Specific completion condition 2]
- [ ] [Specific completion condition 3]

## Technical Implementation
[Implementation approach and steps]
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Core Logic
[Key business logic explanation]

## UI/UX Requirements
[Interface and interaction specs, if applicable. Delete if not needed]
- Layout:
- Interaction:
- Responsive:

## Testing Requirements
- [ ] Unit tests: [scope]
- [ ] Integration tests: [scope]
- [ ] Edge cases: [boundaries to cover]

## Dependencies
- Blocked by: [none / #xxx]
- Blocks: [none / #xxx]
- Related: [none / #xxx]
```

## Epic Template

```markdown
## Background
[Overall Epic background and goals]

## Objectives
[Core objectives of this Epic]

## Scope
**Included:**
- [Feature 1]
- [Feature 2]

**Excluded:**
- [Explicitly excluded items]

## Acceptance Criteria
- [ ] [Epic-level completion condition 1]
- [ ] [Epic-level completion condition 2]

## Sub-Issues

```[tasklist]
### Tasks
- [ ] #xxx [Sub-Issue 1 title]
- [ ] #xxx [Sub-Issue 2 title]
- [ ] #xxx [Sub-Issue 3 title]
```

## Dependencies
- Blocked by: [none / #xxx]
- Blocks: [none / #xxx]

## Technical Decisions
[Epic-level technical decisions and constraints]
```

## Sub-Issue Template

```markdown
## Background
[Task origin, related Epic]

**Parent Epic**: #xxx [Epic title]

## Acceptance Criteria
- [ ] [Specific completion condition 1]
- [ ] [Specific completion condition 2]

## Technical Implementation
[Implementation approach]

## Core Logic
[Key logic explanation]

## Testing Requirements
- [ ] [Test item 1]
- [ ] [Test item 2]

## Dependencies
- Epic: #xxx
- Blocked by: [none / #xxx]
- Blocks: [none / #xxx]
```

## Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| Background | ✅ | Task origin and motivation |
| Acceptance Criteria | ✅ | Checkable completion conditions |
| Technical Implementation | ✅ | Specific implementation steps |
| Core Logic | Conditional | Required for complex logic |
| UI/UX Requirements | Conditional | Required for UI tasks |
| Testing Requirements | ✅ | Test strategy and scope |
| Dependencies | ✅ | Relations with other Issues |
