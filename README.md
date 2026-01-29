# devflows

A Claude Code plugin for structured feature development workflows.

## Overview

devflows provides:

- **Global Rules** - Cross-project common rules (auto-injected via SessionStart hook)
- **Skills** - Structured feature development workflow

## Repository Structure

```
devflows/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── hooks/
│   ├── hooks.json            # Hook definitions
│   └── session-start.sh      # Rules injection + session status
├── global/
│   └── rules.md              # Cross-project rules (auto-injected)
└── skills/
    ├── design/SKILL.md       # Start planning
    ├── go/SKILL.md           # Begin implementation
    ├── continue/SKILL.md     # Resume work
    ├── pr/SKILL.md           # Create PR
    ├── ios-dev/SKILL.md      # iOS build configuration
    ├── web-dev/SKILL.md      # Web build configuration
    └── ...
```

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/tom-e-kid/devflows.git ~/devflows
```

### 2. Install as a plugin

```bash
# Global installation (all projects)
/plugin install ~/devflows --scope user

# Or project-specific installation
/plugin install ~/devflows --scope project
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
│                       /design                                    │
│  Start planning - discuss requirements, explore codebase        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         /go                                     │
│  Approve plan - create branch, save docs, start implementation  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Implementation Loop                           │
│  Implement → Simplify → Format → Build → Update Progress        │
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
| `/design` | Start planning a new feature |
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
| `issues.md` | Review issues (append-only, tracked until PR merge) |
| `build_baseline.log` | Initial warning count |

This directory is created by `/go` and deleted by `/feature-cleanup` after merge.

## How It Works

On session start, the plugin automatically:

1. Injects `global/rules.md` as `<devflows-rules>`
2. Detects current branch and session status
3. Suggests `/continue` or `/design` based on context

```
<devflows-rules>
# Global Rules
...
</devflows-rules>

<session-status>
BRANCH: feature/my-feature
STATUS: SESSION_EXISTS

Existing session detected. Run /continue to resume work.
</session-status>
```

## Development

### Local Testing

Test the plugin without installing:

```bash
claude --plugin-dir ~/devflows
```

### Debugging

```bash
claude --plugin-dir ~/devflows --debug
```

### Applying Changes

No hot reload available. After modifying files:

1. Exit the session (`/exit` or Ctrl+C)
2. Restart with the same command

### Verification

In a session, verify the plugin is loaded:

- `/help` - Check if skills are registered
- Run `/design` or `/continue` - Test skill execution
- Check session start output for `<devflows-rules>` and `<session-status>`

## License

MIT
