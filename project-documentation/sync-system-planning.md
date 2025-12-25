# Sync System Planning (Phase 2)

This document captures all context and decisions for building a sync system to keep the Claude Project Starter Kit in sync with multiple real projects.

## The Problem

Managing developer workflow configurations across multiple projects is challenging:

1. **Manual sync nightmare**: Currently copying files manually when setting up or updating projects
2. **Inconsistent updates**: Changes made in one project don't propagate to others
3. **Template vs synced confusion**: Some files should be identical everywhere, others are customized per project
4. **Two-way requirement**: Need to pull improvements from real projects back into the starter kit

## File Classification System

### Category 1: Core Files (Bi-Directional Sync)

These files should be identical across all projects. Changes flow both ways:
- Starter kit → all projects (push)
- Any project → starter kit → other projects (pull then push)

**Files:**
```
airules/*.md              # All AI behavior rules
bin/*                     # CLI utilities
_claude-global/           # Global Claude config (skills, hooks, output styles)
_git-hooks-project/               # Git hooks (pre-commit, pre-merge)
```

### Category 2: Template Files (One-Way: Starter Kit → Project)

Starting points that get customized per project. Only sync when explicitly requested or for new projects:

**Files:**
```
AGENTS.md                            # Import list - toggle rules per project
CLAUDE.md                            # Entry point
readme.md                            # README structure template
changelog.md                         # Changelog format template
_specify/memory/constitution.md      # Project rules template
_claude-project/settings.local.json  # Project-specific settings
```

### Category 3: Project-Specific (Never Sync)

Files that exist only in real projects, never in starter kit:
```
.env files
package.json, node_modules/
Source code (src/, app/, etc.)
.specify/features/*                  # Active feature directories
```

## Proposed Workflow

### Pull Workflow (Project → Starter Kit)

When you make a useful change in a real project:

```bash
# In the starter kit directory
kit-sync pull /path/to/project

# What happens:
# 1. Compares core files between project and starter kit
# 2. Shows diff for each changed file
# 3. Prompts: "Accept this change? [y/n/diff/skip]"
# 4. Updates starter kit with approved changes
```

### Push Workflow (Starter Kit → Projects)

After updating the starter kit:

```bash
# Push to a specific project
kit-sync push /path/to/project

# Push to all registered projects
kit-sync push --all

# What happens:
# 1. Compares core files between starter kit and project(s)
# 2. Shows diff for each changed file
# 3. Prompts: "Apply this change? [y/n/diff/skip]"
# 4. Updates project(s) with approved changes
```

### Project Registry

Maintain a list of projects that participate in sync:

```json
// ~/.kit-sync-registry.json
{
  "starterKit": "/Users/petehalsted/projects/claude-project-starter-kit",
  "projects": [
    {
      "path": "/Users/petehalsted/projects/mysite",
      "name": "mysite",
      "lastSync": "2025-12-25T06:00:00Z"
    },
    {
      "path": "/Users/petehalsted/projects/other-project",
      "name": "other-project",
      "lastSync": "2025-12-20T12:00:00Z"
    }
  ]
}
```

Commands:
```bash
kit-sync register /path/to/project    # Add project to registry
kit-sync unregister project-name      # Remove from registry
kit-sync list                         # Show all registered projects
kit-sync status                       # Show sync status for all projects
```

## Sync Manifest

Define what syncs where:

```json
// sync-manifest.json (in starter kit root)
{
  "version": "1.0",
  "core": {
    "biDirectional": true,
    "paths": [
      "airules/**/*.md",
      "bin/**/*",
      "_claude-global/**/*",
      "_git-hooks-project/**/*"
    ]
  },
  "templates": {
    "biDirectional": false,
    "onlyNewProjects": true,
    "paths": [
      "AGENTS.md",
      "CLAUDE.md",
      "readme.md",
      "changelog.md",
      "_specify/memory/constitution.md",
      "_claude-project/settings.local.json"
    ]
  },
  "ignore": [
    ".git/**",
    "node_modules/**",
    ".env*",
    "*.log",
    ".DS_Store"
  ]
}
```

