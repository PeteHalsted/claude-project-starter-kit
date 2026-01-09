# Token-Based Hook Enforcement

A pattern for creating secure bypass mechanisms in Claude Code hooks that AI cannot easily circumvent.

## The Problem

When using hooks to enforce rules (like requiring a skill for certain operations), you need a way for the authorized skill to bypass the enforcement. Traditional approaches have weaknesses:

**Environment Variable Bypass (e.g., `GITPRO_RUNNING=1`)**
- AI can read the skill documentation and learn the bypass
- AI can manually prefix commands with the bypass variable
- The bypass mechanism is documented and discoverable

**Pattern-Based Bypass (e.g., checking command prefix)**
- Any prefix that breaks the pattern match works as a bypass
- Example: `GITPRO_RUNNING=1 git commit` bypasses `^git ` pattern match
- AI can discover this accidentally or intentionally

## The Solution: Token-Based Enforcement

Use component-scoped hooks (Claude Code 2.1+) to create tokens that global hooks validate. The bypass mechanism is opaque to the AI.

### How It Works

1. **Skill defines a component-scoped PreToolUse hook** that creates a token file
2. **Global hook checks for valid token** before allowing the command
3. **Token includes session ID** for multi-session safety
4. **Token has age validation** to prevent stale token reuse

### Implementation

#### Component Hook (skill creates token)

```bash
#!/bin/bash
# ~/.claude/skills/gitpro/scripts/create-token.sh

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TOKEN_FILE="/tmp/.gitpro-token-${SESSION_ID}"

# Create token with current timestamp
echo "$(date +%s)" > "$TOKEN_FILE"
exit 0
```

#### Skill Frontmatter (registers component hook)

```yaml
---
name: gitpro
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: ~/.claude/skills/gitpro/scripts/create-token.sh
          timeout: 5
---
```

#### Global Hook (validates token)

```bash
#!/bin/bash
# ~/.claude/hooks/git-guard.sh

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TOKEN_FILE="/tmp/.gitpro-token-${SESSION_ID}"

# Token-based bypass
if [ -f "$TOKEN_FILE" ]; then
  TOKEN_AGE=$(($(date +%s) - $(cat "$TOKEN_FILE")))
  if [ "$TOKEN_AGE" -lt 300 ]; then
    exit 0  # Valid token, allow command
  fi
fi

# Cleanup old tokens
find /tmp -name ".gitpro-token-*" -mmin +60 -delete 2>/dev/null

# ... rest of enforcement logic
```

## Hook Execution Order

Both component and global hooks run in parallel on PreToolUse. However, the timing typically works in our favor:

1. Both hooks start simultaneously
2. Global hook does initial setup (jq parsing, variable extraction)
3. Component hook creates token
4. Global hook checks for token - finds it

This works because:
- The global hook's setup work (parsing JSON, extracting session_id) takes time
- The component hook's work (create file, write timestamp) is fast
- By the time global hook checks `[ -f "$TOKEN_FILE" ]`, the file exists

## Multi-Session Safety

Using `session_id` from Claude Code's hook input ensures:
- Each session has its own token file
- Concurrent sessions don't interfere
- Token filename: `/tmp/.gitpro-token-{session_id}`

## Security Properties

1. **Bypass mechanism is not documented** - The skill doesn't mention tokens
2. **AI cannot fake tokens** - Would need to know the exact mechanism
3. **Session-scoped** - Tokens are per-session, can't be shared
4. **Time-limited** - Tokens expire after 5 minutes (configurable)
5. **Auto-cleanup** - Old tokens are deleted

## When to Use This Pattern

- High-security enforcement where AI cheating is a concern
- Skills that need to bypass global restrictions
- Multi-step workflows where authorization should persist

## Limitations

- Relies on parallel hook execution timing (not guaranteed)
- Adds slight complexity vs. simple env var bypass
- Temp file system required

## Future Enhancements

For even stronger security, consider:

1. **Cryptographic tokens** - Generate HMAC-signed tokens
2. **Process validation** - Check if token was created by legitimate hook process
3. **One-time tokens** - Token is deleted after first use
