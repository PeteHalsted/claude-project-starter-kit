# Beads Install and Setup

This document describes how our team installs and uses **Beads (`bd`)** with **Claude Code** locally. It assumes macOS or Linux with Homebrew.

---

## 1. Install `bd` via Homebrew

Run once per machine:

```bash
brew install beads
```

Verify the install:

```bash
bd version
```

---

## 2. Initialize Beads in a repository

Run in each project repo (once per clone):

```bash
cd /path/to/repo

# Skip hooks - we use our own Claude Code integration (see Section 3)
bd init --skip-hooks
```

What this does:

- Creates `.beads/` with the SQLite cache and JSONL issue store
- Skips beads' built-in Claude Code hooks (we use custom ones)

**Important:** After init, you MUST configure the sync branch and db path. See Section 2.1.

Run a health check at any time:

```bash
bd doctor
```

---

### 2.1 Required Post-Init Configuration

The `bd init` command does NOT properly set up sync-branch or db path. You must do this manually.

#### Edit `.beads/config.yaml`

Add these two settings (replace `/path/to/repo` with your actual path):

```yaml
# IMPORTANT: Hardcoded to lowercase path to prevent case mismatch on macOS
db: "/path/to/repo/.beads/beads.db"

# IMPORTANT: Use dedicated sync branch, NOT main (prevents worktree blocking)
sync-branch: "beads-sync"
```

#### Set sync.branch in database

```bash
bd config set sync.branch beads-sync
```

#### Run initial sync

```bash
bd sync
```

#### Verify worktree is correct

```bash
git worktree list
# Should show: .git/beads-worktrees/beads-sync  [beads-sync]
# Should NOT show main in worktrees
```

#### Commit the setup

```bash
git add .beads .gitattributes AGENTS.md
git commit -m "Initialize Beads issue tracker"
```

### Why These Steps Matter

1. **Hardcoded db path**: macOS has case-insensitive filesystem. Without explicit lowercase path, beads can create duplicate databases with different casing.

2. **sync-branch in config.yaml**: The `bd config set` command only sets it in the SQLite database (which is gitignored). Setting it in config.yaml ensures all clones use the same sync branch.

3. **beads-sync branch**: Using `main` as sync branch causes worktree to lock main, breaking `git checkout main` during merge workflows.

---

## 3. Claude Code Integration (Hook-Based)

Our starter kit uses **custom hooks** instead of `bd prime` for Claude Code integration.

### How It Works

The `~/.claude/settings.json` includes hooks that:
1. Run on **SessionStart** and **PreCompact** (context recovery)
2. Check if `.beads/` directory exists in the current project
3. If beads is installed, inject the workflow guide from `~/.claude/hooks/beads-workflow.md`

### Files Involved

| File | Purpose |
|------|---------|
| `~/.claude/hooks/beads-inject.sh` | Checks for `.beads`, outputs workflow if found |
| `~/.claude/hooks/beads-workflow.md` | Custom workflow guide (our version, not `bd prime`) |
| `~/.claude/skills/beads/SKILL.md` | Full command reference, invoked on demand |
| `~/.claude/settings.json` | Hook configuration |

### Why Custom Hooks Instead of `bd prime`

- **Full control** over workflow guidance
- **No upstream surprises** when beads updates
- **Custom label workflow** (coding -> needs-testing -> tested-local -> deployed)
- **AI autonomy boundaries** (what AI can/cannot close)
- **Single source of truth** for our team's workflow

---

## 4. Sync Branch Configuration

### Problem

When `sync.branch` is set to `main`, two issues occur:

1. **Worktree blocking**: Beads creates a worktree that locks `main`, causing `git checkout main` to fail during merge workflows
2. **Dual CI/CD triggers**: `bd sync` pushes to main, then gitpro merge also pushes to main = two pipeline runs

### Root Cause

Beads uses git worktrees to commit to the sync branch without switching your working directory. When sync.branch = main, the worktree locks main:

```
fatal: 'main' is already checked out at '/path/.git/beads-worktrees/main'
```

### Solution

Use a dedicated sync branch (not main). See Section 2.1 for full setup.

**Quick fix for existing repos:**

```bash
# Set in database (takes effect immediately)
bd config set sync.branch beads-sync

# Also set in config.yaml (persists across clones)
# Edit .beads/config.yaml:
sync-branch: "beads-sync"
```

### Verification

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

### Migration Steps (for existing repos with sync.branch = main)

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

### Expected Behavior After Fix

| Operation | Branch | CI/CD Trigger |
|-----------|--------|---------------|
| `bd sync` | beads-sync | No |
| `gitpro merge` | main | Yes (once) |
| `git checkout main` | - | Works (no lock) |

---

## 5. Opting Out of Beads

To disable beads integration for a user:

1. Edit `~/.claude/settings.json`
2. Remove or comment out the `beads-inject.sh` hooks from `PreCompact` and `SessionStart`

```json
"PreCompact": [],
"SessionStart": []
```

The hooks are smart - they only inject when `.beads/` exists. But removing the hooks entirely ensures zero beads-related context injection.

---

## 6. Daily Usage

When working with Claude Code in this repo:

- Keep `.beads/` committed and synced with git
- Use `bd` for persistent work planning and tracking:
  - `bd list` - show non-closed issues (open + in_progress, limit 50)
  - `bd ready` - show ready-to-work issues (unblocked)
  - `bd create "Title" -t task -p 2 --notes "Context"` - create with notes
  - `bd dep add <issue> --blocked-by <other>` - manage dependencies
  - `bd status` - project health overview
  - `bd close <id> --suggest-next` - close and show newly unblocked

For command reference: `bd --help` or `bd <command> --help`

---

## 7. Upgrading Beads

### Understanding the Data Model

**JSONL is the source of truth**, not SQLite. The `.beads/issues.jsonl` file is git-tracked and serves as the authoritative data store. SQLite is a derived cache that gets rebuilt automatically.

### Standard Upgrade

```bash
# Check current version
bd version

# Upgrade via Homebrew
brew upgrade beads

# Trigger any pending migrations (any command works)
bd list --json
```

### If Something Breaks

If the upgrade causes database issues, reimport from JSONL:

```bash
# Backup existing DB (optional)
for f in .beads/*.db; do mv "$f" "$f.backup"; done

# Reinitialize and import from git-tracked JSONL
bd init
bd import -i .beads/issues.jsonl
```

### Auto-Recovery Behavior

Beads auto-imports from JSONL when it detects the JSONL is newer than the DB (e.g., after `git pull`). This provides built-in resilience during upgrades.

### Updating Workflow Guidance

After major beads upgrades, review release notes for new commands or workflow changes:

1. Check releases: https://github.com/steveyegge/beads/releases
2. Run `/beads-update` slash command to get changelog summary
3. Update `_claude-global/hooks/beads-workflow.md` if needed
4. Update `_claude-global/skills/beads/SKILL.md` if needed
5. Run `/sync-global` to install

**Source of truth**: `_claude-global/` files in the starter kit

---

## 8. Reference

- Beads docs: https://github.com/steveyegge/beads/blob/main/docs/CONFIG.md
- Beads docs: https://github.com/steveyegge/beads/blob/main/docs/WORKTREES.md
- Beads docs: https://github.com/steveyegge/beads/blob/main/docs/PROTECTED_BRANCHES.md
- Releases: https://github.com/steveyegge/beads/releases
