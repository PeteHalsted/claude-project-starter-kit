# Claude Project Starter Kit

A developer workflow blueprint for AI-assisted development. This repository contains standardized configurations for Claude Code, Git hooks, development rules, and automation scripts that can be synced across multiple projects.

## What This Is

- **Blueprint Repository**: Defines your standard development setup and AI agent behaviors
- **Sync Source**: Central location for configurations that should be consistent across projects
- **Template Collection**: Starting points for project-specific files that get customized

## Quick Start

### For New Projects

1. Clone/copy this starter kit to reference
2. Copy the folders to their destinations (see Folder Structure below)
3. Customize template files (`AGENTS.md`, `constitution.md`) for your project
4. Update `AGENTS.md` imports to enable/disable rules for your project

### For Existing Projects

1. Copy `airules/` folder to your project root as `AIRules/`
2. Copy `_claude-project/` contents to your project's `.claude/` folder
3. Copy `_git-hooks/` contents to your project's `.git/hooks/` folder
4. Create `CLAUDE.md` and `AGENTS.md` in project root (use templates here)
5. Customize the imports in `AGENTS.md` for your needs

## Folder Structure

| Folder | Destination | Purpose |
|--------|-------------|---------|
| `_claude-global/` | `~/.claude/` | Global Claude Code config (skills, hooks, agents) |
| `_claude-project/` | `project/.claude/` | Project-specific Claude commands and settings |
| `_git-hooks/` | `project/.git/hooks/` | Git hooks (pre-commit, pre-merge) |
| `_specify/` | `project/.specify/` | Spec-kit framework (constitution, templates, scripts) |
| `airules/` | `project/AIRules/` | Modular AI behavior rules (imported via AGENTS.md) |
| `bin/` | `~/bin/` (add to PATH) | CLI utilities (cl for YOLO mode, etc.) |
| `project-documentation/` | `project/project-documentation/` | Documentation template structure |

## File Classification

Understanding which files sync vs which are templates is critical for the sync system:

### Core Files (Bi-Directional Sync)
These should be identical across all projects:
- `airules/*.md` - All AI behavior rules
- `bin/*` - CLI utilities
- `_claude-global/` - Global Claude config (skills, hooks, output styles)
- `_git-hooks/` - Git hooks

### Template Files (One-Way: Starter Kit to Project)
Starting points that get customized per project:
- `AGENTS.md` - Import list (toggle rules on/off per project)
- `CLAUDE.md` - Entry point (usually just imports AGENTS.md)
- `readme.md` - Project README structure
- `changelog.md` - Changelog format
- `_specify/memory/constitution.md` - Project rules and constraints
- `_claude-project/settings.local.json` - Project-specific settings

### Project-Specific (Never Sync)
Files that exist only in real projects:
- `.env` files
- `package.json`, `node_modules/`
- Source code
- Active `.specify/features/` directories

## Key Components

### AIRules (Modular Behavior Rules)

The `airules/` folder contains markdown files that define AI agent behavior. Enable/disable them via imports in `AGENTS.md`:

| File | Purpose |
|------|---------|
| `bashtools.md` | Shell tooling standards (fd, rg, ast-grep, jq) |
| `git.md` | Git workflow rules (mandates gitpro skill) |
| `development-guidelines.md` | Code quality, TypeScript, responsive design |
| `Documentation.md` | Where to store documentation |
| `ChromeDevTools.md` | Browser automation guidelines |
| `shadcn.md` | shadcn/ui component integration |
| `ref.md` | API/library doc lookup via Ref MCP |
| `exa.md` | Web research via Exa MCP |

### Skills (Global Claude Capabilities)

Located in `_claude-global/skills/`:

| Skill | Purpose |
|-------|---------|
| `gitpro` | Git operations with conventional commits and changelog |
| `systematic-debugging` | 4-phase debugging framework |
| `dispatching-parallel-agents` | Run concurrent subagents |
| `verification-before-completion` | Verify before claiming done |
| `frontend-design` | Production-grade UI development |

### Hooks (Safety Guards)

Located in `_claude-global/hooks/`:
- `git-guard.sh` - Blocks dangerous git commands (forces gitpro skill)
- `block-db-commands.sh` - Blocks Drizzle commands (requires human)

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

### Global Setup (One Time)

```bash
# Copy global Claude config
cp -r _claude-global/* ~/.claude/

# Add bin to PATH (add to ~/.zshrc)
export PATH="$HOME/bin:$PATH"

# Copy bin utilities
cp -r bin/* ~/bin/
```

### Per-Project Setup

```bash
# In your project root
cp -r /path/to/starter-kit/airules ./AIRules
cp -r /path/to/starter-kit/_claude-project/.  ./.claude/
cp -r /path/to/starter-kit/_git-hooks/* ./.git/hooks/
cp -r /path/to/starter-kit/_specify ./.specify

# Create entry point files
cp /path/to/starter-kit/CLAUDE.md ./CLAUDE.md
cp /path/to/starter-kit/AGENTS.md ./AGENTS.md

# Customize AGENTS.md imports for your project
```

## For AI Agents

This section provides context for Claude and other AI agents working on this repository.

**This is a meta-repository** - it defines configurations and rules for OTHER projects. When working here:

1. **You are editing templates** that will be copied to real projects
2. **Changes here propagate** to multiple projects via sync (Phase 2)
3. **The constitution here** is a template - real projects have customized versions
4. **Test changes carefully** - they affect all synced projects

**Key files to understand:**
- `AGENTS.md` - Central import hub for all AI rules
- `_specify/memory/constitution.md` - Base project rules template
- `airules/*.md` - Individual behavior rule modules

**When adding new rules:**
1. Create new `.md` file in `airules/`
2. Document the import line for `AGENTS.md`
3. Consider if it should be on by default or commented out

## Sync System (Phase 2 - Planned)

A sync system is being developed to:
- Pull changes from real projects into this starter kit
- Push updates to all registered projects
- Handle conflicts interactively
- Respect file classification (synced vs template)

See `project-documentation/sync-system-planning.md` for details.

## Related Files

- `CLAUDE.md` - Entry point, imports AGENTS.md
- `AGENTS.md` - Central hub for all AI rule imports
- `changelog.md` - Change history for this starter kit
