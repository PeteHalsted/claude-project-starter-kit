#!/bin/bash
# GitPro Sync - Safe fast-forward from remote
# Usage: gitpro-sync.sh [--branch name]
#
# Fetches remote and fast-forwards local branch. Refuses if:
# - Working tree has uncommitted changes
# - Local branch has unpushed commits (diverged history)
# - Fast-forward not possible (requires merge)

set -e

BRANCH="main"

while [[ $# -gt 0 ]]; do
    case $1 in
        --branch) BRANCH="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

CURRENT_BRANCH=$(git branch --show-current)

echo "=== GitPro Sync ==="
echo "Branch: $BRANCH"
echo ""

# 1. Check for uncommitted changes
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "Error: Uncommitted changes in working tree." >&2
    echo "Commit or stash your changes first." >&2
    exit 1
fi

# Also check for untracked files that might conflict
UNTRACKED=$(git ls-files --others --exclude-standard)
if [ -n "$UNTRACKED" ]; then
    echo "Warning: Untracked files present (will not be affected):"
    echo "$UNTRACKED" | head -5
    [ "$(echo "$UNTRACKED" | wc -l)" -gt 5 ] && echo "  ... and more"
    echo ""
fi

# 2. Switch to target branch if needed
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo "Switching to $BRANCH..."
    git checkout "$BRANCH"
fi

# 3. Fetch remote
echo "Fetching origin..."
git fetch origin

# 4. Check for unpushed local commits
LOCAL_AHEAD=$(git rev-list "origin/${BRANCH}..HEAD" --count 2>/dev/null || echo "0")
if [ "$LOCAL_AHEAD" -gt 0 ]; then
    echo "Error: You have $LOCAL_AHEAD unpushed local commit(s):" >&2
    git log --oneline "origin/${BRANCH}..HEAD" >&2
    echo "" >&2
    echo "Push your changes first, or merge manually." >&2
    # Switch back if we changed branches
    if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
        git checkout "$CURRENT_BRANCH"
    fi
    exit 1
fi

# 5. Check for incoming changes
REMOTE_AHEAD=$(git rev-list "HEAD..origin/${BRANCH}" --count 2>/dev/null || echo "0")
if [ "$REMOTE_AHEAD" -eq 0 ]; then
    echo "Already up to date."
    # Switch back if we changed branches
    if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
        git checkout "$CURRENT_BRANCH"
    fi
    exit 0
fi

# 6. Show incoming commits
echo "$REMOTE_AHEAD incoming commit(s):"
git log --oneline "HEAD..origin/${BRANCH}"
echo ""

# 7. Fast-forward merge
echo "Fast-forwarding..."
git merge --ff-only "origin/${BRANCH}"

# 8. Switch back if we changed branches
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo "Switching back to $CURRENT_BRANCH..."
    git checkout "$CURRENT_BRANCH"
fi

echo ""
echo "=== Sync Complete ==="
echo "Updated $BRANCH to $(git rev-parse --short "origin/${BRANCH}")"
