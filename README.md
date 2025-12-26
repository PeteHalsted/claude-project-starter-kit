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
- Syncs `AIRules/` folder (creates if missing)
- Installs git hooks (makes executable)
- Audits `CLAUDE.md` (warns if not minimal)
- Intelligently merges `AGENTS.md` (preserves your enabled/disabled choices)

### Manual Setup (Alternative)

If you prefer manual control:

1. Copy `airules/` folder to your project root as `AIRules/`
2. Copy `_git-hooks-project/` contents to `.git/hooks/` and `chmod +x`
3. Create minimal `CLAUDE.md` (just `@AGENTS.md` import)
4. Create `AGENTS.md` with imports for your project

## Folder Structure

| Folder | Destination | Purpose |
|--------|-------------|---------|
| `_claude-global/` | `~/.claude/` | Global Claude Code config (skills, hooks) |
| `_git-hooks-project/` | `project/.git/hooks/` | Git hooks (TypeScript validation, beads sync) |
| `airules/` | `project/AIRules/` | Modular AI behavior rules (imported via AGENTS.md) |
| `project-documentation/` | `project/project-documentation/` | Documentation template structure |

## File Classification

Understanding which files sync vs which are templates is critical for the sync system:

### Core Files (Bi-Directional Sync)
These should be identical across all projects:
- `airules/*.md` - All AI behavior rules
- `_claude-global/` - Global Claude config (skills, hooks, output styles)
- `_git-hooks-project/` - Git hooks

### Template Files (One-Way: Starter Kit to Project)
Starting points that get customized per project:
- `AGENTS.md` - Import list (toggle rules on/off per project)
- `CLAUDE.md` - Entry point (usually just imports AGENTS.md)
- `readme.md` - Project README structure
- `changelog.md` - Changelog format
- `airules/constitution.md` - Global rules
- `airules/projectrules.md` - Project-specific rules template

### Project-Specific (Never Sync)
Files that exist only in real projects:
- `.env` files
- `package.json`, `node_modules/`
- Source code
- Active feature branches and work-in-progress

## Key Components

### AIRules (Modular Behavior Rules)

The `airules/` folder contains markdown files that define AI agent behavior. Enable/disable them via imports in `AGENTS.md`:

| File | Purpose |
|------|---------|
| `bashtools.md` | Shell tooling standards (fd, rg, ast-grep, jq) |
| `git.md` | Git workflow rules (mandates gitpro skill) |
| `development-guidelines.md` | Code quality, TypeScript, documentation |
| `ClaudeChrome.md` | Browser automation via Claude in Chrome |
| `constitution.md` | Global rules (naming, quality, security) |
| `projectrules.md` | Project-specific rules template |
| `shadcn.md` | shadcn/ui component integration |
| `ref.md` | API/library doc lookup via Ref MCP |
| `exa.md` | Web research via Exa MCP |

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

See Quick Start above for what this does.

## For AI Agents

This section provides context for Claude and other AI agents working on this repository.

**This is a meta-repository** - it defines configurations and rules for OTHER projects. When working here:

1. **You are editing templates** that will be copied to real projects
2. **Changes here propagate** to multiple projects via sync (Phase 2)
3. **The constitution here** is a template - real projects have customized versions
4. **Test changes carefully** - they affect all synced projects

**Key files to understand:**
- `AGENTS.md` - Central import hub for all AI rules
- `airules/constitution.md` - Global rules (apply to all projects)
- `airules/projectrules.md` - Project-specific rules template
- `airules/*.md` - Individual behavior rule modules

**When adding new rules:**
1. Create new `.md` file in `airules/`
2. Document the import line for `AGENTS.md`
3. Consider if it should be on by default or commented out

## Sync System

Two commands keep projects in sync:

| Command | Run From | Direction | Purpose |
|---------|----------|-----------|---------|
| `/sync-global` | Starter kit | `~/.claude/` ↔ `_claude-global/` | Sync global Claude config |
| `/sync-starter-kit` | Any project | Starter kit → Project | Update project from kit |

**Key behaviors:**
- Interactive prompts before any changes
- Shows diffs for modified files
- Intelligent `AGENTS.md` merge (preserves your choices)
- Handles path mapping (`airules/` → `AIRules/`)

See `project-documentation/sync-system-planning.md` for technical details.

## Master Workflow (Maintainer Only)

When you improve AIRules in a real project and want to bring changes back to the starter kit:

```
# From the starter kit directory in Claude Code
/pull-from-project
```

This command:
- Only works from starter kit (checks for `.claude/master.txt`)
- Asks which project to pull from
- Compares project `AIRules/` with kit `airules/`
- Shows diffs, asks which files to pull
- Skips `projectrules.md` (always project-specific)
- Reminds to update `AGENTS.md` template for new imports

After pulling, run `/sync-global` to push updated rules to `~/.claude/`.

## Related Files

- `CLAUDE.md` - Entry point, imports AGENTS.md
- `AGENTS.md` - Central hub for all AI rule imports
- `changelog.md` - Change history for this starter kit
