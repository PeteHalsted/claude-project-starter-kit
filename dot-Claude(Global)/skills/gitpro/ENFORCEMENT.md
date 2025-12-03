# GitPro Skill Enforcement Documentation

This document explains the complete enforcement system for the gitpro skill.

## Overview

The gitpro skill uses a **three-tier enforcement system**:

1. **Skill Description** - Improves discovery probability
2. **CLAUDE.md Instructions** - Provides clear mandatory usage rules  
3. **PreToolUse Hook** - Physically blocks direct git commands

## Files Modified/Created

### Global Files (Apply to All Projects)

1. `~/.claude-code/hooks/git-guard.sh` - Hook script that blocks git commands
2. `~/.claude/settings.json` - Activates the git-guard hook
3. `~/.claude/skills/gitpro/SKILL.md` - Enhanced description emphasizing mandatory usage
4. `~/.claude/skills/gitpro/ENFORCEMENT.md` - This documentation

### Project Files (Per-Project)

1. `CLAUDE.md` - Add ABSOLUTE RULE section for gitpro mandatory usage

## Hook Configuration

The git-guard hook is configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "~/.claude-code/hooks/git-guard.sh",
          "timeout": 5
        }]
      },
      {
        "matcher": "mcp__acp__Bash",
        "hooks": [{
          "type": "command",
          "command": "~/.claude-code/hooks/git-guard.sh",
          "timeout": 5
        }]
      }
    ]
  }
}
```

## Emergency Override

If gitpro has a bug and you need to bypass:

```bash
export SKIP_GIT_GUARD=1
git commit -m "emergency fix"
unset SKIP_GIT_GUARD
```

## Testing

### Test 1: Direct git commit (should block)
Try: `git commit -m "test"`
Expected: Hook denial message

### Test 2: Git status (should allow)
Try: `git status`
Expected: Command executes normally

### Test 3: Gitpro skill (should work)
User says: "do a commit"
Expected: Claude invokes gitpro skill successfully

## Troubleshooting

If hook not working:
1. Check file exists: `ls -la ~/.claude-code/hooks/git-guard.sh`
2. Check executable: `chmod +x ~/.claude-code/hooks/git-guard.sh`
3. Check settings: `cat ~/.claude/settings.json`
4. Restart Claude Code

## Version

v1.0 (2025-11-13): Initial implementation
