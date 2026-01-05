# Claude Project Starter Kit

A developer workflow blueprint for AI-assisted development. This repository contains standardized configurations for Claude Code, Git hooks, development rules, and automation scripts that can be synced across multiple projects.

## What This Is

- **Blueprint Repository**: Defines your standard development setup and AI agent behaviors
- **Sync Source**: Central location for configurations that should be consistent across projects
- **Template Collection**: Starting points for project-specific files that get customized

## Quick Start

### First Time Setup (One Time)

```bash
# 1. Clone this starter kit
git clone https://github.com/youruser/claude-project-starter-kit.git

# 2. From the starter kit directory, run /sync-global in Claude Code
# This installs global config AND configures the sync system
cd claude-project-starter-kit
# Then in Claude Code: /sync-global
```

### For New/Existing Projects

From any project directory in Claude Code:
```
/sync-starter-kit
```

This command:
- Syncs `.claude/rules/` folder (creates if missing)
- Installs git hooks (makes executable)
- Checks for legacy files (warns if AGENTS.md or AIRules/ exist)

### Manual Setup (Alternative)

If you prefer manual control:

1. Copy `.claude/rules/` folder to your project
2. Copy `_git-hooks-project/` contents to `.git/hooks/` and `chmod +x`

## Folder Structure

| Folder | Destination | Purpose |
|--------|-------------|---------|
| `_claude-global/` | `~/.claude/` | Global Claude Code config (skills, hooks) |
| `_git-hooks-project/` | `project/.git/hooks/` | Git hooks (TypeScript validation, beads sync) |
| `_claude-project/rules/` | `project/.claude/rules/` | Rule templates (synced to native rules directory) |
| `project-documentation/` | `project/project-documentation/` | Documentation template structure |

## File Classification

Understanding which files sync vs which are templates is critical for the sync system:

### Core Files (Bi-Directional Sync)
These should be identical across all projects:
- `_claude-project/rules/*.md` - Rule templates (synced to `.claude/rules/`)
- `_claude-global/` - Global Claude config (skills, hooks)
- `_git-hooks-project/` - Git hooks

### Template Files (One-Way: Starter Kit to Project)
Starting points that get customized per project:
- `CLAUDE.md` - Optional project notes
- `_claude-project/rules/projectrules.md` - Project-specific rules template

### Project-Specific (Never Sync)
Files that exist only in real projects:
- `.env` files
- `package.json`, `node_modules/`
- Source code
- Active feature branches and work-in-progress

## Key Components

### Rules (Native .claude/rules/ Directory)

Claude Code's native rules system - all `.md` files auto-discovered, no imports needed.

| File | Purpose |
|------|---------|
| `constitution.md` | Global rules (naming, quality, security) |
| `development-guidelines.md` | Code quality, TypeScript, documentation |
| `git.md` | Git workflow rules (mandates gitpro skill) |
| `bashtools.md` | Shell tooling standards (fd, rg, ast-grep, jq) |
| `shadcn.md` | shadcn/ui component integration |
| `projectrules.md` | Project-specific rules template |
| `integrations/ref.md` | API/library doc lookup via Ref MCP |
| `integrations/exa.md` | Web research via Exa MCP |
| `integrations/ClaudeChrome.md` | Browser automation via Claude in Chrome |

**Path-targeting**: Rules can be scoped to specific files using YAML frontmatter:
```yaml
---
paths: src/api/**/*.ts
---
# These rules only apply when working on API files
```

See `project-documentation/path-targeting-rules.md` for details.

### Skills (Global Claude Capabilities)

Located in `_claude-global/skills/`:

| Skill | Purpose |
|-------|---------|
| `gitpro` | Git operations with conventional commits and changelog |

Additional skills (e.g., `frontend-design`) are installed via the Claude Code plugin marketplace. See `project-documentation/claude-code-setup.md`.

### Hooks (Safety Guards & Context Injection)

