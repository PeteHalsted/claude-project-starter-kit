#!/bin/bash

# Git Guard Hook - Enforces gitpro skill usage for git operations
# Part of the gitpro skill reliability enforcement system

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

[ "$SKIP_GIT_GUARD" = "1" ] && exit 0
[ "$GITPRO_RUNNING" = "1" ] && exit 0

deny() {
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
    exit 0
}

if [ "$TOOL_NAME" = "Bash" ] || [ "$TOOL_NAME" = "mcp__acp__Bash" ]; then
    # Parse compound commands (handles ;, &&, ||, |)
    IFS=$'\n'
    PARTS=($(echo "$COMMAND" | sed 's/;/\n/g; s/&&/\n/g; s/||/\n/g; s/|/\n/g'))
    unset IFS

    for PART in "${PARTS[@]}"; do
        PART=$(echo "$PART" | xargs 2>/dev/null || echo "$PART")
        [ -z "$PART" ] && continue
        echo "$PART" | grep -q "^git " || continue

        # Whitelist: read-only and safe operations
        echo "$PART" | grep -E "^git (status|log|diff|show|branch(\s|$)|config|remote|tag(\s|$)|rev-parse|ls-files|describe|fetch|stash(\s|$)|reflog)" > /dev/null && continue

        # Block: git add
        if echo "$PART" | grep -E "^git add" > /dev/null; then
            deny "GIT ADD BLOCKED\\n\\nYou attempted to run: $PART\\n\\nABSOLUTE RULE: Use the gitpro skill for git operations.\\n\\nThe gitpro skill handles staging as part of its workflow.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}\\n\\nEmergency override: SKIP_GIT_GUARD=1"
        fi

        # Block: git commit
        if echo "$PART" | grep -E "^git commit" > /dev/null; then
            deny "GIT COMMIT BLOCKED\\n\\nYou attempted to run: $PART\\n\\nABSOLUTE RULE: Use the gitpro skill for all commits.\\n\\nThe gitpro skill handles:\\n- Staging changes\\n- Updating changelog.md\\n- Conventional commit format\\n- Auto-push (non-main branches)\\n\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}\\n\\nEmergency override: SKIP_GIT_GUARD=1"
        fi

        # Block: git push
        if echo "$PART" | grep -E "^git push" > /dev/null; then
            deny "GIT PUSH BLOCKED\\n\\nYou attempted to run: $PART\\n\\nABSOLUTE RULE: Use the gitpro skill for git operations.\\n\\nThe gitpro skill auto-pushes after commits (non-main branches).\\n\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}\\n\\nEmergency override: SKIP_GIT_GUARD=1"
        fi

        # Block: git merge
        if echo "$PART" | grep -E "^git merge" > /dev/null; then
            deny "GIT MERGE BLOCKED\\n\\nYou attempted to run: $PART\\n\\nABSOLUTE RULE: Use the gitpro skill for merge operations.\\n\\nThe gitpro skill handles:\\n- Committing current changes\\n- Switching to main\\n- Merging the branch\\n- Version bumping\\n- Pushing with tags\\n\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}\\n\\nEmergency override: SKIP_GIT_GUARD=1"
        fi

        # Block: destructive operations
        echo "$PART" | grep -E "^git reset" > /dev/null && deny "GIT RESET BLOCKED - Destructive operation. Fix issues with Read/Edit/Write tools instead."
        echo "$PART" | grep -E "^git restore" > /dev/null && deny "GIT RESTORE BLOCKED - Destructive operation. Fix issues with Read/Edit/Write tools instead."
        echo "$PART" | grep -E "^git revert" > /dev/null && deny "GIT REVERT BLOCKED - Destructive operation. Requires explicit user instruction."
        echo "$PART" | grep -E "^git clean" > /dev/null && deny "GIT CLEAN BLOCKED - Destructive operation. Requires explicit user instruction."

        # Block: branch creation
        if echo "$PART" | grep -E "^git (checkout|switch) -b" > /dev/null; then
            deny "GIT BRANCH CREATION BLOCKED\\n\\nYou attempted to run: $PART\\n\\nABSOLUTE RULE: Use the gitpro skill for branch creation.\\n\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}\\n\\nEmergency override: SKIP_GIT_GUARD=1"
        fi

        # Block: branch rename
        if echo "$PART" | grep -E "^git branch -m" > /dev/null; then
            deny "GIT BRANCH RENAME BLOCKED\\n\\nYou attempted to run: $PART\\n\\nABSOLUTE RULE: Use the gitpro skill for branch renaming.\\n\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}\\n\\nEmergency override: SKIP_GIT_GUARD=1"
        fi

        # Block: git checkout with file (destructive) but allow branch switching
        if echo "$PART" | grep -E "^git checkout" > /dev/null; then
            # Allow: git checkout branch-name (just alphanumeric, dash, slash)
            echo "$PART" | grep -E "^git checkout [a-zA-Z0-9_/-]+$" > /dev/null && continue
            deny "GIT CHECKOUT FILE BLOCKED - Destructive operation. Fix issues with Read/Edit/Write tools instead."
        fi
    done
fi
exit 0
