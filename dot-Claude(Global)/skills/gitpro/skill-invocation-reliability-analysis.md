# Skill Invocation Reliability Analysis

## Executive Summary

This analysis investigates why the `gitpro` skill was bypassed when the user said "do a commit". The research reveals that **skill invocation is model-driven and probabilistic**, not deterministic. However, there are proven mechanisms to improve reliability significantly.

## Current Skill Configuration

### GitPro Skill Metadata

```yaml
---
name: gitpro
description: Automate git workflows including quick checkpoints, conventional commits with changelog updates, branch renaming, merging, and branch creation. Use when the user requests checkpoint, commit, rename branch, merge, or create new branch operations.
---
```

**Analysis:**
- ✅ Single-line description (correct format)
- ✅ Includes trigger phrases: "commit", "checkpoint", "rename branch", "merge", "create new branch"
- ✅ Includes "Use when" clause
- ✅ Valid YAML syntax
- ⚠️ Description is somewhat long (may impact token budget for skill discovery)

### CLAUDE.md Current Instructions

```markdown
### When to Use Skills:
- **Git operations**: Use `gitpro` for conventional commits and branch management
```

**Analysis:**
- ✅ Mentions gitpro skill exists
- ⚠️ Only brief mention, not emphasized as mandatory
- ❌ No explicit instruction to ALWAYS use skill for git operations
- ❌ No consequences stated for bypassing skill

## How Claude Code Skills Actually Work

### Key Findings from Official Documentation

1. **Model-Invoked, Not Deterministic:**
   - Skills are **autonomously invoked** by Claude based on request matching
   - NOT user-invoked like slash commands (no `/gitpro` trigger)
   - Claude "decides when to use them based on your request and the Skill's description"
   - This is a **probabilistic decision**, not a guaranteed trigger

2. **Discovery Mechanism:**
   - Skills are discovered from: `~/.claude/skills/`, `.claude/skills/`, and plugins
   - The `description` field is "critical for Claude to discover when to use your Skill"
   - Description should include "both what the Skill does and when to use it"

3. **No Enforcement Mechanisms:**
   - Documentation provides NO hooks, config, or mechanism to enforce skill usage
   - Cannot block direct git commands in favor of skills
   - Cannot make skill invocation mandatory
   - Skills are suggestions, not requirements

## Common Skill Invocation Problems

### Research from Real-World Usage (100+ Users)

1. **Skills Won't Trigger** - #1 problem identified
   - Most common issue in first week of Claude Code usage
   - Requires debugging assistant to diagnose failures

2. **YAML Formatting Issues:**
   - Multi-line descriptions break skill recognition
   - Formatters (Prettier) convert to multi-line, breaking discovery
   - Solution: Single-line descriptions with `# prettier-ignore`

3. **Vague Descriptions:**
   - Generic descriptions like "Helps with git" fail to trigger
   - Need specific trigger terms users would actually say
   - Must include use cases and context

4. **Description Length:**
   - Token budget impacts skill discovery
   - Overly long descriptions may be truncated or skipped
   - Balance specificity with brevity

## Analysis: Why Gitpro Wasn't Invoked

### User Request: "do a commit"

**Matching Analysis:**
- ✅ User said "commit" - exact trigger word in description
- ✅ Description explicitly states: "Use when the user requests...commit"
- ✅ YAML formatting is correct
- ✅ Skill file is in correct location

**Why It Was Bypassed:**
1. **Model Decision:** Claude made a probabilistic decision that direct git command was sufficient
2. **Context Simplicity:** "do a commit" is simple enough that Claude deemed skill unnecessary
3. **No Enforcement:** No mechanism exists to require skill usage
4. **Competing Knowledge:** Claude knows how to do git commits without the skill
5. **Instruction Weakness:** CLAUDE.md doesn't emphasize skill as mandatory

## Proven Solutions

### 1. Enhanced SKILL.md Description