Located in `_claude-global/hooks/`:
- `git-guard.sh` - Blocks dangerous git commands (forces gitpro skill)
- `block-db-commands.sh` - Blocks Drizzle commands (requires human)
- `dev-server-guard.sh` - Prevents AI from starting/killing dev server
- `beads-inject.sh` - Injects beads workflow when `.beads/` exists
- `beads-workflow.md` - Custom beads workflow guide (replaces `bd prime`)

## Tech Stack Context

This starter kit is optimized for:
- **Language**: TypeScript
- **Frontend**: React, TanStack Start, shadcn/ui, TailwindCSS
- **Backend**: TanStack Start (unified) or Hono (separate API)
- **Database**: PostgreSQL (Neon DB), Drizzle ORM
- **Auth**: Clerk with RBAC (or BetterAuth)
- **Runtime**: Node.js (considering Bun)

Adjust the rules and constitution for your specific stack.

## Installation

For complete Claude Code installation, configuration, and plugin setup, see `project-documentation/claude-code-setup.md`.

### Global Setup (One Time)

From the starter kit directory in Claude Code:
```
/sync-global
```

This:
- Copies `_claude-global/*` to `~/.claude/` (hooks, skills, commands)
- Configures starter kit path for `/sync-starter-kit` command
- Installs the sync commands globally

Then install recommended plugins:
```
/plugin install frontend-design@claude-plugins-official
```

### Per-Project Setup

From any project directory in Claude Code:
```
/sync-starter-kit
```

## For AI Agents

This section provides context for Claude and other AI agents working on this repository.

**This is a meta-repository** - it defines configurations and rules for OTHER projects. When working here:

1. **You are editing templates** that will be copied to real projects
2. **Changes here propagate** to multiple projects via sync
3. **The constitution here** is a template - real projects may have customized versions
4. **Test changes carefully** - they affect all synced projects

**Key files to understand:**
- `_claude-project/rules/constitution.md` - Global rules (apply to all projects)
- `_claude-project/rules/projectrules.md` - Project-specific rules template
- `_claude-project/rules/*.md` - Individual behavior rule modules

**When adding new rules:**
1. Create new `.md` file in `_claude-project/rules/`
2. Consider if it needs path-targeting (see `project-documentation/path-targeting-rules.md`)
3. If MCP-dependent, add to MCP_RULES mapping in sync script
4. Rules auto-discover in projects after sync

## Sync System

Two commands keep projects in sync:

| Command | Run From | Direction | Purpose |
|---------|----------|-----------|---------|
| `/sync-global` | Starter kit | `~/.claude/` ↔ `_claude-global/` | Sync global Claude config |
| `/sync-starter-kit` | Any project | Starter kit → Project | Update project from kit |

**Key behaviors:**
- Interactive prompts before any changes
- Shows diffs for modified files
- Warns about legacy files (AGENTS.md, AIRules/)
- Recursive comparison of `.claude/rules/` including subdirectories

See `project-documentation/sync-system-planning.md` for technical details.

## Master Workflow (Maintainer Only)

When you improve rules in a real project and want to bring changes back to the starter kit:

```
# From the starter kit directory in Claude Code
/pull-from-project
```

This command:
- Only works from starter kit (checks for `.claude/master.txt`)
- Asks which project to pull from
- Compares project `.claude/rules/` with kit `.claude/rules/`
- Shows diffs, asks which files to pull
- Skips `projectrules.md` (always project-specific)

After pulling, run `/sync-global` to push updated rules to `~/.claude/`.

## Migration from Legacy Structure

If your project uses the old AGENTS.md/AIRules pattern:

1. Run `/sync-starter-kit` - it will warn about legacy files
2. Copy any custom rules from `AIRules/` to `.claude/rules/`
3. Delete `AGENTS.md` and `AIRules/` folder
4. Update `CLAUDE.md` to remove imports (rules auto-discover)

## Related Files

- `CLAUDE.md` - Minimal project entry point
- `.claude/rules/` - Native rules directory
- `changelog.md` - Change history for this starter kit
- `project-documentation/path-targeting-rules.md` - Path-specific rules guide
