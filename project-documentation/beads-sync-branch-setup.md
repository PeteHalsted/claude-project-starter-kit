# Beads Sync Branch Configuration

## Problem

When `sync.branch` is set to `main`, two issues occur:

1. **Worktree blocking**: Beads creates a worktree that locks `main`, causing `git checkout main` to fail during merge workflows
2. **Dual CI/CD triggers**: `bd sync` pushes to main, then gitpro merge also pushes to main = two pipeline runs

## Root Cause

Beads uses git worktrees to commit to the sync branch without switching your working directory. When sync.branch = main, the worktree locks main:

```
fatal: 'main' is already checked out at '/path/.git/beads-worktrees/main'
```

## Solution

Use a dedicated sync branch (not main):

```bash
# Set in database (takes effect immediately)
bd config set sync.branch beads-sync

# Also set in config.yaml (persists across clones)
# Edit .beads/config.yaml:
sync-branch: "beads-sync"
```

## Verification

```bash
# Check database setting
sqlite3 .beads/beads.db "SELECT value FROM config WHERE key='sync.branch';"
# Expected: beads-sync

# Check worktree
git worktree list
# Should show worktree on beads-sync, NOT main

# Check branch exists
git branch -a | grep beads-sync
```

## Migration Steps (for existing repos with sync.branch = main)

```bash
# 1. Check current config
bd config get sync.branch
sqlite3 .beads/beads.db "SELECT value FROM config WHERE key='sync.branch';"

# 2. If set to 'main', change it
bd config set sync.branch beads-sync

# 3. Update config.yaml for persistence across clones
# Edit .beads/config.yaml, add/change:
sync-branch: "beads-sync"

# 4. Remove old worktree if it exists
git worktree remove .git/beads-worktrees/main --force 2>/dev/null || true
git worktree prune

# 5. Run bd sync to create new worktree
bd sync

# 6. Verify
git worktree list
```

## Expected Behavior After Fix

| Operation | Branch | CI/CD Trigger |
|-----------|--------|---------------|
| `bd sync` | beads-sync | No |
| `gitpro merge` | main | Yes (once) |
| `git checkout main` | - | Works (no lock) |

## Reference

- Beads docs: https://github.com/steveyegge/beads/blob/main/docs/CONFIG.md
- Beads docs: https://github.com/steveyegge/beads/blob/main/docs/WORKTREES.md
- Beads docs: https://github.com/steveyegge/beads/blob/main/docs/PROTECTED_BRANCHES.md
