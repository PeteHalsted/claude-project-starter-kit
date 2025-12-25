#!/bin/bash
set -euo pipefail

# sync-starter-kit.sh - Sync project with starter kit
# Run from any project directory
# Exit codes: 0 = has changes, 1 = error, 2 = no changes needed

CONFIG_FILE="$HOME/.claude/starter-kit-config.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

info() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

header() {
    echo -e "${CYAN}$1${NC}"
}

# Get starter kit path from config
get_kit_path() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "Starter kit not configured. Run /sync-global from starter kit first."
    fi

    local path
    path=$(grep -o '"starterKitPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

    if [[ -z "$path" ]]; then
        error "Invalid config file. Run /sync-global from starter kit to reconfigure."
    fi

    if [[ ! -d "$path" ]]; then
        error "Starter kit path does not exist: $path"
    fi

    echo "$path"
}

# Check if we're in a project directory
check_project() {
    if [[ ! -f "package.json" && ! -d ".git" && ! -f "CLAUDE.md" ]]; then
        error "Not in a project directory. Run from a project root."
    fi
}

# Compare AIRules
compare_airules() {
    local kit_path="$1"
    local kit_airules="$kit_path/airules"
    local project_airules="./AIRules"

    header "=== AIRULES COMPARISON ==="
    echo ""

    if [[ ! -d "$kit_airules" ]]; then
        error "Starter kit missing airules/ folder"
    fi

    local has_changes=0

    # Create AIRules if missing
    if [[ ! -d "$project_airules" ]]; then
        warn "AIRules/ folder missing in project"
        has_changes=1
    fi

    # Compare each kit file
    for kit_file in "$kit_airules"/*.md; do
        [[ -f "$kit_file" ]] || continue

        local filename
        filename=$(basename "$kit_file")

        # Skip projectrules.md - always project-specific
        if [[ "$filename" == "projectrules.md" ]]; then
            echo "SKIP: $filename (project-specific)"
            continue
        fi

        local project_file="$project_airules/$filename"

        if [[ ! -f "$project_file" ]]; then
            warn "NEW: $filename (not in project)"
            has_changes=1
        else
            local kit_hash project_hash
            kit_hash=$(md5 -q "$kit_file")
            project_hash=$(md5 -q "$project_file")

            if [[ "$kit_hash" == "$project_hash" ]]; then
                success "IDENTICAL: $filename"
            else
                warn "DIFFERS: $filename"
                has_changes=1
            fi
        fi
    done

    # Check for project-only files
    if [[ -d "$project_airules" ]]; then
        for project_file in "$project_airules"/*.md; do
            [[ -f "$project_file" ]] || continue

            local filename
            filename=$(basename "$project_file")
            local kit_file="$kit_airules/$filename"

            if [[ ! -f "$kit_file" ]]; then
                info "PROJECT-ONLY: $filename"
            fi
        done
    fi

    echo ""
    return $has_changes
}

# Compare git hooks
compare_hooks() {
    local kit_path="$1"
    local kit_hooks="$kit_path/_git-hooks-project"
    local project_hooks="./.git/hooks"

    header "=== GIT HOOKS ==="
    echo ""

    if [[ ! -d ".git" ]]; then
        warn "No .git directory - skipping hooks"
        echo ""
        return 0
    fi

    if [[ ! -d "$kit_hooks" ]]; then
        warn "Starter kit missing _git-hooks-project/ folder"
        echo ""
        return 0
    fi

    local has_changes=0

    for kit_hook in "$kit_hooks"/*; do
        [[ -f "$kit_hook" ]] || continue

        local filename
        filename=$(basename "$kit_hook")

        # Skip README
        if [[ "$filename" == "README.md" ]]; then
            continue
        fi

        local project_hook="$project_hooks/$filename"

        if [[ ! -f "$project_hook" ]]; then
            warn "MISSING: $filename"
            has_changes=1
        else
            local kit_hash project_hash
            kit_hash=$(md5 -q "$kit_hook")
            project_hash=$(md5 -q "$project_hook")

            if [[ "$kit_hash" == "$project_hash" ]]; then
                # Check if executable
                if [[ -x "$project_hook" ]]; then
                    success "OK: $filename"
                else
                    warn "NOT EXECUTABLE: $filename"
                    has_changes=1
                fi
            else
                warn "DIFFERS: $filename"
                has_changes=1
            fi
        fi
    done

    echo ""
    return $has_changes
}

# Audit CLAUDE.md
audit_claude_md() {
    header "=== CLAUDE.MD AUDIT ==="
    echo ""

    if [[ ! -f "CLAUDE.md" ]]; then
        warn "CLAUDE.md missing"
        echo ""
        return 1
    fi

    # Check for @AGENTS.md import
    if ! grep -q "@AGENTS.md" "CLAUDE.md"; then
        warn "CLAUDE.md missing @AGENTS.md import"
        echo ""
        return 1
    fi

    # Check for extra content beyond minimal template
    # Minimal should only have: header, description, imports section, @AGENTS.md
    # Any other @ imports or content = extra
    local extra_imports
    extra_imports=$(grep -E "^@" "CLAUDE.md" | grep -v "@AGENTS.md" || true)

    local extra_content
    extra_content=$(grep -vE "^#|^$|^@AGENTS.md|^This file provides|^\*\*\*|^## Imports" "CLAUDE.md" | grep -v "^[[:space:]]*$" || true)

    if [[ -n "$extra_imports" || -n "$extra_content" ]]; then
        warn "CLAUDE.md has extra content (should only import @AGENTS.md)"
        if [[ -n "$extra_imports" ]]; then
            echo "Extra imports found:"
            echo "$extra_imports"
        fi
        if [[ -n "$extra_content" ]]; then
            echo "Extra content found:"
            echo "$extra_content" | head -10
        fi
        echo ""
        return 1
    fi

    success "CLAUDE.md is minimal with @AGENTS.md import"
    echo ""
    return 0
}

# Analyze AGENTS.md
analyze_agents_md() {
    local kit_path="$1"
    local kit_agents="$kit_path/AGENTS.md"

    header "=== AGENTS.MD ANALYSIS ==="
    echo ""

    if [[ ! -f "AGENTS.md" ]]; then
        warn "AGENTS.md missing in project"
        echo ""
        return 1
    fi

    if [[ ! -f "$kit_agents" ]]; then
        warn "AGENTS.md missing in starter kit"
        echo ""
        return 1
    fi

    # Extract imports from kit (canonical order)
    echo "Kit imports (canonical order):"
    grep -E "^@|^<!-- @" "$kit_agents" | head -20 || true
    echo ""

    # Extract imports from project
    echo "Project imports:"
    grep -E "^@|^<!-- @" "AGENTS.md" | head -20 || true
    echo ""

    # Check for non-import content
    local non_import_lines
    non_import_lines=$(grep -cvE "^#|^@|^<!-- @|^$|^\*\*\*|^## " "AGENTS.md" 2>/dev/null || echo "0")

    if [[ "$non_import_lines" -gt 5 ]]; then
        warn "AGENTS.md has significant non-import content ($non_import_lines lines)"
    fi

    return 0
}

# Main
main() {
    echo "=========================================="
    echo "STARTER KIT SYNC"
    echo "=========================================="
    echo ""

    check_project

    local kit_path
    kit_path=$(get_kit_path)

    echo "Project:     $PWD"
    echo "Starter Kit: $kit_path"
    echo ""

    local total_changes=0

    compare_airules "$kit_path" || total_changes=1
    compare_hooks "$kit_path" || total_changes=1
    audit_claude_md || total_changes=1
    analyze_agents_md "$kit_path" || true  # Don't count as blocking change

    echo "=========================================="
    if [[ $total_changes -eq 0 ]]; then
        success "All synced. No changes needed."
        exit 2
    else
        warn "Changes available. Review above and decide actions."
        exit 0
    fi
}

main "$@"
