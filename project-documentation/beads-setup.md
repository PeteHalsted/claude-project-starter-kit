# Beads Install and Setup

This document describes how our team installs and uses **Beads (`bd`)** with **Claude Code** locally. It assumes macOS or Linux with Homebrew.

---

## 1. Install `bd` via Homebrew

Run once per machine:

```bash
# Add the Beads tap (if needed)
brew tap steveyegge/beads

# Install the Beads CLI
brew install bd
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

# Choose one initialization mode:
bd init                # default
# bd init --team         # team/branch workflow
# bd init --contributor  # OSS fork workflow
```

What this does:

- Creates `.beads/` with the SQLite cache and JSONL issue store
- Offers to install git hooks and configure the merge driver (say **yes**)

Run a health check at any time:

```bash
bd doctor
```

Commit the metadata:

```bash
git add .beads
git commit -m "Initialize Beads issue tracker"
```

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
| `~/.claude/settings.json` | Hook configuration |

### Why Custom Hooks Instead of `bd prime`

- **Full control** over workflow guidance
- **No upstream surprises** when beads updates
- **Custom label workflow** (coding → needs-testing → tested-local → deployed)
- **AI autonomy boundaries** (what AI can/cannot close)
- **Single source of truth** for our team's workflow

---

## 4. Opting Out of Beads

To disable beads integration for a user:

1. Edit `~/.claude/settings.json`
2. Remove or comment out the `beads-inject.sh` hooks from `PreCompact` and `SessionStart`

```json
"PreCompact": [],
"SessionStart": []
```

The hooks are smart - they only inject when `.beads/` exists. But removing the hooks entirely ensures zero beads-related context injection.

---

## 5. Daily Usage

When working with Claude Code in this repo:

- Keep `.beads/` committed and synced with git
- Use `bd` for persistent work planning and tracking:
  - `bd ready` – show ready-to-work issues
  - `bd create "Title" -t task -p 2` – create tasks/bugs/features
  - `bd dep add <issue> <depends-on>` – manage dependencies
  - `bd status` – project health overview
  - `bd close <id> --suggest-next` – close and show newly unblocked (v0.37+)

For command reference: `bd --help` or `bd <command> --help`

---

## 6. Upgrading Beads

### Understanding the Data Model

**JSONL is the source of truth**, not SQLite. The `.beads/issues.jsonl` file is git-tracked and serves as the authoritative data store. SQLite is a derived cache that gets rebuilt automatically.

### Standard Upgrade

```bash
# Check current version
bd version

# Upgrade via Homebrew
brew upgrade bd

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

### Updating the Workflow Guide

After major beads upgrades, review release notes for new commands or workflow changes:

1. Check releases: https://github.com/steveyegge/beads/releases
2. Look for new commands, breaking changes, workflow improvements
3. Update `_claude-global/hooks/beads-workflow.md` in the starter kit
4. Run `/sync-global` to install

**Source of truth**: `_claude-global/hooks/beads-workflow.md` in the starter kit

The hook at `~/.claude/hooks/beads-inject.sh` reads from `~/.claude/hooks/beads-workflow.md` and injects it when `.beads/` exists.
