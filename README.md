# devflows

Reusable development workflows for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Overview

devflows provides:

- **Global CLAUDE.md** - Cross-project common rules
- **Skills** - Structured feature development workflow

## Repository Structure

```
devflows/
├── global/
│   └── rules.md           # Cross-project common rules
│
└── skills/                # Workflow skills
    ├── spec/              # Start planning
    ├── go/                # Begin implementation
    ├── continue/          # Resume work
    ├── pr/                # Create PR
    ├── ios-dev/           # iOS build configuration
    ├── web-dev/           # Web build configuration
    └── ...
```

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/tom-e-kid/devflows.git ~/devflows
```

### 2. Set up global configuration

```bash
# Create ~/.claude if it doesn't exist
mkdir -p ~/.claude

# Link global rules
ln -s ~/devflows/global/rules.md ~/.claude/CLAUDE.md

# Link skills
ln -s ~/devflows/skills ~/.claude/skills
```

### 3. Project-specific configuration (optional)

For project-specific rules, create `.claude/CLAUDE.md` in your project:

```markdown
# Project Rules

## Project
- Type: iOS / Next.js / etc.
- Main branch: develop

## Build
- Workspace: MyApp.xcworkspace
- Scheme: MyApp
```

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                        /spec                                     │
│  Start planning - discuss requirements, explore codebase         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         /go                                      │
│  Approve plan - create branch, save docs, start implementation   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Implementation Loop                            │
│  Implement → Simplify → Format → Build → Update Progress         │
└─────────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            │                                   │
            ▼                                   ▼
    ┌──────────────┐                   ┌──────────────┐
    │  /continue   │                   │    /pr       │
    │  Resume work │                   │  Create PR   │
    └──────────────┘                   └──────────────┘
```

## Skills Reference

### User Commands

| Skill | Description |
|-------|-------------|
| `/spec` | Start planning a new feature |
| `/go` | Approve plan and begin implementation |
| `/continue` | Resume work on existing feature |
| `/pr` | Create pull request |

### Internal Skills

| Skill | Description |
|-------|-------------|
| `review` | Multi-level code review (step/loop/pr) |
| `feature-setup` | Create branch and documentation |
| `feature-continue` | Resume with context restoration |
| `feature-pr` | Commit, push, and create PR |
| `feature-status` | Check PR status |
| `feature-cleanup` | Clean up after merge |
| `implementation-loop` | Step-by-step implementation cycle |

### Platform Skills

| Skill | Description |
|-------|-------------|
| `ios-dev` | iOS/Xcode build configuration |
| `web-dev` | Web/Next.js build configuration |

Platform skills are automatically called by `feature-setup` based on project detection.

## Feature Documentation

During development, feature state is stored in `.devflows/sessions/<branch>/`:

| File | Purpose |
|------|---------|
| `requirements.md` | Goal and full plan |
| `notes.md` | Key decisions and context |
| `plan.md` | Implementation checklist |
| `build_baseline.log` | Initial warning count |

This directory is created by `/go` and deleted by `/feature-cleanup` after merge.

## Configuration Layers

```
~/.claude/CLAUDE.md          # Global rules (from global/rules.md)
         ↓
.claude/CLAUDE.md            # Project-specific rules
         ↓
.devflows/sessions/<branch>/      # Feature-specific context
```

## License

MIT
