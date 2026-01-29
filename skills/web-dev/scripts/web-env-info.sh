#!/bin/bash
# web-env-info.sh - Gather web project environment information
# Usage: web-env-info.sh [project_root]

set -e

PROJECT_ROOT="${1:-.}"

echo "=== Web Project Environment ==="
echo ""

# Check Node.js version
echo "## Node.js"
if command -v node &> /dev/null; then
    echo "Version: $(node --version)"
else
    echo "Version: NOT FOUND"
fi
echo ""

# Detect package manager
echo "## Package Manager"
if [ -f "$PROJECT_ROOT/bun.lockb" ] || [ -f "$PROJECT_ROOT/bun.lock" ]; then
    echo "Detected: bun"
    if command -v bun &> /dev/null; then
        echo "Version: $(bun --version)"
    fi
elif [ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]; then
    echo "Detected: pnpm"
    if command -v pnpm &> /dev/null; then
        echo "Version: $(pnpm --version)"
    fi
elif [ -f "$PROJECT_ROOT/yarn.lock" ]; then
    echo "Detected: yarn"
    if command -v yarn &> /dev/null; then
        echo "Version: $(yarn --version)"
    fi
elif [ -f "$PROJECT_ROOT/package-lock.json" ]; then
    echo "Detected: npm"
    if command -v npm &> /dev/null; then
        echo "Version: $(npm --version)"
    fi
else
    echo "Detected: unknown (defaulting to npm)"
fi
echo ""

# Check for monorepo
echo "## Project Structure"
IS_TURBOREPO=false
if [ -f "$PROJECT_ROOT/turbo.json" ]; then
    IS_TURBOREPO=true
    echo "Monorepo: Turborepo"
    echo "  → Run all commands from repo root (PROJECT_ROOT=\".\")"
    if [ -d "$PROJECT_ROOT/apps" ]; then
        echo "Apps:"
        ls -1 "$PROJECT_ROOT/apps" 2>/dev/null | sed 's/^/  - /'
    fi
    if [ -d "$PROJECT_ROOT/packages" ]; then
        echo "Packages:"
        ls -1 "$PROJECT_ROOT/packages" 2>/dev/null | sed 's/^/  - /'
    fi
elif [ -f "$PROJECT_ROOT/lerna.json" ]; then
    echo "Monorepo: Lerna"
elif [ -f "$PROJECT_ROOT/pnpm-workspace.yaml" ]; then
    echo "Monorepo: pnpm workspace"
else
    echo "Monorepo: No (single package)"
fi
echo ""

# Detect framework (check root and apps/ for monorepos)
echo "## Framework Detection"
detect_framework() {
    local pkg="$1"
    if [ -f "$pkg" ]; then
        if grep -q '"next"' "$pkg" 2>/dev/null; then
            NEXT_VERSION=$(grep -o '"next": *"[^"]*"' "$pkg" | grep -o '[0-9][^"]*' | head -1)
            echo "Next.js $NEXT_VERSION"
            return 0
        elif grep -q '"nuxt"' "$pkg" 2>/dev/null; then
            echo "Nuxt.js"
            return 0
        elif grep -q '"gatsby"' "$pkg" 2>/dev/null; then
            echo "Gatsby"
            return 0
        elif grep -q '"remix"' "$pkg" 2>/dev/null; then
            echo "Remix"
            return 0
        elif grep -q '"astro"' "$pkg" 2>/dev/null; then
            echo "Astro"
            return 0
        elif grep -q '"vite"' "$pkg" 2>/dev/null; then
            echo "Vite"
            return 0
        fi
    fi
    return 1
}

FRAMEWORK_FOUND=false
# Check root package.json first
if detect_framework "$PROJECT_ROOT/package.json"; then
    echo "Framework: $(detect_framework "$PROJECT_ROOT/package.json")"
    FRAMEWORK_FOUND=true
fi

# For monorepos, also check apps/
if [ "$FRAMEWORK_FOUND" = false ] && [ -d "$PROJECT_ROOT/apps" ]; then
    for app_dir in "$PROJECT_ROOT/apps"/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/package.json" ]; then
            DETECTED=$(detect_framework "$app_dir/package.json")
            if [ -n "$DETECTED" ]; then
                APP_NAME=$(basename "$app_dir")
                echo "Framework: $DETECTED (in apps/$APP_NAME)"
                FRAMEWORK_FOUND=true
                break
            fi
        fi
    done
fi

if [ "$FRAMEWORK_FOUND" = false ]; then
    echo "Framework: Unknown"
fi
echo ""

# List available scripts
echo "## Available Scripts"
if [ -f "$PROJECT_ROOT/package.json" ]; then
    # Extract scripts using grep and sed (portable)
    grep -A 100 '"scripts"' "$PROJECT_ROOT/package.json" 2>/dev/null | \
        grep -E '^\s*"[^"]+":' | \
        grep -v '"scripts"' | \
        sed 's/^\s*"\([^"]*\)".*/  - \1/' | \
        head -20
fi
echo ""

# Check for common config files
echo "## Configuration Files"
[ -f "$PROJECT_ROOT/tsconfig.json" ] && echo "  - tsconfig.json (TypeScript)"
[ -f "$PROJECT_ROOT/eslint.config.js" ] || [ -f "$PROJECT_ROOT/eslint.config.mjs" ] || [ -f "$PROJECT_ROOT/.eslintrc.js" ] || [ -f "$PROJECT_ROOT/.eslintrc.json" ] && echo "  - ESLint config"
[ -f "$PROJECT_ROOT/prettier.config.js" ] || [ -f "$PROJECT_ROOT/prettier.config.mjs" ] || [ -f "$PROJECT_ROOT/.prettierrc" ] || [ -f "$PROJECT_ROOT/.prettierrc.json" ] && echo "  - Prettier config"
[ -f "$PROJECT_ROOT/vitest.config.ts" ] || [ -f "$PROJECT_ROOT/vitest.config.js" ] && echo "  - Vitest config"
[ -f "$PROJECT_ROOT/jest.config.js" ] || [ -f "$PROJECT_ROOT/jest.config.ts" ] && echo "  - Jest config"
[ -f "$PROJECT_ROOT/playwright.config.ts" ] && echo "  - Playwright config"
[ -f "$PROJECT_ROOT/tailwind.config.js" ] || [ -f "$PROJECT_ROOT/tailwind.config.ts" ] && echo "  - Tailwind CSS config"
[ -f "$PROJECT_ROOT/drizzle.config.ts" ] && echo "  - Drizzle ORM config"
echo ""

# Recommended config for Turborepo
if [ "$IS_TURBOREPO" = true ]; then
    echo "## Recommended Turborepo Config"
    echo "PROJECT_ROOT=\".\""
    echo "BUILD_CMD=\"bun run build\""
    echo "DEV_CMD=\"bun run dev\""
    echo "LINT_CMD=\"bun run lint\""
    echo "TEST_CMD=\"bun run test\""
    echo "FORMAT_CMD=\"bun run format\""
    echo "FORMAT_CHECK_CMD=\"bun run format:check\""
    echo ""
fi
