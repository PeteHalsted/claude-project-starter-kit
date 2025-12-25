#!/bin/bash

# Read input from Claude Code
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Check if this is a Bash command with database operations
if [ "$TOOL_NAME" = "Bash" ] || [ "$TOOL_NAME" = "mcp__acp__Bash" ]; then
    if echo "$COMMAND" | grep -E "(db:generate|db:migrate|db:push|drizzle-kit)" > /dev/null; then
        # Block the command
        cat <<BLOCK
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "🚫 DATABASE COMMAND BLOCKED\n\nYou attempted to run: $COMMAND\n\nPer constitution line 25: AI agents MUST NEVER run drizzle commands.\n\nWhat you SHOULD do:\n1. Modify schema files ONLY\n2. STOP immediately\n3. Tell the human: 'Schema changes ready. Please run: npm run db:generate && npm run db:migrate'\n4. Wait for human to review and execute\n\nYou cannot generate OR apply migrations. This is a hard constitutional rule."
  }
}
BLOCK
        exit 0
    fi
fi

# Allow all other commands
exit 0
