#!/bin/bash
# GitPro Checkpoint - Quick timestamped commit
# Usage: gitpro-checkpoint.sh [optional-message]
#
# Creates a fast checkpoint commit without full validation.
# Uses --no-verify since pre-gitpro hook handles validation context.

set -e

MESSAGE_PREFIX="${1:-Checkpoint}"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M.%S)

# Check for changes
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to checkpoint"
    exit 0
fi

# Stage all changes
git add -A

# Commit with timestamp
if [ "$MESSAGE_PREFIX" = "Checkpoint" ]; then
    COMMIT_MSG="${TIMESTAMP} Checkpoint"
else
    COMMIT_MSG="${MESSAGE_PREFIX} - ${TIMESTAMP}"
fi

git commit --no-verify -m "$COMMIT_MSG"

echo "Checkpoint created: $COMMIT_MSG"
