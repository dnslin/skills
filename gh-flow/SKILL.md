---
name: gh-flow
description: "GitHub Issue workflow automation. Auto-create structured Issues from PRD docs with Epic/Sub-Issue splitting, auto-labeling, and GitHub Tasklist linking. Triggers: (1) user requests Issue creation from PRD, (2) /gh-issue-create command, (3) converting requirements to executable tasks. Requires gh CLI."
---

# gh-flow

GitHub Issue workflow automation skill. Currently supports `gh-issue-create`.

**Output language: Chinese (中文)**

## gh-issue-create Workflow

Create structured GitHub Issues from PRD documents:

1. **Read PRD** → Parse PRD file at specified path
2. **Analyze tasks** → AI identifies features, generates task list
3. **Split suggestion** → Suggest Epic/Sub-Issue split for complex tasks
4. **User confirmation** → Show task list and split plan, wait for approval
5. **Create Issues** → Use gh CLI to create Issues, add labels, establish links
6. **Optional Project link** → Ask if adding to GitHub Project

## Execution Steps

### Step 1: Environment Check

```bash
gh auth status
```

If not authenticated, prompt user to run `gh auth login`.

### Step 2: Read and Analyze PRD

Read user-specified PRD file (default `docs/*-prd.md`), analyze to identify:
- Features and tasks
- Dependencies between tasks
- Priority and complexity

### Step 3: Generate Task List

For each identified task, generate:
- Title (concise and clear)
- Issue Body (use template from `references/issue-template.md`)
- Labels (see `references/labels.md`)
- Dependencies

### Step 4: Epic Split Suggestion

For complex tasks (estimated > 3 days or contains multiple independent sub-features):
1. Suggest splitting into Epic + Sub-Issues
2. Show split plan
3. Wait for user confirmation or adjustment

**Split principles:**
- Sub-Issue granularity: completable by one person in 1-3 days
- Each Sub-Issue independently testable
- Clear dependencies

### Step 5: Create Issues

**Creation order:**
1. First create Issues without dependencies
2. Then create Issues with dependencies (can reference created Issue numbers)
3. Finally create Epic (containing Tasklist of all Sub-Issues)

**Create command:**
```bash
gh issue create --title "Title" --body "Content" --label "label1,label2"
```

**Epic Tasklist format:**
````markdown
```[tasklist]
### Sub-Issues
- [ ] #123 Sub-Issue 1 title
- [ ] #124 Sub-Issue 2 title
```
````

### Step 6: Optional Project Link

Ask user if linking to GitHub Project:
```bash
# List available Projects
gh project list

# Add Issue to Project
gh project item-add PROJECT_NUMBER --owner OWNER --url ISSUE_URL
```

## Output Format

After creation, output summary table (in Chinese):

```
✅ 已创建 X 个 Issue

| # | 标题 | 类型 | 优先级 | 依赖 |
|---|------|------|--------|------|
| #1 | xxx | feature | P1 | - |
| #2 | xxx | epic | P0 | - |
| #3 | xxx | feature | P1 | #1 |
```

## References

- **Issue Body template**: See `references/issue-template.md`
- **Label definitions**: See `references/labels.md`