## Implementation Considerations

### Conflict Resolution

When files differ, the sync tool should:

1. **Show clear diff**: Side-by-side comparison with highlighting
2. **Provide context**: Which file is newer, file sizes, etc.
3. **Offer options**:
   - Accept source version
   - Keep destination version
   - Manual merge (open in editor)
   - Skip this file
   - Skip all remaining

### Path Mapping

The folder names differ between starter kit and real projects:

| Starter Kit | Real Project |
|-------------|--------------|
| `airules/` | `AIRules/` |
| `_claude-global/` | `~/.claude/` |
| `_claude-project/` | `.claude/` |
| `_git-hooks-project/` | `.git/hooks/` |
| `_specify/` | `.specify/` |
| `_gemini/` | `.gemini/` |

The sync tool needs to handle these mappings.

### AI-Assisted Sync

Given the complexity and judgment required, consider:

1. **Diff analysis**: AI could analyze diffs and recommend which changes to accept
2. **Conflict resolution**: AI could suggest how to merge conflicting changes
3. **Change description**: AI could summarize what each change does

This might be implemented as a Claude Code skill that wraps the sync tool.

## Open Questions

1. **Git integration**: Should sync be git-aware? Check for uncommitted changes before syncing?

2. **Backup strategy**: Should we backup files before overwriting?

3. **Dry-run mode**: `kit-sync push --dry-run` to preview changes without applying?

4. **Selective sync**: Ability to sync only specific files/folders?

5. **Auto-sync hooks**: Should `kit-sync status` run automatically (e.g., on terminal open)?

6. **Cross-platform**: Windows compatibility if team members use Windows?

## Implementation Options

### Option A: Shell Script

- **Pros**: Simple, no dependencies, runs anywhere
- **Cons**: Limited UI, harder to implement complex diff logic

### Option B: Node.js CLI

- **Pros**: Better diff libraries, can use existing npm ecosystem
- **Cons**: Requires Node.js, more complex setup

### Option C: Claude Code Skill

- **Pros**: AI-assisted decisions, natural language interface
- **Cons**: Requires Claude Code running, slower

### Recommended Approach

Start with **Option A (Shell Script)** for core sync logic, then optionally wrap it with **Option C (Claude Code Skill)** for AI-assisted conflict resolution.

## Implemented: Global Claude Config Sync

### What's Done

The `_claude-global/` ↔ `~/.claude/` sync is **fully implemented** via a Claude Code command.

**Location**: `.claude/commands/sync-global.md`

**Invoke**: Run `/sync-global` from Claude Code while in the starter kit directory.

### Master Mode Detection

A file `.claude/master.txt` determines sync direction:

- **File exists** → MASTER MODE: Your `~/.claude/` is truth, kit gets updated
- **File missing** → CONSUMER MODE: Starter kit is truth, your global gets updated

The starter kit repo has this file, so running `/sync-global` here updates the kit from your global.

### Whitelist Approach (Critical Design Decision)

Instead of trying to exclude all the noise in `~/.claude/` (debug logs, project histories, caches, etc.), we use a **whitelist** of watched locations:

**Folders** (full recursive):
- `hooks/`
- `skills/`
- `Agents/` (if exists)
- `commands/` (if exists)

**Root files**:
- `settings.json`
- `statusline.sh`

This means:
1. New files added to watched folders are automatically detected
2. Runtime noise (projects/, debug/, plugins/, file-history/, etc.) is ignored
3. No need to update exclusion lists as Claude Code adds new cache directories

### How It Works

1. Command detects MASTER vs CONSUMER mode
2. Lists files from watched locations in both kit and global
3. Compares MD5 hashes to categorize: IDENTICAL, DIFFERS, MISSING_IN_GLOBAL, ONLY_IN_GLOBAL
4. For differing files, AI reads both versions and explains what changed
5. Proposes actions and waits for user approval
6. Updates files only after explicit "yes"

### Key Files

| File | Purpose |
|------|---------|
| `.claude/commands/sync-global.md` | The sync command prompt |
| `.claude/master.txt` | Mode detection marker (presence = master mode) |
| `_claude-global/` | Starter kit's copy of global config |

