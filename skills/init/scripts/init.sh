#!/bin/bash
# Initialize .devflows directory with templates and build config scaffold
# Usage: init.sh <GIT_ROOT> <PLUGIN_ROOT>
set -euo pipefail

GIT_ROOT="${1:?Usage: init.sh <GIT_ROOT> <PLUGIN_ROOT>}"
PLUGIN_ROOT="${2:?Usage: init.sh <GIT_ROOT> <PLUGIN_ROOT>}"

DEVFLOWS_DIR="$GIT_ROOT/.devflows"
TEMPLATES_DIR="$DEVFLOWS_DIR/templates"
DEFAULTS_DIR="$PLUGIN_ROOT/skills/init/defaults"

# Create directories
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$DEVFLOWS_DIR/build"
mkdir -p "$DEVFLOWS_DIR/sessions"

CREATED=()
SKIPPED=()

# Copy default templates (skip if already exists)
for file in pr.md issue.md; do
  if [ ! -f "$TEMPLATES_DIR/$file" ]; then
    cp "$DEFAULTS_DIR/$file" "$TEMPLATES_DIR/$file"
    CREATED+=("templates/$file")
  else
    SKIPPED+=("templates/$file (already exists)")
  fi
done

# Report
echo "=== devflows init ==="
echo "Directory: $DEVFLOWS_DIR"
echo ""

if [ ${#CREATED[@]} -gt 0 ]; then
  echo "Created:"
  for item in "${CREATED[@]}"; do
    echo "  + $item"
  done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "Skipped:"
  for item in "${SKIPPED[@]}"; do
    echo "  - $item"
  done
fi

echo ""
echo "Directories ready:"
echo "  .devflows/templates/"
echo "  .devflows/build/"
echo "  .devflows/sessions/"