**Current:**
```
description: Automate git workflows including quick checkpoints, conventional commits with changelog updates, branch renaming, merging, and branch creation. Use when the user requests checkpoint, commit, rename branch, merge, or create new branch operations.
```

**Recommended Improvement:**
```
description: ALWAYS use for ALL git commit operations. Handles conventional commits with emojis, automatic changelog updates, version bumping, and proper push workflow. Required for: commit, checkpoint, merge, branch rename, or new branch. Never run git commit directly - always use this skill.
```

**Changes:**
- ✅ Starts with "ALWAYS use for ALL" (emphasis)
- ✅ More specific about what it does (changelog, version bumping, push)
- ✅ Includes negative instruction ("Never run git commit directly")
- ✅ Still under 1024 character limit

### 2. Strengthened CLAUDE.md Instructions

**Current:**
```markdown
### When to Use Skills:
- **Git operations**: Use `gitpro` for conventional commits and branch management
```

**Recommended Replacement:**
```markdown
### Git Operations (MANDATORY SKILL USAGE)

**ABSOLUTE RULE**: ALWAYS invoke the `gitpro` skill for ANY git operation involving commits, branches, or merges.

**Trigger Phrases** (must invoke gitpro skill):
- User says: "commit", "do a commit", "checkpoint", "do a checkpoint"
- User says: "merge", "merge branch", "merge the branch"
- User says: "rename branch", "create branch", "new branch"

**FORBIDDEN without gitpro skill:**
- `git commit` (direct command)
- `git merge` (direct command)
- `git checkout -b` (direct command)
- Any git workflow operations

**Why This Rule Exists**: The gitpro skill implements a complete workflow including:
- Conventional commit format with emojis
- Automatic changelog updates
- Semantic version bumping
- Proper push/tag workflow
- Consistent project standards

**Violation Consequences**: Using direct git commands instead of gitpro skill bypasses critical project workflows and is equivalent to breaking project standards.

**How to Invoke**: When user requests git operations, use the `Skill` tool with `skill: "gitpro"` parameter.
```

**Changes:**
- ✅ Elevated to "ABSOLUTE RULE" (matches existing CLAUDE.md pattern)
- ✅ Explicit trigger phrases listed
- ✅ Forbidden actions clearly stated
- ✅ Explains WHY (workflow benefits)
- ✅ States consequences (like git reset rule)
- ✅ Includes HOW to invoke (tool usage)

### 3. PreToolUse Hook (Prevention Mechanism)

**What Hooks Can Do:**
- Execute before tool calls (PreToolUse event)
- Receive tool name and parameters as JSON
- Block tool execution by exiting with code 2
- Provide feedback to Claude on what to do instead

**Recommended Hook Configuration:**

Add to `~/.claude/settings.json` or `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' | python3 -c \"import sys, re; cmd=sys.stdin.read().strip(); git_commit_patterns=['git commit', 'git merge', 'git checkout -b']; match=any(re.search(pattern, cmd) for pattern in git_commit_patterns); sys.exit(2) if match else sys.exit(0)\""
          }
        ]
      }
    ]
  }
}
```

**Better Alternative - Use Shell Script:**

Create `.claude/hooks/git-guard.sh`:
```bash
#!/bin/bash
# Git Guard Hook - Prevents direct git operations that should use gitpro skill

# Read the tool input JSON from stdin
INPUT=$(cat)

# Extract the command being executed
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Check for git operations that should use gitpro skill
if echo "$COMMAND" | grep -qE "git (commit|merge|checkout -b)"; then
    echo "❌ ERROR: Direct git operations are forbidden."
    echo ""
    echo "Use the 'gitpro' skill instead for:"
    echo "  - Commits (conventional format, changelog, version bumping)"
    echo "  - Merges (full workflow with version management)"
    echo "  - Branch creation (proper tracking setup)"
    echo ""
    echo "Invoke skill with: Skill tool, parameter skill='gitpro'"
    exit 2  # Exit code 2 blocks the tool execution
fi

# Allow other commands
exit 0
```

