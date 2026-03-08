#!/bin/bash
# GitPro Branch - Branch creation, switching, and merge-from operations
# Usage: gitpro-branch.sh --action create|switch|merge-from [options]
#
# Actions:
#   create:     Create new branch and push to remote
#   switch:     Switch to existing branch
#   merge-from: Fetch and merge another branch into current

set -e

ACTION=""
BRANCH_NAME=""
USERNAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --action) ACTION="$2"; shift 2 ;;
        --branch) BRANCH_NAME="$2"; shift 2 ;;
        --username) USERNAME="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$ACTION" ]; then
    echo "Error: --action is required (create|switch|merge-from)" >&2
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

# Shared safety check
check_dirty() {
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        echo "Error: Uncommitted changes in working tree." >&2
        echo "Commit or checkpoint your changes first." >&2
        exit 1
    fi

    UNTRACKED=$(git ls-files --others --exclude-standard)
    if [ -n "$UNTRACKED" ]; then
        echo "Warning: Untracked files present (will not be affected):"
        echo "$UNTRACKED" | head -5
        [ "$(echo "$UNTRACKED" | wc -l)" -gt 5 ] && echo "  ... and more"
        echo ""
    fi
}

case "$ACTION" in
    create)
        # Default branch name: wt-{username}
        if [ -z "$BRANCH_NAME" ]; then
            if [ -z "$USERNAME" ]; then
                USERNAME=$(whoami)
            fi
            BRANCH_NAME="wt-${USERNAME}"
        fi

        check_dirty

        echo "=== GitPro Branch: Create ==="
        echo "New branch: $BRANCH_NAME"
        echo ""

        # Check if branch already exists locally
        if git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            echo "Error: Branch '$BRANCH_NAME' already exists locally." >&2
            echo "Switch to it with: gitpro-branch.sh --action switch --branch $BRANCH_NAME" >&2
            exit 1
        fi

        # Check if branch exists on remote
        git fetch origin 2>/dev/null || true
        if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            echo "Branch '$BRANCH_NAME' exists on remote. Checking out with tracking..."
            git checkout -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
        else
            git checkout -b "$BRANCH_NAME"
            git push -u origin "$BRANCH_NAME"
            echo "Created and pushed: $BRANCH_NAME"
        fi

        echo ""
        echo "=== Branch Created ==="
        echo "Branch: $BRANCH_NAME"
        ;;

    switch)
        if [ -z "$BRANCH_NAME" ]; then
            echo "Error: --branch is required for switch" >&2
            exit 1
        fi

        if [ "$CURRENT_BRANCH" = "$BRANCH_NAME" ]; then
            echo "Already on branch '$BRANCH_NAME'"
            exit 0
        fi

        check_dirty

        echo "=== GitPro Branch: Switch ==="
        echo "From: $CURRENT_BRANCH"
        echo "To:   $BRANCH_NAME"
        echo ""

        # Check if branch exists locally
        if git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            git checkout "$BRANCH_NAME"
        else
            # Try remote
            git fetch origin 2>/dev/null || true
            if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
                git checkout -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
                echo "Checked out remote branch with tracking."
            else
                echo "Error: Branch '$BRANCH_NAME' does not exist locally or on remote." >&2
                exit 1
            fi
        fi

        echo ""
        echo "=== Branch Switched ==="
        echo "Now on: $BRANCH_NAME"
        ;;

    merge-from)
        if [ -z "$BRANCH_NAME" ]; then
            echo "Error: --branch is required for merge-from" >&2
            exit 1
        fi

        echo "=== GitPro Branch: Merge From ==="
        echo "Source: $BRANCH_NAME"
        echo "Into:   $CURRENT_BRANCH"
        echo ""

        # Fetch latest
        echo "Fetching origin..."
        git fetch origin

        # Determine merge source (prefer remote for freshness)
        if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            MERGE_REF="origin/$BRANCH_NAME"
        elif git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            MERGE_REF="$BRANCH_NAME"
        else
            echo "Error: Branch '$BRANCH_NAME' does not exist locally or on remote." >&2
            exit 1
        fi

        # Show what's incoming
        INCOMING=$(git rev-list "HEAD..$MERGE_REF" --count 2>/dev/null || echo "0")
        if [ "$INCOMING" -eq 0 ]; then
            echo "No new commits to merge from $BRANCH_NAME."
            echo ""
            echo "=== Merge Complete (nothing to do) ==="
            exit 0
        fi

        echo "$INCOMING incoming commit(s):"
        git log --oneline "HEAD..$MERGE_REF"
        echo ""

        # Merge
        echo "Merging..."
        if ! git merge "$MERGE_REF" --no-edit; then
            echo "" >&2
            echo "Error: Merge conflict detected." >&2
            echo "Resolve conflicts manually, then commit via gitpro." >&2
            exit 1
        fi

        # Push current branch if it has a remote
        if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
            echo "Pushing $CURRENT_BRANCH..."
            git push
        fi

        echo ""
        echo "=== Merge Complete ==="
        echo "Merged $INCOMING commit(s) from $BRANCH_NAME into $CURRENT_BRANCH"
        ;;

    *)
        echo "Error: Unknown action '$ACTION'. Use: create|switch|merge-from" >&2
        exit 1
        ;;
esac
