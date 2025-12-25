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
_git-hooks/               # Git hooks (pre-commit, pre-merge)
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
      "_git-hooks/**/*"
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
| `_git-hooks/` | `.git/hooks/` |
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

## Next Steps for Phase 2

1. [ ] Create `sync-manifest.json` with file classifications
2. [ ] Build `kit-sync` shell script with basic commands
3. [ ] Implement registry file and management commands
4. [ ] Add conflict resolution prompts
5. [ ] Test with 2-3 real projects
6. [ ] Document usage in README
7. [ ] Optional: Create Claude Code skill wrapper

## Notes from Discovery Session

- Symlinks are fragile and not all tools respect them - avoid
- The modular AIRules import system (via AGENTS.md) enables per-project customization
- Two-way sync is critical - changes often originate in real projects
- Interactive prompts preferred over automatic decisions
- Registry is needed because not all projects should sync (some are one-offs)
- Current manual workflow: weekly/monthly attempts to freshen up starter kit, often falls behind
