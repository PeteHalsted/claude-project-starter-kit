#!/bin/bash
# GitPro Merge - Full merge-to-main workflow
# Usage: gitpro-merge.sh --source-branch name --bump-type major|minor|patch --username name
#
# Handles: merge, version bump, commit, tag, push (once!), cleanup, new branch creation

set -e

SOURCE_BRANCH=""
BUMP_TYPE=""
USERNAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --source-branch) SOURCE_BRANCH="$2"; shift 2 ;;
        --bump-type) BUMP_TYPE="$2"; shift 2 ;;
        --username) USERNAME="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$SOURCE_BRANCH" ] || [ -z "$BUMP_TYPE" ] || [ -z "$USERNAME" ]; then
    echo "Error: --source-branch, --bump-type, and --username are required" >&2
    exit 1
fi

WORKING_BRANCH="wt-${USERNAME}"

echo "=== GitPro Merge to Main ==="
echo "Source: $SOURCE_BRANCH"
echo "Bump: $BUMP_TYPE"
echo "User: $USERNAME"
echo ""

# Ensure source branch is pushed
echo "Pushing source branch..."
git push origin "$SOURCE_BRANCH" 2>/dev/null || true

# Checkout and update main
echo "Switching to main..."
git checkout main
git pull

# Merge source branch
echo "Merging $SOURCE_BRANCH..."
git merge "$SOURCE_BRANCH" --no-edit

# Version bump
echo "Bumping version ($BUMP_TYPE)..."
NEW_VERSION=$(npm version "$BUMP_TYPE" --no-git-tag-version)
echo "New version: $NEW_VERSION"

# Commit version bump
git add package.json package-lock.json
git commit --no-verify -m "chore: bump version to $NEW_VERSION"

# Tag
git tag "$NEW_VERSION"

# Push main and tags (single push operation)
echo "Pushing main and tags..."
git push && git push --tags

# Delete merged source branch
echo "Cleaning up source branch..."
if git branch --merged main | grep -q "$SOURCE_BRANCH"; then
    git branch -d "$SOURCE_BRANCH"
    git push origin --delete "$SOURCE_BRANCH" 2>/dev/null || true
    echo "Deleted: $SOURCE_BRANCH"
else
    echo "Warning: $SOURCE_BRANCH not fully merged, skipping delete"
fi

# Create fresh working branch
echo "Creating fresh working branch: $WORKING_BRANCH"

# Check if working branch exists and clean it up
if git branch --list "$WORKING_BRANCH" | grep -q "$WORKING_BRANCH"; then
    # Check for beads worktree
    if git worktree list | grep -q "$WORKING_BRANCH"; then
        git worktree remove ".git/beads-worktrees/$WORKING_BRANCH" --force 2>/dev/null || true
    fi
    git branch -D "$WORKING_BRANCH" 2>/dev/null || true
fi

# Create and push new branch
git checkout -b "$WORKING_BRANCH"
git push -u origin "$WORKING_BRANCH"

echo ""
echo "=== Merge Complete ==="
echo "Version: $NEW_VERSION"
echo "Branch: $WORKING_BRANCH"