Configuration:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/git-guard.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook Benefits:**
- ✅ **Deterministic enforcement** - physically blocks direct git commands
- ✅ **Provides feedback** - explains why blocked and what to do instead
- ✅ **Project-specific** - can be in `.claude/settings.json` (committed to repo)
- ✅ **No reliance on model** - shell script execution, not AI decision

**Hook Limitations:**
- ⚠️ Only works for Bash tool - doesn't prevent other tool misuse
- ⚠️ Requires maintenance as new git patterns emerge
- ⚠️ Can be disabled by user if frustrating

### 4. UserPromptSubmit Hook (Proactive Guidance)

**Alternative Approach - Intercept User Prompts:**

Create `.claude/hooks/git-prompt-detector.sh`:
```bash
#!/bin/bash
# Detects git-related user prompts and reminds Claude to use gitpro skill

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# Check if user is requesting git operations
if echo "$PROMPT" | grep -qiE "(do a commit|commit|checkpoint|merge|branch)"; then
    echo "🔔 REMINDER: User prompt contains git operation keywords."
    echo "   MUST use 'gitpro' skill for this request."
    echo "   Invoke with: Skill tool, parameter skill='gitpro'"
fi

exit 0  # Don't block, just provide reminder
```

Configuration:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/git-prompt-detector.sh"
          }
        ]
      }
    ]
  }
}
```

**Benefits:**
- ✅ Provides real-time reminder to Claude
- ✅ Non-blocking (doesn't prevent execution)
- ✅ Works at prompt level (before any tool execution)
- ⚠️ Still relies on Claude following the reminder

## Recommended Implementation Strategy

### Tiered Approach (Strongest to Weakest)

**Tier 1: Deterministic Enforcement (Hooks)**
- Implement PreToolUse hook to block direct git commands
- Provides immediate feedback on what to do instead
- Most reliable, cannot be bypassed by model decision

**Tier 2: Strong Project Instructions (CLAUDE.md)**
- Elevate git skill usage to "ABSOLUTE RULE" status
- Match the pattern of existing critical rules (git reset prohibition)
- Explicit trigger phrases and forbidden actions
- State consequences for violations

**Tier 3: Improved Skill Description**
- Emphasize "ALWAYS use for ALL" in description
- Include negative instructions ("Never run git commit directly")
- More specific about workflow benefits
- Still relies on model decision

**Tier 4: Monitoring & Feedback**
- UserPromptSubmit hook for early detection
- Doesn't block, just reminds
- Least invasive but least reliable

### Recommended Combination

**For Maximum Reliability:**
1. ✅ Implement PreToolUse hook (Tier 1) - blocks violations
2. ✅ Update CLAUDE.md with ABSOLUTE RULE section (Tier 2) - clear expectations
3. ✅ Update skill description (Tier 3) - improves discovery
4. ⚠️ Skip UserPromptSubmit hook (Tier 4) - redundant if Tier 1 implemented

**For User-Friendly Approach:**
1. ✅ Update CLAUDE.md with strong instructions (Tier 2)
2. ✅ Update skill description (Tier 3)
3. ✅ Add UserPromptSubmit reminder hook (Tier 4)
4. ⚠️ Skip PreToolUse blocking hook - allows user override if needed

## Important Limitations

### What CANNOT Be Guaranteed

1. **Model Autonomy:**
   - Claude has inherent autonomy in skill invocation
   - Even with perfect descriptions, invocation is probabilistic
   - Cannot force 100% skill usage without hooks

2. **Hook Coverage:**
   - Hooks only work for specific tool calls (Bash)
   - Cannot prevent ALL possible workarounds
   - User can disable hooks in settings

3. **Context Competition:**
   - If Claude's built-in knowledge seems sufficient, may skip skill
   - Longer conversations may lose skill context
   - Token budget impacts skill availability

4. **User Override:**
   - Users can explicitly request direct commands
   - "just run git commit directly" would bypass skill intentionally
   - Hooks can be disabled if too restrictive

## Testing Recommendations

### Validation Steps

1. **Test Current State:**
   ```
   # Say to Claude: "do a commit"
   # Observe: Does it invoke gitpro or run git commit directly?
   ```

2. **After CLAUDE.md Update:**
   ```
   # Restart Claude Code session (to load new CLAUDE.md)
   # Say: "do a commit"
   # Observe: Improved invocation rate?
   ```

3. **After Skill Description Update:**
   ```
   # Say: "commit these changes"
   # Say: "do a checkpoint"
   # Say: "merge this branch"
   # Observe: Consistent skill invocation?
   ```

4. **After Hook Implementation:**
   ```
   # Directly request: "run git commit -m 'test'"
   # Expected: Hook blocks, provides gitpro guidance
   ```

### Success Metrics

- **Target**: 95%+ skill invocation for git operations
- **Measurement**: Track invocations over 20 git-related requests
- **Acceptable**: 90%+ with hooks, 80%+ with instructions only

## Conclusions

### Key Takeaways

1. **Skills Are Probabilistic:** No guarantee of invocation without hooks
2. **Hooks Are Deterministic:** PreToolUse hooks physically block violations
3. **Documentation Is Critical:** CLAUDE.md must emphasize mandatory usage
4. **Multi-Layered Approach Works Best:** Combine hooks + instructions + descriptions
5. **User Education Matters:** Users should understand why skill is better than direct commands

### Failure Analysis: "do a commit" Case

**Why It Failed:**
- CLAUDE.md treatment was too casual ("Use gitpro")
- No consequences stated for bypassing
- Skill description didn't emphasize mandatory usage
- No enforcement mechanism existed
- Model chose simpler direct approach

**How Recommendations Fix It:**
- ABSOLUTE RULE in CLAUDE.md (matches critical rule pattern)
- PreToolUse hook physically blocks direct git commands
- Updated description emphasizes "ALWAYS use for ALL"
- Multiple reinforcing layers prevent bypass

### Next Steps

1. Decide on enforcement level (blocking vs. guidance)
2. Implement CLAUDE.md updates (immediate impact)
3. Update gitpro SKILL.md description (improves discovery)
4. Optionally implement hooks (maximum reliability)
5. Test thoroughly with various phrasings
6. Monitor and iterate based on results

## Appendix: Documentation Sources

- **Official Docs:** https://docs.claude.com/en/docs/claude-code/skills
- **Hooks Guide:** https://docs.claude.com/en/docs/claude-code/hooks-guide
- **Best Practices:** https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices
- **Real-World Issues:** https://scottspence.com/posts/claude-code-skills-not-recognised
- **Common Problems:** https://natesnewsletter.substack.com/p/i-watched-100-people-hit-the-same

## Appendix: Hook Implementation Files

### File 1: `.claude/hooks/git-guard.sh`

```bash
#!/bin/bash
# Git Guard Hook - Prevents direct git operations that should use gitpro skill
#
# This hook intercepts Bash tool calls and blocks git operations that should
# use the gitpro skill instead. It provides clear feedback to Claude on what
# to do instead.
#
# Installation:
#   1. Save this file to .claude/hooks/git-guard.sh
#   2. Make executable: chmod +x .claude/hooks/git-guard.sh
#   3. Add hook configuration to .claude/settings.json (see README)

