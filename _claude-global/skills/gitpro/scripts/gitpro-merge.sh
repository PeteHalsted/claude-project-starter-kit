#!/bin/bash
# GitPro Merge - Full merge-to-main workflow
# Usage: gitpro-merge.sh --source-branch name --bump-type major|minor|patch --username name
#
# Handles: merge, version bump, commit, tag, push (once!), cleanup, new branch creation
# Supports: Node.js (package.json) and Python (pyproject.toml)

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

if [ -z "$SOURCE_BRANCH" ] || [ -z "$USERNAME" ]; then
    echo "Error: --source-branch and --username are required" >&2
    exit 1
fi

WORKING_BRANCH="wt-${USERNAME}"
SCRIPT_DIR="$(dirname "$0")"

# Detect project type
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "pyproject.toml" ]; then
        echo "python"
    else
        echo "unknown"
    fi
}

# Bump version based on project type
bump_version() {
    local project_type="$1"
    local bump_type="$2"

    case "$project_type" in
        node)
            npm version "$bump_type" --no-git-tag-version
            ;;
        python)
            python3 "$SCRIPT_DIR/gitpro-bump-python.py" "$bump_type"
            ;;
        *)
            echo "Error: Unknown project type, cannot bump version" >&2
            exit 1
            ;;
    esac
}

# Stage version files based on project type
stage_version_files() {
    local project_type="$1"

    case "$project_type" in
        node)
            git add package.json
            [ -f "package-lock.json" ] && git add package-lock.json
            ;;
        python)
            git add pyproject.toml
            # Also stage __init__.py if it was updated by bump script
            git add "*/__init__.py" 2>/dev/null || true
            ;;
    esac
}

PROJECT_TYPE=$(detect_project_type)

echo "=== GitPro Merge to Main ==="
echo "Source: $SOURCE_BRANCH"
echo "Bump: $BUMP_TYPE"
echo "User: $USERNAME"
echo "Project: $PROJECT_TYPE"
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

# Version bump (skip if no project manifest)
if [ "$PROJECT_TYPE" = "unknown" ] || [ -z "$BUMP_TYPE" ]; then
    echo "No package.json or pyproject.toml — skipping version bump"
    NEW_VERSION=""
else
    echo "Bumping version ($BUMP_TYPE)..."
    NEW_VERSION=$(bump_version "$PROJECT_TYPE" "$BUMP_TYPE")
    echo "New version: $NEW_VERSION"

    # Stage and commit version bump
    stage_version_files "$PROJECT_TYPE"
    git commit --no-verify -m "🔖 chore: bump version to $NEW_VERSION"

    # Tag
    git tag "$NEW_VERSION"
fi

# Push main and tags (single push operation)
echo "Pushing main and tags..."
git push
[ -n "$NEW_VERSION" ] && git push --tags

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
[ -n "$NEW_VERSION" ] && echo "Version: $NEW_VERSION"
echo "Branch: $WORKING_BRANCH"
