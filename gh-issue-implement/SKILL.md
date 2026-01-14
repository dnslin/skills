---
name: gh-issue-implement
description: "GitHub Issue implementation workflow. Read Issue content, execute /dev for development, create PR linked to Issue. Triggers: (1) user requests implementing a GitHub Issue, (2) /gh-issue-implement command, (3) converting Issue to PR. Requires gh CLI."
---

# gh-issue-implement

Implement GitHub Issues end-to-end: read Issue → create branch → execute /dev → create linked PR.

**Output language: Chinese (中文)**

## Workflow

### Step 1: Environment Check

```bash
gh auth status
```

If not authenticated, prompt: `gh auth login`

### Step 2: Read Issue

Parse Issue number from user input (supports `123` or `#123`):

```bash
gh issue view {number} --json number,title,body,labels
```

Extract from Issue body:
- Acceptance Criteria (验收标准)
- Technical Implementation (技术实现)
- Testing Requirements (测试要求)

Display Issue summary and **ask user to confirm** before proceeding.

### Step 3: Create Branch

Branch naming: `issue-{number}`

```bash
git checkout -b issue-{number}
```

If branch exists, ask user:
- Switch to existing branch
- Delete and recreate
- Cancel

### Step 4: Execute Development

Invoke `/dev` skill with Issue content as requirements:

```
/dev

Requirements from Issue #{number}: {issue_title}

{extracted_acceptance_criteria}

{extracted_technical_implementation}

{extracted_testing_requirements}
```

Follow `/dev` workflow (requirement clarification → analysis → dev-plan → parallel execution).

**Ask user to confirm** before starting development.

### Step 5: Create PR

After development completes, **ask user to confirm** PR creation.

```bash
gh pr create --title "[#{number}] {issue_title}" --body "$(cat <<'EOF'
## Summary
[Development summary from /dev output]

Closes #{number}

## Changes
[List of main changes]

## Test Plan
- [ ] [Test items from Issue]
EOF
)"
```

## Error Handling

| Error | Action |
|-------|--------|
| gh not authenticated | Prompt `gh auth login` |
| Issue not found | Report error, ask for correct number |
| Branch conflict | Ask user how to handle |
| /dev failure | Stop and report, preserve branch state |
| PR creation failure | Report error, show manual command |

## Output Format

```
✅ Issue #{number} 实现完成

| 步骤 | 状态 |
|------|------|
| 读取 Issue | ✅ |
| 创建分支 | ✅ issue-{number} |
| 执行开发 | ✅ |
| 创建 PR | ✅ PR #{pr_number} |

PR 链接: {pr_url}
```
