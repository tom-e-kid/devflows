#!/bin/bash
# session-start.sh - Inject global rules and notify session state
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Output global rules
if [[ -f "$PLUGIN_ROOT/global/rules.md" ]]; then
    echo "<devflows-rules>"
    cat "$PLUGIN_ROOT/global/rules.md"
    echo "</devflows-rules>"
    echo ""
fi

# Detect git branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if [[ -z "$BRANCH" ]]; then
    exit 0
fi

# Resolve git root for .devflows directory (monorepo support)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SESSION_DIR="$GIT_ROOT/.devflows/sessions/$BRANCH"

echo "<session-status>"
echo "BRANCH: $BRANCH"

if [[ -d "$SESSION_DIR" ]]; then
    echo "STATUS: SESSION_EXISTS"

    # Extract goal from plan.md (fallback to requirements.md for older sessions)
    GOAL=""
    if [[ -f "$SESSION_DIR/plan.md" ]]; then
        GOAL=$(sed -n '/^## Goal/{n; /^$/d; p;}' "$SESSION_DIR/plan.md" | head -3 | sed 's/^[[:space:]]*//' | tr '\n' ' ')
    elif [[ -f "$SESSION_DIR/requirements.md" ]]; then
        GOAL=$(sed -n '/^## Goal/{n; /^$/d; p;}' "$SESSION_DIR/requirements.md" | head -3 | sed 's/^[[:space:]]*//' | tr '\n' ' ')
    fi
    if [[ -n "$GOAL" ]]; then
        echo "GOAL: $GOAL"
    fi

    # Extract progress from tasks.md (fallback to plan.md for older sessions)
    if [[ -f "$SESSION_DIR/tasks.md" ]]; then
        TOTAL=$(grep -cE '^\| [0-9]+' "$SESSION_DIR/tasks.md" 2>/dev/null || echo "0")
        COMPLETED=$(grep -cE '^\| [0-9]+.*completed' "$SESSION_DIR/tasks.md" 2>/dev/null || echo "0")
        echo "PROGRESS: $COMPLETED/$TOTAL tasks"
    elif [[ -f "$SESSION_DIR/plan.md" ]]; then
        TOTAL=$(grep -cE '^\| [0-9]+' "$SESSION_DIR/plan.md" 2>/dev/null || echo "0")
        COMPLETED=$(grep -cE '^\| [0-9]+.*completed' "$SESSION_DIR/plan.md" 2>/dev/null || echo "0")
        echo "PROGRESS: $COMPLETED/$TOTAL tasks"
    fi

    echo ""
    echo "Active session detected for this branch."
    echo "Run /devflows:resume to continue, or /devflows:status for details."
else
    echo "STATUS: NO_SESSION"
    echo ""
    echo "No active session. Run /devflows:start to begin, or /devflows:issues to browse issues."
fi

echo "</session-status>"