## Next Steps

### Immediate: Perfect the Starter Kit Folders

Before automating cross-project sync, ensure the starter kit folder structure is correct:

1. [ ] Audit `_claude-global/` - remove any files that shouldn't be synced (backup files, etc.)
2. [ ] Audit `airules/` - ensure all rules are current and useful
3. [ ] Audit `_claude-project/` - clean up commands and settings
4. [ ] Audit `_git-hooks-project/` - verify hooks are working
5. [ ] Audit `_specify/` - ensure templates are current

### Then: Cross-Project Sync

1. [ ] Create similar command for project-level sync (airules/, _git-hooks-project/, etc.)
2. [ ] Implement project registry
3. [ ] Build push/pull workflows
4. [ ] Handle path mappings (airules/ → AIRules/, etc.)

## Notes from Discovery Session

- Symlinks are fragile and not all tools respect them - avoid
- The modular AIRules import system (via AGENTS.md) enables per-project customization
- Two-way sync is critical - changes often originate in real projects
- Interactive prompts preferred over automatic decisions
- Registry is needed because not all projects should sync (some are one-offs)
- Current manual workflow: weekly/monthly attempts to freshen up starter kit, often falls behind

---

## Audit Progress Log

### Session: 2025-12-25

**Focus**: `airules/` folder audit (comparing with `mysite.nextagedesigns/AIRules/`)

#### Files Analyzed

| File | Status | Decision | Notes |
|------|--------|----------|-------|
| bashtools.md | ✅ IDENTICAL | Keep | No action needed |
| ChromeDevTools.md | ✅ IDENTICAL | PENDING | mysite has ClaudeChrome.md which is more comprehensive |
| development-guidelines.md | ✅ IDENTICAL | Keep | No action needed |
| Documentation.md | ✅ IDENTICAL | Keep | No action needed |
| exa.md | ✅ IDENTICAL | Keep | No action needed |
| git.md | ⚠️ DIFFERS | PENDING | mysite is newer (Dec 18), adds 2 lines about enforcement |
| ref.md | ✅ IDENTICAL | Keep | No action needed |
| shadcn.md | ✅ IDENTICAL | Keep | No action needed |

#### Files Only in mysite (Not in Starter Kit)

| File | Size | Decision | Recommendation |
|------|------|----------|----------------|
| beads.md | 11KB | PENDING | Issue tracker rules - project-specific or template? |
| ClaudeChrome.md | 7KB | PENDING | More comprehensive than ChromeDevTools.md - consider replacing |
| context7.md | 949B | SKIP | Alternative to Ref MCP - not used in starter kit |
| linear.md | 881B | SKIP | Project-specific (hardcoded project IDs) |
| Playwright.md | 903B | PENDING | Alternative browser automation - optional add? |

#### Decisions Made This Session

- [x] git.md - PULLED from mysite (adds enforcement docs)
- [x] ChromeDevTools.md - REMOVED, replaced by ClaudeChrome.md
- [x] ClaudeChrome.md - ADDED to starter kit
- [x] beads.md - ADDED to starter kit, commented out in AGENTS.md
- [x] Playwright.md - REMOVED from mysite (deprecated)
- [x] context7.md - REMOVED from mysite (deprecated)
- [x] linear.md - REMOVED from mysite (deprecated)

#### airules/ Audit Status: ✅ COMPLETE

Both folders now in sync. Starter kit has 9 files, mysite has 9 files (identical set).

---

## Session Notes

**User is driving** - Do not suggest next steps. User has the full plan in their head.

### Decision: Eliminate _specify/

**Rationale**: Opus 4.5 native plan mode has replaced the spec-kit workflow.

**Action taken**:
- Removed `_specify/` folder entirely from starter kit
- Moved `constitution.md` to `airules/constitution.md` (using mysite version)
- Updated AGENTS.md import path

**constitution.md status**: Needs review - currently contains mysite-specific content (NextAge Designs, TanStack Start, Clerk, etc.). Needs to be genericized for starter kit template use.
