#!/bin/bash

# Git Guard Hook - Enforces gitpro skill usage for git operations
# Uses token-based bypass when gitpro skill is active (component hook creates token)

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Extract session ID for token validation
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TOKEN_FILE="/tmp/.gitpro-token-${SESSION_ID}"

# Token-based bypass: gitpro component hook creates token when skill is active
if [ -f "$TOKEN_FILE" ]; then
  TOKEN_AGE=$(($(date +%s) - $(cat "$TOKEN_FILE")))
  if [ "$TOKEN_AGE" -lt 300 ]; then
    exit 0  # Valid token, allow command
  fi
fi

# Cleanup old tokens (>1 hour)
find /tmp -name ".gitpro-token-*" -mmin +60 -delete 2>/dev/null

# Output functions
deny() {
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
    exit 0
}

delegate() {
    # For non-standard commands: explain and ask user to run manually
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
    exit 0
}

if [ "$TOOL_NAME" = "Bash" ] || [ "$TOOL_NAME" = "mcp__acp__Bash" ]; then
    # Strip leading VAR=value prefixes to get actual command
    CLEAN_COMMAND=$(echo "$COMMAND" | sed 's/^[A-Za-z_][A-Za-z0-9_]*=[^ ]* *//')

    # Parse compound commands (handles ;, &&, ||, |)
    IFS=$'\n'
    PARTS=($(echo "$CLEAN_COMMAND" | sed 's/;/\n/g; s/&&/\n/g; s/||/\n/g; s/|/\n/g'))
    unset IFS

    for PART in "${PARTS[@]}"; do
        PART=$(echo "$PART" | xargs 2>/dev/null || echo "$PART")
        [ -z "$PART" ] && continue

        # Also strip VAR=value from each part (for chained commands)
        PART=$(echo "$PART" | sed 's/^[A-Za-z_][A-Za-z0-9_]*=[^ ]* *//')

        echo "$PART" | grep -q "^git " || continue

        # Whitelist: read-only and safe operations
        echo "$PART" | grep -E "^git (status|log|diff|show|branch(\s|$)|config|remote|tag(\s|$)|rev-parse|ls-files|describe|fetch|stash list|reflog)" > /dev/null && continue

        # === GITPRO STANDARD WORKFLOW - Use skill ===

        # git add - staging
        if echo "$PART" | grep -E "^git add" > /dev/null; then
            deny "GIT ADD BLOCKED\\n\\nYou attempted: $PART\\n\\nUse the gitpro skill for staging and commits.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}"
        fi

        # git commit - committing
        if echo "$PART" | grep -E "^git commit" > /dev/null; then
            deny "GIT COMMIT BLOCKED\\n\\nYou attempted: $PART\\n\\nUse the gitpro skill for commits.\\nIt handles: staging, changelog, conventional format, auto-push.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}"
        fi

        # git push - pushing
        if echo "$PART" | grep -E "^git push" > /dev/null; then
            deny "GIT PUSH BLOCKED\\n\\nYou attempted: $PART\\n\\nUse the gitpro skill - it auto-pushes after commits.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}"
        fi

        # git merge - merging
        if echo "$PART" | grep -E "^git merge" > /dev/null; then
            deny "GIT MERGE BLOCKED\\n\\nYou attempted: $PART\\n\\nUse the gitpro skill for merges.\\nIt handles: commit, merge, version bump, cleanup.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}"
        fi

        # git checkout -b / switch -b - branch creation
        if echo "$PART" | grep -E "^git (checkout|switch) -b" > /dev/null; then
            deny "GIT BRANCH CREATION BLOCKED\\n\\nYou attempted: $PART\\n\\nUse the gitpro skill for branch creation.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}"
        fi

        # git branch -m - branch rename
        if echo "$PART" | grep -E "^git branch -m" > /dev/null; then
            deny "GIT BRANCH RENAME BLOCKED\\n\\nYou attempted: $PART\\n\\nUse the gitpro skill for branch renaming.\\nInvoke: Skill tool with {\\\"skill\\\": \\\"gitpro\\\"}"
        fi

        # === DESTRUCTIVE OPERATIONS - Always blocked ===

        if echo "$PART" | grep -E "^git reset" > /dev/null; then
            deny "GIT RESET BLOCKED\\n\\nYou attempted: $PART\\n\\nThis is a DESTRUCTIVE operation that discards commits or changes.\\nNEVER run this command - fix issues with Read/Edit/Write tools.\\n\\nIf you believe this is necessary, explain to the user:\\n- What problem you're trying to solve\\n- What this command would do\\n- Ask them to run it manually if appropriate"
        fi

        if echo "$PART" | grep -E "^git restore" > /dev/null; then
            deny "GIT RESTORE BLOCKED\\n\\nYou attempted: $PART\\n\\nThis is a DESTRUCTIVE operation that discards file changes.\\nNEVER run this command - fix issues with Read/Edit/Write tools.\\n\\nIf you need to undo changes, use Edit tool to restore content."
        fi

        if echo "$PART" | grep -E "^git revert" > /dev/null; then
            deny "GIT REVERT BLOCKED\\n\\nYou attempted: $PART\\n\\nThis creates a commit that undoes previous changes.\\n\\nIf you believe this is necessary, explain to the user:\\n- Which commit(s) need reverting and why\\n- What the revert will do\\n- Ask them to run it manually if appropriate"
        fi

        if echo "$PART" | grep -E "^git clean" > /dev/null; then
            deny "GIT CLEAN BLOCKED\\n\\nYou attempted: $PART\\n\\nThis PERMANENTLY DELETES untracked files.\\nNEVER run this command.\\n\\nIf cleanup is needed, explain to the user what files should be removed and let them handle it."
        fi

        # git checkout with file path - destructive
        if echo "$PART" | grep -E "^git checkout" > /dev/null; then
            # Allow: git checkout branch-name (just alphanumeric, dash, slash, dot)
            echo "$PART" | grep -E "^git checkout [a-zA-Z0-9_./-]+$" > /dev/null && continue
            deny "GIT CHECKOUT FILE BLOCKED\\n\\nYou attempted: $PART\\n\\nChecking out specific files discards changes.\\nFix issues with Read/Edit/Write tools instead."
        fi

        # === NON-STANDARD OPERATIONS - Explain and delegate ===

        # git stash (except list which is whitelisted above)
        if echo "$PART" | grep -E "^git stash" > /dev/null; then
            delegate "GIT STASH OPERATION\\n\\nYou attempted: $PART\\n\\nThis is outside gitpro's standard workflow.\\n\\nWhat this does: Temporarily shelves changes so you can work on something else.\\n- 'git stash' or 'git stash push': Save current changes to stash\\n- 'git stash pop': Apply most recent stash and remove it\\n- 'git stash apply': Apply stash but keep it\\n\\nPlease run this command manually if needed."
        fi

        # git cherry-pick
        if echo "$PART" | grep -E "^git cherry-pick" > /dev/null; then
            delegate "GIT CHERRY-PICK OPERATION\\n\\nYou attempted: $PART\\n\\nThis is outside gitpro's standard workflow.\\n\\nWhat this does: Applies changes from specific commit(s) to current branch.\\nUseful for selectively pulling fixes without full merge.\\n\\nPlease run this command manually if needed."
        fi

        # git rebase
        if echo "$PART" | grep -E "^git rebase" > /dev/null; then
            delegate "GIT REBASE OPERATION\\n\\nYou attempted: $PART\\n\\nThis is outside gitpro's standard workflow.\\n\\nWhat this does: Reapplies commits on top of another branch.\\nCan rewrite history - use with caution.\\n\\nPlease run this command manually if needed."
        fi

        # git tag with arguments (creating tags)
        if echo "$PART" | grep -E "^git tag -" > /dev/null; then
            delegate "GIT TAG CREATION\\n\\nYou attempted: $PART\\n\\nThis is outside gitpro's standard workflow.\\n\\nWhat this does: Creates a tag (bookmark) at a specific commit.\\ngitpro handles version tags during merge-to-main workflow.\\n\\nFor manual tags, please run this command yourself."
        fi

        # git pull (potentially dangerous, prefer fetch + merge)
        if echo "$PART" | grep -E "^git pull" > /dev/null; then
            delegate "GIT PULL OPERATION\\n\\nYou attempted: $PART\\n\\nThis combines fetch + merge which can cause unexpected merges.\\n\\nSafer approach:\\n1. git fetch origin\\n2. Review changes: git log HEAD..origin/branch\\n3. Merge explicitly via gitpro\\n\\nPlease run this command manually if needed."
        fi

    done
fi
exit 0
