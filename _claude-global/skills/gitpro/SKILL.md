---
name: gitpro
description: ALWAYS use this skill for ALL git operations. NEVER run git commit, git add, git push, git merge, git checkout -b, or git branch -m directly. This skill automates git workflows with conventional commits, automatic changelog updates, semantic version bumping, and consistent formatting. Use when user requests checkpoint, commit, rename branch, merge, or create new branch operations.
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: ~/.claude/skills/gitpro/scripts/create-token.sh
          timeout: 5
---

# GitPro

Git workflow automation using scripts for atomic, efficient operations.

**Supports**: Node.js (package.json) and Python (pyproject.toml)

## Architecture

```
┌─────────────────────────────────────────┐
│ Claude Code PreToolUse hook (Skill)     │
│ - Validates TS, TODOs before gitpro     │
│ - Checkpoint operations skip validation │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ GitPro Skill (this file)                │
│ - AI analyzes changes                   │
│ - AI determines parameters              │
│ - AI calls script with parameters       │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ Bash Scripts (atomic execution)         │
│ - Handle beads sync                     │
│ - Use --no-verify (validation done)     │
│ - Single script = single operation      │
└─────────────────────────────────────────┘
```

## Quick Start

| User Says | Operation | Script |
|-----------|-----------|--------|
| "checkpoint" | Quick timestamped commit | `gitpro-checkpoint.sh` |
| "commit" | Full conventional commit | `gitpro-commit.sh` |
| "merge to main" | Merge + version bump + cleanup | `gitpro-merge.sh` |
| "merge from X" | Pull changes from branch | Manual (simple) |
| "rename branch" | Rename current branch | Via commit script |
| "new branch" | Create working branch | Manual (simple) |

## Core Operations

### Checkpoint

Fast timestamped commit without full analysis.

**AI Steps:**
1. Determine if user provided a custom message prefix
2. Call script

**Script Call:**
```bash
~/.claude/skills/gitpro/scripts/gitpro-checkpoint.sh [optional-message]
```

**Examples:**
- User: "checkpoint" → `gitpro-checkpoint.sh`
- User: "checkpoint with message Phase 1 complete" → `gitpro-checkpoint.sh "Phase 1 complete"`
- AI completing work: → `gitpro-checkpoint.sh "Refactored auth module"`

---

### Commit

Full conventional commit with changelog and optional branch rename.

**AI Steps:**
1. Run `git status` to see all changed/untracked files
2. Run `git diff --stat` to see actual changes per file (insertions/deletions)
3. **Categorize changes by feature/purpose:**
   - Group related files (e.g., all files for "image processing" vs "AI descriptions")
   - Identify distinct features/fixes being committed
   - Note: Changes may span multiple sessions - analyze ALL diffs, not just session memory
4. Load reference files:
   - `~/.claude/skills/gitpro/references/commit-types.md` - emoji/type mapping
   - `~/.claude/skills/gitpro/references/changelog-rules.md` - what goes in changelog
5. **Build commit message:**
   - If single feature: `<emoji> <type>: <description>`
   - If multiple features: Multi-line with primary type, then bullet list
6. **Build changelog entry:**
   - List ALL user-facing features/fixes (see changelog-rules.md)
   - Exclude refactors, tests, docs, style changes
7. Determine branch rename if current is `wt-*`
8. Call script with parameters

**Script Call:**
```bash
~/.claude/skills/gitpro/scripts/gitpro-commit.sh \
  --message "✨ feat: add user authentication" \
  --old-branch "wt-petehalsted" \
  --new-branch "add-user-auth" \
  --changelog "- **✨ Add User Authentication** - JWT-based auth with refresh tokens"
```

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `--message` | Yes | Full commit message with emoji and type |
| `--old-branch` | No | Current wt-* branch name (for rename) |
| `--new-branch` | No | New descriptive branch name |
| `--changelog` | No | Changelog entry text (if changelog.md exists) |

**What Script Does:**
- Beads sync (pre-commit)
- Stage all changes
- Rename branch (if --old-branch/--new-branch provided)
- Update changelog (if --changelog provided)
- Commit with --no-verify
- Beads sync (post-commit)
- Push to remote (non-main branches)

**CRITICAL: Analyze ALL Changes**
- Do NOT rely on what you remember working on in this session
- Uncommitted changes may include work from previous sessions
- Always use `git diff --stat` to see the actual scope of changes
- If you see changes you don't recognize, they still need to be in the commit message/changelog

---

### Merge to Main

Full merge workflow with version bump and cleanup.

**AI Steps:**
1. Check for uncommitted changes - if any, do Commit workflow first
2. Get current branch name: `git branch --show-current`
3. Analyze commits to determine version bump type:
   ```bash
   git log --oneline main..HEAD
   ```
   - **major**: BREAKING CHANGE, ! after type
   - **minor**: feat:, ✨
   - **patch**: everything else
4. Get username via whoami command
5. Call script with parameters

**Script Call:**
```bash
~/.claude/skills/gitpro/scripts/gitpro-merge.sh \
  --source-branch "add-user-auth" \
  --bump-type "minor" \
  --username "petehalsted"
```

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| `--source-branch` | Yes | Branch being merged to main |
| `--bump-type` | Yes | major, minor, or patch |
| `--username` | Yes | For creating wt-{username} branch |

**What Script Does:**
- Push source branch
- Checkout main, pull
- Merge source branch
- Bump version, commit, tag
- Push main and tags (single push!)
- Delete merged source branch
- Create fresh wt-{username} branch

---

### Merge from Branch

Pull changes from another branch into current.

**AI Steps (no script needed):**
1. `git fetch origin`
2. `git merge origin/{branch}` or `git merge {branch}`
3. If conflicts: report and exit
4. If not main/master: ask user about deleting source branch

---

### New Branch

Create new working branch.

**AI Steps (no script needed):**
1. Check for uncommitted changes - offer to commit/checkpoint
2. `git checkout -b {name}` (default: `wt-$(whoami)`)
3. `git push -u origin {name}`

---

## Commit Types Reference

| Emoji | Type | Use For |
|-------|------|---------|
| ✨ | feat | New feature |
| 🐛 | fix | Bug fix |
| 📚 | docs | Documentation |
| 🎨 | style | Formatting |
| ♻️ | refactor | Refactoring |
| ⚡ | perf | Performance |
| 🧪 | test | Testing |
| 🔧 | chore | Maintenance |
| 🔖 | chore | Version bump (auto) |

## Validation

Validation happens in Claude Code `PreToolUse` hook BEFORE this skill runs:
- TypeScript errors (Node) → blocks gitpro (except checkpoint)
- Python lint/type errors (Python) → blocks gitpro (except checkpoint)
- Invalid TODOs → blocks gitpro (except checkpoint)
- Toast usage → warning only

Scripts use `--no-verify` because validation already passed.

## Scripts Location

All scripts in: `~/.claude/skills/gitpro/scripts/`

| Script | Purpose |
|--------|---------|
| `gitpro-checkpoint.sh` | Quick timestamped commit |
| `gitpro-commit.sh` | Full commit with changelog |
| `gitpro-merge.sh` | Merge to main workflow (Node + Python) |
| `gitpro-bump-python.py` | Python version bump helper |
| `create-token.sh` | Token for git-guard bypass |
| `get_timestamp.sh` | Local timezone timestamp |

## Project Type Detection

Merge script auto-detects project type:
- **Node.js**: `package.json` exists → uses `npm version`
- **Python**: `pyproject.toml` exists → uses `gitpro-bump-python.py`

Version format follows semver: `vX.Y.Z`
