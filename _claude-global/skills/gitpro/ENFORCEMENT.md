# GitPro Skill Enforcement

Claude doesn't always invoke skills when instructed. This hook physically blocks direct git commands to force skill usage.

## How It Works

**Three-tier enforcement:**
1. **Skill Description** - Claude sees gitpro is available
2. **CLAUDE.md/AGENTS.md** - Rules mandate gitpro usage
3. **PreToolUse Hook** - Blocks direct git commands (fallback when Claude ignores rules)

## Hook Location

`~/.claude/hooks/git-guard.sh`

Configured in `~/.claude/settings.json` under `PreToolUse` for both `Bash` and `mcp__acp__Bash` matchers.

## What Gets Blocked

| Command | Reason |
|---------|--------|
| `git add` | Use gitpro (handles staging) |
| `git commit` | Use gitpro (changelog, conventional commits) |
| `git push` | Use gitpro (auto-pushes after commit) |
| `git merge` | Use gitpro (version bump, tags) |
| `git checkout -b` | Use gitpro (branch creation) |
| `git switch -b` | Use gitpro (branch creation) |
| `git branch -m` | Use gitpro (branch rename) |
| `git reset` | Destructive - use Read/Edit/Write instead |
| `git restore` | Destructive - use Read/Edit/Write instead |
| `git revert` | Requires explicit user instruction |
| `git clean` | Requires explicit user instruction |
| `git checkout <file>` | Destructive - use Read/Edit/Write instead |

## What's Allowed (Read-Only)

- `git status`
- `git log`
- `git diff`
- `git show`
- `git branch` (listing)
- `git config`
- `git remote`
- `git tag` (listing)
- `git rev-parse`
- `git ls-files`
- `git describe`
- `git fetch`
- `git stash`
- `git reflog`
- `git checkout <branch>` (switching, not file revert)

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `SKIP_GIT_GUARD=1` | Emergency bypass (user sets manually) |
| `GITPRO_RUNNING=1` | Skill sets this so its own git commands pass |

## Emergency Override

If gitpro has a bug:

```bash
export SKIP_GIT_GUARD=1
git commit -m "emergency fix"
unset SKIP_GIT_GUARD
```

## Troubleshooting

1. Check hook exists: `ls -la ~/.claude/hooks/git-guard.sh`
2. Check executable: `chmod +x ~/.claude/hooks/git-guard.sh`
3. Check settings: `jq '.hooks.PreToolUse' ~/.claude/settings.json`
4. Restart Claude Code after changes

## Version

- v1.0 (2025-11-13): Initial implementation
- v1.1 (2025-12-25): Updated paths, added GITPRO_RUNNING, documented all blocked ops