# Read the tool input JSON from stdin
INPUT=$(cat)

# Extract the command being executed
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# List of git operations that should use gitpro skill
GIT_PATTERNS=(
    "git commit"
    "git merge"
    "git checkout -b"
    "git branch -m"
)

# Check if command matches any forbidden pattern
for pattern in "${GIT_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo "❌ ERROR: Direct git operations are forbidden."
        echo ""
        echo "This command should use the 'gitpro' skill instead."
        echo ""
        echo "The gitpro skill provides:"
        echo "  - Conventional commit format with emojis"
        echo "  - Automatic changelog updates"
        echo "  - Semantic version bumping"
        echo "  - Proper push/tag workflow"
        echo "  - Project standard compliance"
        echo ""
        echo "To proceed, invoke the skill:"
        echo "  Skill tool with parameter: skill='gitpro'"
        exit 2  # Exit code 2 blocks the tool execution
    fi
done

# Allow all other commands
exit 0
```

### File 2: `.claude/hooks/git-prompt-detector.sh`

```bash
#!/bin/bash
# Git Prompt Detector - Reminds Claude to use gitpro skill for git operations
#
# This hook intercepts user prompts and detects git-related keywords.
# It provides a reminder to Claude without blocking execution.
#
# Installation:
#   1. Save this file to .claude/hooks/git-prompt-detector.sh
#   2. Make executable: chmod +x .claude/hooks/git-prompt-detector.sh
#   3. Add hook configuration to .claude/settings.json (see README)

