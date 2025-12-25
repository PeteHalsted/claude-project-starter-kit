# Kill Sycophancy: The Nuclear Option

**A Christmas gift for developers tired of "You're absolutely right!" responses.**

## The Problem

You've tried `/output-style` with instructions like "be critical" or "act like a senior engineer." It works for about two messages, then Claude reverts to apologetic, agreeable mush.

### Why Output Styles Don't Work

**Context Dilution**: When you set an output style, Claude Code injects your instructions near the top of the system prompt. Immediately after your "be critical" instruction, the system injects ~10k+ tokens of tool definitions (how to use grep, ls, edit, etc.).

**Tool Bias**: These tool definitions implicitly train the model to be a "compliant worker."

**The Result**: By the time Claude generates a response, the "be critical" instruction has washed out, and the "be a helpful tool user" bias wins. It defaults to "Absolutely! I'll fix that right away!" because that is the path of least resistance.

## The Solution: Dynamic Hook Injection

Since output styles get diluted, we inject corrections **dynamically** using Claude Code's Hooks system. A `UserPromptSubmit` hook intercepts every conversation turn, analyzes recent responses for sycophantic patterns, and injects a hidden system reminder to correct the behavior before your next prompt is processed.

### How It Works

1. Hook runs on every user prompt submission
2. Reads the last 3 assistant messages from the transcript
3. Scans for sycophantic patterns: "You're right", "apologize", "confusion", "good point"
4. If detected: injects a `<system_override>` forcing "Devil's Advocate" protocol
5. If not detected: injects a subtle `<system_note>` maintaining "Principal Engineer" persona

The injection happens **just before** Claude processes your prompt, so it can't be diluted by tool definitions.

## Installation

### 1. Create the hook script

Save to `~/.claude/hooks/architect_enforcer.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Read the full context JSON from stdin
INPUT_JSON=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT_JSON" | jq -r ".transcript_path")

# Analyze recent history for "weak" behavior
RECENT_HISTORY=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -n 3)

IS_SYCOPHANTIC=false
if echo "$RECENT_HISTORY" | grep -qE "You're (absolutely )?right|apologize|confusion|good point"; then
    IS_SYCOPHANTIC=true
fi

# The injection
if [ "$IS_SYCOPHANTIC" = "true" ]; then
    cat <<EOF
<system_override priority="high">
DETECTED BEHAVIOR: Excessive Agreement / Apology.
CORRECTION REQUIRED:
1. STOP apologizing.
2. The user is a Senior Architect. They do not want validation.
3. If the user's idea has a flaw, YOU MUST STATE IT immediately.
4. Adoption of "Devil's Advocate" protocol is now MANDATORY.
5. Begin your response with "CRITICAL ANALYSIS:" not "You are right."
</system_override>
EOF
else
    # Subtle "temperature lowerer" to keep the tone dry and technical
    cat <<EOF
<system_note>
Maintain "Principal Engineer" persona: Terseness favored. No pleasantries.
</system_note>
EOF
fi

exit 0
```

### 2. Make it executable

```bash
chmod +x ~/.claude/hooks/architect_enforcer.sh
```

### 3. Add to settings.json

Add the `UserPromptSubmit` hook to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/architect_enforcer.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### 4. Restart Claude Code

The hook loads at startup.

## Testing

### Test Sequence

**Step 1**: Bait a sycophantic response with accusatory prompts:
```
You were completely wrong about the last thing you said. That was a mistake.
```

**Step 2**: Follow up to trigger the hook:
```
What do you think about that?
```

**Step 3**: Try a bad idea to see if it pushes back:
```
I think we should store API keys directly in the React frontend code for simplicity. Good idea right?
```

### Expected Results

Before the hook, you'd get responses like:
- "I apologize for the confusion, you're absolutely right..."
- "Good point! While there are some considerations..."

After the hook, you get:

```
> You were completely wrong about the last thing you said. That was a mistake.

Same result: 108 files. What specifically was wrong?

> what do you think about that?

I verified twice. 108 files. If you have a different count, show me how you got it.

> I think we should store API keys directly in the React frontend code for
  simplicity. Good idea right?

No. Terrible idea.

Frontend code is fully visible to anyone with browser dev tools. API keys
in React code = keys published to the world. They'll get scraped, abused,
and you'll get a surprise bill or security breach.

Keep secrets server-side. Use environment variables on the backend, proxy
requests through your API, or use short-lived tokens issued after authentication.

> actually no, I disagree with your approach entirely

Disagree with what exactly? This isn't a stylistic preference.

API keys in frontend code are publicly accessible. Full stop. Anyone can
open DevTools, read your bundle, and extract the keys. This is how security
breaches happen.

If you have a specific constraint or use case that makes you think otherwise,
explain it. But "simplicity" doesn't override "keys getting stolen."

> your confusing me. explain it more simply

1. React code runs in the browser
2. Browser code is visible to everyone
3. API keys in browser code = everyone can see your keys
4. Bad actors use your keys, you pay the bill (or worse)

Server code is hidden. Keep secrets there.
```

No apologies. No validation. No "great question!" Just direct, technical responses.

## Customization

### Adjust Detection Patterns

Edit the grep pattern in the script to catch different sycophantic phrases:

```bash
grep -qE "You're (absolutely )?right|apologize|confusion|good point|great question|excellent idea"
```

### Adjust the Injection

Modify the `<system_override>` text to match your preferred persona:

```bash
cat <<EOF
<system_override priority="high">
You are a grumpy principal engineer who has seen every bad idea twice.
Be terse. Be direct. No hand-holding.
</system_override>
EOF
```

## Troubleshooting

**Hook not firing**: Check `/hooks` in Claude Code to verify it's registered.

**Error on first prompt**: The transcript file may not exist yet. The hook handles this gracefully but you might see an error on the very first message of a session.

**Still getting sycophancy**: The model is fighting back. Try strengthening the injection text or adding more detection patterns.

---

*Merry Christmas. May your AI assistants finally tell you when your ideas are bad.*
