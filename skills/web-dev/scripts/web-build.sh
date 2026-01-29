#!/bin/bash
# web-build.sh - Run build and extract warnings/errors
# Usage: web-build.sh [--save-baseline <path>]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Parse arguments
SAVE_BASELINE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --save-baseline)
            SAVE_BASELINE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Load config
CONFIG_FILE=".devflows/build/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found. Run /web-dev first." >&2
    exit 1
fi

source "$CONFIG_FILE"

# Move to project root if specified
if [ -n "$PROJECT_ROOT" ] && [ "$PROJECT_ROOT" != "." ]; then
    cd "$PROJECT_ROOT"
fi

echo "=== Running Build ==="
echo "Command: $BUILD_CMD"
echo ""

# Create temp file for output
BUILD_OUTPUT=$(mktemp)
trap "rm -f $BUILD_OUTPUT" EXIT

# Run build and capture output
set +e
eval "$BUILD_CMD" 2>&1 | tee "$BUILD_OUTPUT"
BUILD_EXIT_CODE=${PIPESTATUS[0]}
set -e

echo ""
echo "=== Build Result ==="
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "Status: SUCCESS"
else
    echo "Status: FAILED (exit code: $BUILD_EXIT_CODE)"
fi

# Extract warnings
echo ""
echo "=== Warnings ==="
if [ -n "$WARNINGS_FILTER" ]; then
    WARNINGS=$(cat "$BUILD_OUTPUT" | eval "$WARNINGS_FILTER" || true)
    if [ -n "$WARNINGS" ]; then
        echo "$WARNINGS"
        WARNING_COUNT=$(echo "$WARNINGS" | wc -l | tr -d ' ')
        echo ""
        echo "Warning count: $WARNING_COUNT"
    else
        echo "No warnings found."
        WARNING_COUNT=0
    fi
else
    echo "No warning filter configured."
    WARNING_COUNT=0
fi

# Save baseline if requested
if [ -n "$SAVE_BASELINE" ]; then
    mkdir -p "$(dirname "$SAVE_BASELINE")"
    {
        echo "# Build Baseline"
        echo "# Generated: $(date)"
        echo "# Build command: $BUILD_CMD"
        echo ""
        echo "## Summary"
        echo "Exit code: $BUILD_EXIT_CODE"
        echo "Warning count: $WARNING_COUNT"
        echo ""
        echo "## Warnings"
        if [ -n "$WARNINGS" ]; then
            echo "$WARNINGS"
        else
            echo "(none)"
        fi
    } > "$SAVE_BASELINE"
    echo ""
    echo "Baseline saved to: $SAVE_BASELINE"
fi

exit $BUILD_EXIT_CODE
