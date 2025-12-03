#!/bin/bash

# Git Guard Hook - Enforces gitpro skill usage for git operations
# Part of the gitpro skill reliability enforcement system

# Read input from Claude Code
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Emergency override - set SKIP_GIT_GUARD=1 to bypass this hook
if [ "$SKIP_GIT_GUARD" = "1" ]; then
    exit 0
fi

# Allow if gitpro skill is running (detected by environment variable)
if [ "$GITPRO_RUNNING" = "1" ]; then
    exit 0
fi

# Check if this is a Bash command
if [ "$TOOL_NAME" = "Bash" ] || [ "$TOOL_NAME" = "mcp__acp__Bash" ]; then
    
    # Whitelist: Allow read-only git commands
    if echo "$COMMAND" | grep -E "^git (status|log|diff|show|branch(\s|$)|config|remote|tag(\s|$)|rev-parse|ls-files|describe)" > /dev/null; then
        exit 0
    fi
    
    # Whitelist: Allow git operations that don't modify history
    if echo "$COMMAND" | grep -E "^git (fetch|stash(\s|$)|reflog)" > /dev/null; then
        exit 0
    fi
    
    # Block: git commit (unless within gitpro)
    if echo "$COMMAND" | grep -E "^git commit" > /dev/null; then
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 GIT COMMIT BLOCKED\n\nYou attempted to run: $COMMAND\n\nABSOLUTE RULE: You MUST use the gitpro skill for all commit operations.\n\nWhat you SHOULD do:\n1. Invoke the Skill tool with: {\"skill\": \"gitpro\"}\n2. The gitpro skill will handle:\n   - Staging all changes (git add -A)\n   - Updating changelog.md\n   - Creating conventional commit message\n   - Committing everything together\n   - Pushing to remote (non-main branches)\n\nNEVER run 'git commit' directly. This rule exists to ensure:\n- Conventional commit format\n- Automatic changelog updates\n- Proper version bumping\n- Consistent workflow\n\nEmergency override: Set SKIP_GIT_GUARD=1 environment variable"
  }
}
BLOCK
        exit 0
    fi
    
    # Block: git add (unless within gitpro or allowing specific safe adds)
    if echo "$COMMAND" | grep -E "^git add" > /dev/null; then
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 GIT ADD BLOCKED\n\nYou attempted to run: $COMMAND\n\nABSOLUTE RULE: You MUST use the gitpro skill for git operations.\n\nThe gitpro skill handles staging as part of its workflow.\n\nWhat you SHOULD do:\n1. Invoke the Skill tool with: {\"skill\": \"gitpro\"}\n2. The gitpro skill will run 'git add -A' as part of its commit workflow\n\nDo NOT stage files manually. Use the gitpro skill.\n\nEmergency override: Set SKIP_GIT_GUARD=1 environment variable"
  }
}
BLOCK
        exit 0
    fi
    
    # Block: git push (unless within gitpro)
    if echo "$COMMAND" | grep -E "^git push" > /dev/null; then
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 GIT PUSH BLOCKED\n\nYou attempted to run: $COMMAND\n\nABSOLUTE RULE: You MUST use the gitpro skill for git operations.\n\nThe gitpro skill automatically pushes after commits (non-main branches).\n\nWhat you SHOULD do:\n1. If you need to commit: Invoke the Skill tool with: {\"skill\": \"gitpro\"}\n2. If you just need to push existing commits: This is rare - confirm with user first\n\nEmergency override: Set SKIP_GIT_GUARD=1 environment variable"
  }
}
BLOCK
        exit 0
    fi
    
    # Block: git merge (unless within gitpro)
    if echo "$COMMAND" | grep -E "^git merge" > /dev/null; then
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 GIT MERGE BLOCKED\n\nYou attempted to run: $COMMAND\n\nABSOLUTE RULE: You MUST use the gitpro skill for merge operations.\n\nWhat you SHOULD do:\n1. Invoke the Skill tool with: {\"skill\": \"gitpro\"}\n2. Tell the skill the user requested a merge\n3. The gitpro skill will handle:\n   - Committing current changes\n   - Pushing current branch\n   - Switching to main\n   - Pulling latest main\n   - Merging the branch\n   - Version bumping (major/minor/patch)\n   - Pushing merged main with tags\n\nNEVER run 'git merge' directly.\n\nEmergency override: Set SKIP_GIT_GUARD=1 environment variable"
  }
}
BLOCK
        exit 0
    fi
    
    # Block: git checkout/switch with -b (branch creation)
    if echo "$COMMAND" | grep -E "^git (checkout|switch) -b" > /dev/null; then
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 GIT BRANCH CREATION BLOCKED\n\nYou attempted to run: $COMMAND\n\nABSOLUTE RULE: You MUST use the gitpro skill for branch creation.\n\nWhat you SHOULD do:\n1. Invoke the Skill tool with: {\"skill\": \"gitpro\"}\n2. Tell the skill the user wants to create a new branch\n3. The gitpro skill will handle:\n   - Checking for uncommitted changes\n   - Creating the branch\n   - Pushing to remote with tracking\n\nNEVER create branches directly.\n\nEmergency override: Set SKIP_GIT_GUARD=1 environment variable"
  }
}
BLOCK
        exit 0
    fi
    
    # Block: git branch -m (rename)
    if echo "$COMMAND" | grep -E "^git branch -m" > /dev/null; then
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 GIT BRANCH RENAME BLOCKED\n\nYou attempted to run: $COMMAND\n\nABSOLUTE RULE: You MUST use the gitpro skill for branch renaming.\n\nWhat you SHOULD do:\n1. Invoke the Skill tool with: {\"skill\": \"gitpro\"}\n2. Tell the skill the user wants to rename the branch\n3. The gitpro skill will analyze current work and suggest/apply appropriate name\n\nNEVER rename branches directly.\n\nEmergency override: Set SKIP_GIT_GUARD=1 environment variable"
  }
}
BLOCK
        exit 0
    fi
fi

# Allow all other commands
exit 0
