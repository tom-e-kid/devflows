#!/bin/bash
# web-verify.sh - Run lint, format check, and typecheck
# Usage: web-verify.sh [--save-baseline <path>]

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
CONFIG_FILE="docs/build/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found. Run /web-dev first." >&2
    exit 1
fi

source "$CONFIG_FILE"

# Move to project root if specified
if [ -n "$PROJECT_ROOT" ] && [ "$PROJECT_ROOT" != "." ]; then
    cd "$PROJECT_ROOT"
fi

OVERALL_STATUS=0
RESULTS=""

# Run format check
echo "=== Format Check ==="
if [ -n "$FORMAT_CHECK_CMD" ]; then
    echo "Command: $FORMAT_CHECK_CMD"
    set +e
    FORMAT_OUTPUT=$(eval "$FORMAT_CHECK_CMD" 2>&1)
    FORMAT_EXIT=$?
    set -e

    if [ $FORMAT_EXIT -eq 0 ]; then
        echo "Status: PASS"
        RESULTS="${RESULTS}Format: PASS\n"
    else
        echo "Status: FAIL"
        echo "$FORMAT_OUTPUT"
        RESULTS="${RESULTS}Format: FAIL\n"
        OVERALL_STATUS=1
    fi
else
    echo "No format check command configured."
    RESULTS="${RESULTS}Format: SKIPPED\n"
fi
echo ""

# Run lint
echo "=== Lint ==="
if [ -n "$LINT_CMD" ]; then
    echo "Command: $LINT_CMD"
    set +e
    LINT_OUTPUT=$(eval "$LINT_CMD" 2>&1)
    LINT_EXIT=$?
    set -e

    if [ $LINT_EXIT -eq 0 ]; then
        echo "Status: PASS"
        RESULTS="${RESULTS}Lint: PASS\n"
    else
        echo "Status: FAIL"
        echo "$LINT_OUTPUT"
        RESULTS="${RESULTS}Lint: FAIL\n"
        OVERALL_STATUS=1
    fi
else
    echo "No lint command configured."
    RESULTS="${RESULTS}Lint: SKIPPED\n"
fi
echo ""

# Run typecheck
echo "=== Typecheck ==="
if [ -n "$TYPECHECK_CMD" ]; then
    echo "Command: $TYPECHECK_CMD"
    set +e
    TYPE_OUTPUT=$(eval "$TYPECHECK_CMD" 2>&1)
    TYPE_EXIT=$?
    set -e

    if [ $TYPE_EXIT -eq 0 ]; then
        echo "Status: PASS"
        RESULTS="${RESULTS}Typecheck: PASS\n"
    else
        echo "Status: FAIL"
        echo "$TYPE_OUTPUT"
        RESULTS="${RESULTS}Typecheck: FAIL\n"
        OVERALL_STATUS=1
    fi
else
    echo "No typecheck command configured."
    RESULTS="${RESULTS}Typecheck: SKIPPED\n"
fi
echo ""

# Run tests (optional, only if test command exists)
echo "=== Tests ==="
if [ -n "$TEST_CMD" ]; then
    echo "Command: $TEST_CMD"
    set +e
    TEST_OUTPUT=$(eval "$TEST_CMD" 2>&1)
    TEST_EXIT=$?
    set -e

    if [ $TEST_EXIT -eq 0 ]; then
        echo "Status: PASS"
        RESULTS="${RESULTS}Tests: PASS\n"
    else
        echo "Status: FAIL"
        echo "$TEST_OUTPUT"
        RESULTS="${RESULTS}Tests: FAIL\n"
        OVERALL_STATUS=1
    fi
else
    echo "No test command configured."
    RESULTS="${RESULTS}Tests: SKIPPED\n"
fi
echo ""

# Summary
echo "=== Summary ==="
echo -e "$RESULTS"

if [ $OVERALL_STATUS -eq 0 ]; then
    echo "Overall: ALL CHECKS PASSED"
else
    echo "Overall: SOME CHECKS FAILED"
fi

# Save baseline if requested
if [ -n "$SAVE_BASELINE" ]; then
    mkdir -p "$(dirname "$SAVE_BASELINE")"
    {
        echo "# Verification Baseline"
        echo "# Generated: $(date)"
        echo ""
        echo -e "$RESULTS"
    } > "$SAVE_BASELINE"
    echo ""
    echo "Baseline saved to: $SAVE_BASELINE"
fi

exit $OVERALL_STATUS
