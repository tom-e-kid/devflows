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

SESSION_DIR=".devflows/sessions/$BRANCH"

echo "<session-status>"
echo "BRANCH: $BRANCH"

if [[ -d "$SESSION_DIR" ]]; then
    echo "STATUS: SESSION_EXISTS"
    echo ""
    echo "Existing session detected. Run /continue to resume work."
else
    echo "STATUS: NO_SESSION"
    echo ""
    echo "No active session. Run /design to start planning a new feature."
fi

echo "</session-status>"
