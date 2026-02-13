# devflows

A Claude Code plugin for structured feature development workflows.

## Overview

devflows provides:

- **Global Rules** - Cross-project common rules (auto-injected via SessionStart hook)
- **Skills** - Structured feature development workflow

### Philosophy

devflows ensures quality and traceability in feature development:

1. **Start with a session** - Use `/devflows:start` to create a trackable session
2. **Track progress** - Session files record state; resume anytime
3. **Review every step** - Each implementation step includes review & refactor
4. **Build accountability** - Compare before/after builds; fix regressions
5. **Format consistently** - Platform-specific formatting before commit
6. **Structured PRs** - Follow project PR format conventions

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
├── commands/                 # User-invocable commands
│   ├── init.md
│   ├── start.md
│   ├── memo.md
│   ├── loop.md
│   ├── issue.md
│   ├── issues.md
│   ├── resume.md
│   ├── status.md
│   └── pr.md
└── skills/
    ├── init/SKILL.md         # Initialize .devflows in a project
    ├── memo/SKILL.md         # Save context to session files
    ├── loop/SKILL.md         # Smart implementation entry point
    ├── issue/SKILL.md        # Create GitHub Issue
    ├── issues/SKILL.md       # List and manage GitHub Issues
    ├── resume/SKILL.md       # Resume work
    ├── status/SKILL.md       # Check progress
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

devflows integrates with Claude Code's standard plan mode.

```
┌─────────────────────────────────────────────────────────────────┐
│                    /devflows:start                                │
│  Create branch → Session directory → Baseline build              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Think, plan, discuss...                              │
│  Enter plan mode → Discuss requirements → Approve plan           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    /devflows:memo                                 │
│  Save context → Goals, decisions, tasks to session files         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    /devflows:loop                                 │
│  Pick up tasks → Implementation Loop → Review → Commit           │
└─────────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┴─────────────────┐
            │                                   │
            ▼                                   ▼
    ┌───────────────┐                  ┌───────────────┐
    │/devflows:resume│                 │ /devflows:pr  │
    │  Resume work  │                  │  Create PR    │
    └───────────────┘                  └───────────────┘
```

## Commands

All commands are invoked as `/devflows:<command>`.

### Setup

| Command | Purpose |
|---------|---------|
| `/devflows:init` | Initialize `.devflows/` directory with templates and build config for your project |
| `/devflows:start` | Start a new feature session — creates branch, session directory, and runs baseline build |

### Development

| Command | Purpose |
|---------|---------|
| `/devflows:memo` | Save conversation context (goals, decisions, tasks) to session files. Safe to run multiple times |
| `/devflows:loop` | Start implementing — detects session state and picks up from the current task |
| `/devflows:status` | Show current implementation progress (tasks completed/remaining) |
| `/devflows:review` | Run code review on current changes |

### Session Management

| Command | Purpose |
|---------|---------|
| `/devflows:resume` | Resume an existing session — auto-detects current branch or lets you pick from a list |
| `/devflows:pr` | Complete a feature — creates PR (or merges locally if no remote) |
| `/devflows:cleanup` | Clean up after merge — removes session files and local branch |

### GitHub Issues

| Command | Purpose |
|---------|---------|
| `/devflows:issue` | Create a GitHub Issue from the current discussion |
| `/devflows:issues` | List and manage GitHub Issues |

### Internal Skills

These skills are used internally by the commands above and are not typically invoked directly.

| Skill | Used By |
|-------|---------|
| `feature-start` | `/devflows:start` |
| `feature-continue` | `/devflows:resume` |
| `feature-pr` | `/devflows:pr` |
| `feature-cleanup` | `/devflows:cleanup` |
| `feature-status` | `/devflows:resume` (PR status check) |
| `implementation-loop` | `/devflows:loop` |

### Platform Skills

| Skill | Platform |
|-------|----------|
| `ios-dev` | iOS / Xcode |
| `web-dev` | Web / Next.js |

Platform skills are auto-detected and called by `/devflows:start` during session setup.

## Customization

### Templates

Run `/devflows:init` in your project to scaffold the `.devflows/` directory with default templates:

```
$GIT_ROOT/.devflows/
├── templates/              # Committed to repo
│   ├── pr.md               # PR body format
│   └── issue.md            # Issue body format (per-type sections inside)
├── build/
│   └── config.sh           # Platform build config (gitignored)
└── sessions/<branch>/      # Session state (gitignored)
```

| Template | Purpose |
|----------|---------|
| `templates/pr.md` | Custom PR body format used by `/devflows:pr` |
| `templates/issue.md` | Custom issue body format used by `/devflows:issue` — contains sections per type (idea, bug, refactor, improvement) |

Templates are optional. If not present, built-in defaults are used.

## Feature Documentation

During development, feature state is stored in `.devflows/sessions/<branch>/`:

| File | Purpose |
|------|---------|
| `plan.md` | Goal, base branch, context, approach |
| `tasks.md` | Task list with status + progress log |
| `issues.md` | Review issues (append-only, tracked until PR merge) |
| `build_baseline.log` | Initial warning count |

## How It Works

On session start, the plugin automatically:

1. Injects `global/rules.md` as `<devflows-rules>`
2. Detects current branch and session status
3. Suggests `/devflows:resume` or starting fresh based on context

```
<devflows-rules>
# Global Rules
...
</devflows-rules>

<session-status>
BRANCH: feature/my-feature
STATUS: SESSION_EXISTS

Existing session detected. Run /devflows:resume to resume work.
</session-status>
```

Use `/devflows:start` to create a session, then implement with the implementation-loop skill.

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
- Run `/devflows:resume` or `/devflows:status` - Test skill execution
- Check session start output for `<devflows-rules>` and `<session-status>`

## License

MIT
