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
    echo ""
    echo "Existing session detected. Run /devflows:resume to resume work."
    echo "Or run /devflows:status to check progress."
else
    echo "STATUS: NO_SESSION"
    echo ""
    echo "No active session. Describe what you want to implement to start planning."
    echo "Or run /devflows:ideas to browse saved ideas."
fi

echo "</session-status>"
