---
name: feature-setup
description: Set up feature branch and documentation after plan approval. Creates branch, saves plan to .devflows/sessions/, runs initial build.
---

# feature-setup

Set up feature branch and documentation after plan mode is complete.

## Prerequisites

- Plan mode has been completed
- User has approved the plan via ExitPlanMode
- Base branch is known (from discussion or user input)

## Procedure

### 1. Determine Base Branch

Detect the project's branching strategy and determine the base branch:

**Step 1: Check current branch**
```bash
git branch --show-current
```

**Step 2: Determine branching strategy**

| Indicator | Strategy |
|-----------|----------|
| `develop` branch exists | Git flow |
| Only `main`/`master` exists | GitHub flow |
| Unclear | Ask user |

**Step 3: Select base branch**

| Strategy | Current Branch | Base Branch |
|----------|----------------|-------------|
| Git flow | `develop` or `develop_*` | Current branch (e.g., `develop`, `develop_xxx`) |
| Git flow | Other | Ask user |
| GitHub flow | Any | `main` |
| Unknown | Any | Ask user |

**If asking user**, use AskUserQuestion:
```
Which branch should be the base for this feature?
- develop
- main
- Other (specify)
```

### 2. Propose Branch Name

Based on the plan discussion, propose a branch name:

```
Proposed branch: feature/<descriptive-name>
Base branch: <base_branch>

Proceed?
```

Wait for user confirmation. Adjust if needed.

### 3. Create Branch

```bash
git fetch origin
git checkout -b <feature_branch> origin/<base_branch>
```

### 4. Create Feature Documentation

Create `.devflows/sessions/<branch_name>/` directory with:

**requirements.md**
```markdown
# Requirements

## Goal
<summarized goal from plan discussion>

## Base Branch
<base_branch>

## Plan
<copy the full plan content here>

## Created
<date>
```

**notes.md**
```markdown
# Notes

## Key Decisions
<important decisions made during brainstorming>

## Context
<relevant context from the discussion>

## References
<relevant files, links, etc.>
```

**plan.md**
```markdown
# Plan

## Baseline Warnings
<to be filled after build>

## Steps

| # | Description | Status |
|---|-------------|--------|
| 1 | ... | pending |
| 2 | ... | pending |

## Progress Log
- <date>: Feature setup complete
```

### 5. Build Configuration Check

Detect project type and run the appropriate platform skill:

| Project Indicator | Platform Skill |
|-------------------|----------------|
| `*.xcworkspace` or `*.xcodeproj` | `/devflows:ios-dev` |
| `build.gradle` or `build.gradle.kts` | `/devflows:android-dev` |
| `package.json` | `/devflows:web-dev` |

### 6. Initial Build & Baseline (Clean Build)

Run a clean build to establish the baseline. Use the appropriate script based on platform:

**iOS**:
```bash
.claude/skills/ios-dev/scripts/ios-build.sh latest --save-baseline .devflows/sessions/<branch_name>/build_baseline.log
```

**Web**:
```bash
.claude/skills/web-dev/scripts/web-build.sh --save-baseline .devflows/sessions/<branch_name>/build_baseline.log
```

Update `plan.md` with baseline status.

### 7. Proceed to Implementation

**If all steps succeeded (no errors):**
- Display brief status and proceed directly to `/devflows:implementation-loop`
- Do NOT ask user for confirmation

```
✓ Branch: <branch_name>
✓ Docs: .devflows/sessions/<branch_name>/
✓ Build: OK (warnings: <count>)

Starting implementation...
```

Then immediately run `/devflows:implementation-loop`.

**If any step failed (build error, git error, etc.):**
- Stop and report the issue to user
- Discuss how to proceed before continuing

---

## Notes

- This skill runs AFTER plan mode, not before
- The brainstorming/planning phase happens in standard CC plan mode
- Documentation should follow project language conventions (check CLAUDE.md)
- Extract key decisions from plan discussion for notes.md
- Always copy the full plan content into requirements.md (do not reference external files)
