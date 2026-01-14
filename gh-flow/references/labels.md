# Label Definitions

## Priority Labels

| Label | Color | Description |
|-------|-------|-------------|
| `P0-Critical` | `#d73a4a` (red) | Blocking issue, immediate action required |
| `P1-High` | `#e99695` (light red) | High priority, must complete in current iteration |
| `P2-Medium` | `#fbca04` (yellow) | Medium priority, planned completion |
| `P3-Low` | `#0e8a16` (green) | Low priority, nice to have |

## Type Labels

| Label | Color | Description |
|-------|-------|-------------|
| `type:epic` | `#5319e7` (purple) | Epic, contains multiple Sub-Issues |
| `type:feature` | `#1d76db` (blue) | New feature |
| `type:enhancement` | `#a2eeef` (cyan) | Enhancement to existing feature |
| `type:bug` | `#d73a4a` (red) | Bug fix |
| `type:docs` | `#0075ca` (dark blue) | Documentation update |
| `type:refactor` | `#fef2c0` (light yellow) | Code refactoring |
| `type:test` | `#bfdadc` (light cyan) | Test related |

## Version Labels

Dynamically created based on PRD version info:
- `version:v1.0`
- `version:v1.1`
- `version:v2.0`

Color: `#c5def5` (light blue)

## Label Creation Commands

```bash
# Priority labels
gh label create "P0-Critical" --color "d73a4a" --description "Blocking issue, immediate action required"
gh label create "P1-High" --color "e99695" --description "High priority, must complete in current iteration"
gh label create "P2-Medium" --color "fbca04" --description "Medium priority, planned completion"
gh label create "P3-Low" --color "0e8a16" --description "Low priority, nice to have"

# Type labels
gh label create "type:epic" --color "5319e7" --description "Epic, contains multiple Sub-Issues"
gh label create "type:feature" --color "1d76db" --description "New feature"
gh label create "type:enhancement" --color "a2eeef" --description "Enhancement to existing feature"
gh label create "type:bug" --color "d73a4a" --description "Bug fix"
gh label create "type:docs" --color "0075ca" --description "Documentation update"
gh label create "type:refactor" --color "fef2c0" --description "Code refactoring"
gh label create "type:test" --color "bfdadc" --description "Test related"

# Version labels (example)
gh label create "version:v1.0" --color "c5def5" --description "Version 1.0"
```

## Label Selection Logic

### Priority
- **P0**: PRD marked as "blocking", "urgent", "Critical"
- **P1**: PRD marked as "high priority", "MVP required", "core feature"
- **P2**: PRD marked as "medium priority", "planned", default priority
- **P3**: PRD marked as "low priority", "nice to have", "future"

### Type
- **epic**: Contains multiple independent sub-features, needs splitting
- **feature**: New functionality
- **enhancement**: Improvement to existing feature
- **bug**: Fix issue
- **docs**: Documentation related
- **refactor**: Code refactoring without behavior change
- **test**: Test related task
