# CLAUDE.md

This file provides guidance to Claude Code when working on the devflows repository.

## About This Repository

devflows is a collection of reusable Claude Code skills and global rules for cross-project development workflows.

## Repository Structure

```
devflows/
├── .claude-plugin/
│   └── plugin.json     # Plugin manifest
├── CLAUDE.md           # This file (rules for devflows itself)
├── README.md           # User documentation
│
├── global/
│   └── rules.md        # Cross-project rules (injected via SessionStart hook)
│
├── hooks/
│   ├── hooks.json      # Hook definitions
│   └── session-start.sh
│
└── skills/             # Workflow skills
    ├── design/
    ├── go/
    ├── continue/
    ├── pr/
    ├── ios-dev/
    ├── web-dev/
    └── ...
```

## Writing Skills

### Skill File Structure

Each skill is a directory containing a SKILL.md file:

```
skill-name/
├── SKILL.md        # Required (uppercase)
└── scripts/        # Optional helper scripts
    └── helper.sh
```

### Skill Frontmatter

```markdown
---
name: skill-name
description: Brief description shown in skill list
---
```

### Skill Content Guidelines

1. **Clear Purpose**: State what the skill does upfront
2. **Prerequisites**: List what's needed before running
3. **Procedure**: Step-by-step instructions
4. **Examples**: Show expected output or behavior
5. **Notes**: Edge cases, warnings, tips

### Script Conventions

- Use `#!/bin/bash` with `set -euo pipefail`
- Include usage comment at the top
- Define clear exit codes
- Use portable commands when possible

## Editing Global Rules

### How It Works

- `global/rules.md` is injected via SessionStart hook when plugin is enabled
- No symlink needed - rules are automatically loaded on session start

### Content Guidelines

- Keep rules generic (no project-specific info)
- Focus on workflow and conventions
- Let skills handle platform-specific logic

## Testing Changes

### Manual Testing

1. Enable the plugin: `claude plugins:add /path/to/devflows`
2. Open a test project
3. Run relevant skills
4. Verify behavior

### Skill Testing Checklist

- [ ] Skill loads without errors
- [ ] Procedure steps are clear
- [ ] Scripts execute correctly
- [ ] Path references resolve correctly

## Git Conventions

- Branch: `feature/<description>` or `fix/<description>`
- Commit messages: English, imperative mood
- Keep changes focused and minimal

## Language

- All documentation: English
- Code comments: English
