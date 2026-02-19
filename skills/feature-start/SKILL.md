---
name: feature-start
description: Start a new feature session. Creates branch, session directory, and runs baseline build. Works with or without a prior plan.
---

# feature-start

Start a new feature session. Creates a feature branch, initializes session files, and runs a baseline build.

## What This Skill Does

1. Checks for existing session on the current branch
2. Gathers context from the conversation (plan, goal, or asks user)
3. Determines base branch and creates a feature branch
4. Creates `.devflows/sessions/<session_name>/` with session files (branch `/` replaced with `-`)
5. Detects platform and runs baseline build
6. Reports readiness — user decides next step

## Prerequisites

- Current directory is inside a git repository

## Procedure

### 0. Determine Git Root

**IMPORTANT: Always resolve git root first to ensure .devflows is created at the repository root, not in subdirectories (monorepo support).**

```bash
GIT_ROOT=$(git rev-parse --show-toplevel)
```

All `.devflows/` paths below should be prefixed with `$GIT_ROOT/`.

### 1. Check for Existing Session

```bash
CURRENT_BRANCH=$(git branch --show-current)
SESSION_NAME="${CURRENT_BRANCH//\//-}"
```

Check if `$GIT_ROOT/.devflows/sessions/$SESSION_NAME/` exists.

- If **exists** → Report that a session already exists on this branch. Offer:
  - Resume with `/devflows:resume`
  - Abort
- If **not exists** → Continue

### 2. Gather Context

Determine what context is available from the current conversation:

| Context Available | Action |
|-------------------|--------|
| Plan exists (plan mode was used, steps exist) | Capture goal, plan content, and context |
| Goal but no formal plan (user described what they want) | Capture the goal, leave plan empty |
| No context (user ran `/devflows:start` with no prior discussion) | Ask user for a brief description of the feature |

### 3. Determine Base Branch

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

### 4. Propose Branch Name

Based on the conversation context, propose a branch name:

```
Proposed branch: feature/<descriptive-name>
Base branch: <base_branch>

Proceed?
```

Wait for user confirmation. Adjust if needed.

### 5. Create Branch

```bash
git fetch origin
git checkout -b <feature_branch> origin/<base_branch>
```

### 6. Create Session Directory

**IMPORTANT: Sanitize branch name for directory path** — replace all `/` with `-` to avoid nested directories.

```bash
SESSION_NAME="${BRANCH_NAME//\//-}"
```

For example, `feature/dark-mode` becomes `feature-dark-mode`.

Create `$GIT_ROOT/.devflows/sessions/$SESSION_NAME/` directory with:

**`.branch`** (actual branch name for reverse mapping)

```
<actual_branch_name>
```

This file stores the real git branch name (e.g., `feature/dark-mode`) so that other skills can map the session directory back to the correct branch.

**plan.md**

If a plan exists:
```markdown
# Plan

## Goal
<summarized goal from conversation>

## Base Branch
<base_branch>

## Context
<important decisions from discussion, relevant context, references>

## Approach
<full plan content — how we'll tackle it, architecture notes>
```

If no plan:
```markdown
# Plan

## Goal
<summarized goal or brief description from user>

## Base Branch
<base_branch>

## Context
No context yet.

## Approach
No formal plan yet. Use `/devflows:memo` to save context, or start implementing directly.
```

**tasks.md**

If a plan exists:
```markdown
# Tasks

| # | Task | Status |
|---|------|--------|
| 1 | ... | pending |
| 2 | ... | pending |

## Log
- <date>: Session started
```

If no plan:
```markdown
# Tasks

No tasks defined yet. Use `/devflows:memo` to capture tasks from the conversation, or add tasks manually.

## Log
- <date>: Session started (no tasks)
```

### 7. Build Configuration Check

Check if `$GIT_ROOT/.devflows/build/config.sh` exists.

- If **exists** → source it and proceed to baseline build
- If **not exists** → detect project type:

| Project Indicator | Platform Skill |
|-------------------|----------------|
| `*.xcworkspace` or `*.xcodeproj` | ios-dev |
| `package.json` | web-dev |
| None detected | Skip build baseline |

### 8. Initial Build & Baseline

Run a clean build to establish the baseline:

**iOS**:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/ios-dev/scripts/ios-build.sh latest --save-baseline $GIT_ROOT/.devflows/sessions/$SESSION_NAME/build_baseline.log
```

**Web**:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/web-dev/scripts/web-build.sh --save-baseline $GIT_ROOT/.devflows/sessions/$SESSION_NAME/build_baseline.log
```

Update `plan.md` Context section with baseline warning count and `tasks.md` Log with build result.

If no platform detected, skip and note in `plan.md` Context: "No build baseline (no platform detected)".

If build fails, report the error and ask user how to proceed.

### 9. Report Completion

```
## Session Started

- Branch: <branch_name> (from <base_branch>)
- Session: .devflows/sessions/<session_name>/
- Build baseline: <OK (warnings: N) / skipped / failed>
- Tasks: <N tasks defined / no tasks yet>

### Next Steps
- Start implementing → `/devflows:loop` picks up tasks and runs implementation-loop
- Save context first → `/devflows:memo` captures goals, decisions, and tasks from the conversation
- Need a plan first → enter plan mode to design the implementation
- Check status → /devflows:status
```

**IMPORTANT: Do NOT automatically proceed to implementation-loop.** The user decides what to do next.

---

## Notes

- This skill works with or without a prior plan — session files are useful either way
- If user later creates a plan, they can use `/devflows:memo` to update plan.md and tasks.md
- Build baseline can be re-run later via platform skills if skipped initially
- Documentation should follow project language conventions (check CLAUDE.md)
- Always copy the full plan content into plan.md (do not reference external files)
