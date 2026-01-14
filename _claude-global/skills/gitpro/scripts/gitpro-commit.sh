#!/bin/bash
# GitPro Commit - Full conventional commit with changelog
# Usage: gitpro-commit.sh --message "msg" [--type feat|fix|...] [--old-branch name] [--new-branch name] [--changelog "entry"]
#
# Pre-gitpro hook validates TS/TODO before this runs.
# Uses --no-verify since validation already complete.

set -e

# Parse arguments
MESSAGE=""
COMMIT_TYPE=""
OLD_BRANCH=""
NEW_BRANCH=""
CHANGELOG_ENTRY=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --message) MESSAGE="$2"; shift 2 ;;
        --type) COMMIT_TYPE="$2"; shift 2 ;;
        --old-branch) OLD_BRANCH="$2"; shift 2 ;;
        --new-branch) NEW_BRANCH="$2"; shift 2 ;;
        --changelog) CHANGELOG_ENTRY="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$MESSAGE" ]; then
    echo "Error: --message is required" >&2
    exit 1
fi

# Beads sync pre-commit
if [ -d ".beads" ] && command -v bd >/dev/null 2>&1; then
    echo "Syncing beads..."
    bd sync >/dev/null 2>&1 || true
fi

# Stage all changes
git add -A

# Branch rename (if requested)
if [ -n "$OLD_BRANCH" ] && [ -n "$NEW_BRANCH" ]; then
    echo "Renaming branch: $OLD_BRANCH -> $NEW_BRANCH"
    git branch -m "$NEW_BRANCH"

    # Delete old remote if exists
    if git ls-remote --heads origin "$OLD_BRANCH" | grep -q "$OLD_BRANCH"; then
        git push origin --delete "$OLD_BRANCH" 2>/dev/null || true
    fi
fi

# Changelog update (if provided)
if [ -n "$CHANGELOG_ENTRY" ] && [ -f "changelog.md" ]; then
    echo "Updating changelog..."

    # Get today's date header
    TODAY=$(date +"%B %-d, %Y")
    ENTRY_FILE=$(mktemp)
    printf '%s\n' "$CHANGELOG_ENTRY" > "$ENTRY_FILE"

    if grep -q "^### $TODAY" changelog.md; then
        # Today's header exists - add entry after it (after any existing entries for today)
        # Find line number of today's header, then next ### or EOF
        START_LINE=$(grep -n "^### $TODAY" changelog.md | head -1 | cut -d: -f1)
        # Insert after the header line
        {
            head -n "$START_LINE" changelog.md
            cat "$ENTRY_FILE"
            tail -n +"$((START_LINE + 1))" changelog.md
        } > changelog.md.tmp && mv changelog.md.tmp changelog.md
    else
        # Add new date section before first ### header
        FIRST_HEADER=$(grep -n "^### " changelog.md | head -1 | cut -d: -f1)
        if [ -n "$FIRST_HEADER" ]; then
            {
                head -n "$((FIRST_HEADER - 1))" changelog.md
                echo "### $TODAY"
                echo ""
                cat "$ENTRY_FILE"
                echo ""
                tail -n +"$FIRST_HEADER" changelog.md
            } > changelog.md.tmp && mv changelog.md.tmp changelog.md
        fi
    fi

    rm -f "$ENTRY_FILE"
    git add changelog.md
fi

# Stage beads files
if [ -d ".beads" ]; then
    [ -f ".beads/issues.jsonl" ] && git add ".beads/issues.jsonl" 2>/dev/null || true
    [ -f ".beads/deletions.jsonl" ] && git add ".beads/deletions.jsonl" 2>/dev/null || true
fi

# Commit
echo "Committing: $MESSAGE"
git commit --no-verify -m "$MESSAGE

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

# Beads sync post-commit
if [ -d ".beads" ] && command -v bd >/dev/null 2>&1; then
    bd sync >/dev/null 2>&1 || true
fi

# Push
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Pushing to origin..."
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        git push
    else
        git push -u origin "$CURRENT_BRANCH"
    fi
fi

echo "Commit complete: $MESSAGE"