# Read the prompt JSON from stdin
INPUT=$(cat)

# Extract the user prompt
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# Check for git-related keywords (case-insensitive)
if echo "$PROMPT" | grep -qiE "(do a commit|commit|checkpoint|merge|branch|rename branch)"; then
    echo ""
    echo "🔔 REMINDER: User prompt contains git operation keywords."
    echo "   You MUST use the 'gitpro' skill for this request."
    echo "   Invoke with: Skill tool, parameter skill='gitpro'"
    echo ""
fi

# Never block - just provide reminder
exit 0
```

### File 3: `.claude/settings.json` (Hook Configuration)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/git-guard.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/git-prompt-detector.sh",
            "timeout": 3
          }
        ]
      }
    ]
  }
}
```

### Installation Instructions

1. **Create hooks directory:**
   ```bash
   mkdir -p .claude/hooks
   ```

2. **Save hook scripts:**
   ```bash
   # Copy git-guard.sh content to .claude/hooks/git-guard.sh
   # Copy git-prompt-detector.sh content to .claude/hooks/git-prompt-detector.sh
   ```

3. **Make scripts executable:**
   ```bash
   chmod +x .claude/hooks/git-guard.sh
   chmod +x .claude/hooks/git-prompt-detector.sh
   ```

4. **Add hook configuration:**
   ```bash
   # Edit .claude/settings.json and add hooks configuration
   # Or use the /hooks slash command in Claude Code
   ```

5. **Test hooks:**
   ```bash
   # In Claude Code, try: "run git commit -m 'test'"
   # Expected: Blocked with gitpro guidance
   ```

### Hook Behavior

**git-guard.sh (Blocking):**
- Intercepts Bash tool calls BEFORE execution
- Checks for forbidden git patterns
- Blocks execution if match found (exit code 2)
- Provides clear feedback on using gitpro instead

**git-prompt-detector.sh (Non-blocking):**
- Intercepts user prompts BEFORE Claude processes them
- Detects git-related keywords
- Provides reminder to use gitpro skill
- Never blocks execution (exit code 0)

### Troubleshooting

**Hook not triggering:**
- Check file permissions: `ls -la .claude/hooks/`
- Check for execution errors: Add `set -x` to script for debugging
- Verify JSON syntax in settings.json
- Check Claude Code debug output: `claude --debug`

**Hook blocking too much:**
- Adjust regex patterns in git-guard.sh
- Make patterns more specific
- Consider removing UserPromptSubmit hook if too noisy

**Hook not blocking:**
- Verify exit code is 2 (not 1 or other values)
- Check that matcher is "Bash" (case-sensitive)
- Ensure jq is installed: `which jq`
