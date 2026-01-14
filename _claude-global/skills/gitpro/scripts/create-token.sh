#!/bin/bash
# Component hook: Create token for gitpro session
# This runs as a PreToolUse hook when gitpro skill is active
# Allows git-guard.sh to bypass blocking for gitpro operations

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TOKEN_FILE="/tmp/.gitpro-token-${SESSION_ID}"

# Create token with current timestamp
echo "$(date +%s)" > "$TOKEN_FILE"
exit 0
