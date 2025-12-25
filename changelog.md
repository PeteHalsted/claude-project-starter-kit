# Changelog

All notable changes to the Claude Project Starter Kit will be documented here.

## Format Guide

- Entries are organized chronologically by date: `### Month Day, Year`
- Group related changes under section headings: `#### Section Name`
- Focus on key changes, new features, and functional improvements
- This is NOT a dump of git commits - document meaningful changes only

---

### December 25, 2025

#### AIRules System Restructure
- **Constitution/Projectrules Split**: Separated global enforcement rules (constitution.md) from project-specific rules (projectrules.md)
- **Development Guidelines Cleanup**: Consolidated documentation standards, removed duplicates, demoted "MUST" language to guidance
- **Import Order Optimization**: Reordered AGENTS.md imports for LLM recency bias - constitution.md now loads last
- **New Console.log Hook**: `block-console-log.sh` blocks console.log in Adze projects (PreToolUse on Edit/Write)
- **Folder Rename**: `_git-hooks/` → `_git-hooks-project/` for naming consistency
- **Removed**: `_specify/` folder (replaced by Opus 4.5 plan mode), `Documentation.md` (merged into dev-guidelines)
- **Added**: `beads.md` (issue tracking), `ClaudeChrome.md` (browser automation), `projectrules.md` (template)
- **Header Comments**: Added "what belongs here" comments to constitution, dev-guidelines, projectrules
- **TypeScript Enforcement**: Zero tolerance via pre-commit hook, removed manifest system from gitpro skill

#### Complete Sync System
- **`/sync-global` Command**: Sync between `_claude-global/` and `~/.claude/`
  - Master mode detection via `.claude/master.txt`
  - Whitelist approach for watched folders/files
  - Executable bash script at `.claude/scripts/sync-global.sh`
- **`/sync-starter-kit` Command**: Sync starter kit → any project
  - Syncs AIRules/, git hooks, audits CLAUDE.md/AGENTS.md
  - Path mapping: `airules/` → `AIRules/`, `_git-hooks-project/` → `.git/hooks/`
  - Intelligent AGENTS.md merge (preserves enabled/disabled state)
  - Executable bash script at `~/.claude/scripts/sync-starter-kit.sh`
- **`/pull-from-project` Command**: Pull project changes → starter kit (master only)
  - Compares project AIRules/ with kit airules/
  - Shows diffs, asks which files to pull
- **README**: Added Master Workflow section documenting maintainer commands
- **Hooks Fix**: Made `architect_enforcer.sh` resilient to missing transcript

#### Global Config Cleanup
- **Removed Unused Skills**: Deleted skills no longer in use:
  - dispatching-parallel-agents, feature-documentation-cleanup, frontend-design
  - receiving-code-review, requesting-code-review, root-cause-tracing
  - skill-creator, subagent-driven-development, systematic-debugging, verification-before-completion
- **Removed Output Styles**: Deleted CriticalReview.md, task-adaptive.md
- **Removed Agents**: Deleted code-reviewer.md agent
- **Removed Commands**: Deleted code-review.md command
- **Cleaned GitPro**: Removed backup files and analysis document, updated ENFORCEMENT.md

#### New Hooks
- **architect_enforcer.sh**: UserPromptSubmit hook for principal engineer persona
- **dev-server-guard.sh**: Prevents AI from starting/killing dev server

#### Settings Updates
- Added `typescript-lsp@claude-plugins-official` plugin

---

#### Folder Naming Convention Overhaul
- **Underscore Prefix Convention**: Renamed all "dot-" folders to use underscore prefix for cleaner naming:
  - `dot-Claude(Global)` → `_claude-global`
  - `dot-Claude(Project)` → `_claude-project`
  - `dot-git-hooks(Project)` → `_git-hooks`
  - `dot-specify(Project)` → `_specify`
  - `AIRules` → `airules`
- **Removed Gemini Support**: Deleted `_gemini/` folder (no longer supporting Google Gemini CLI)
- **Typo Fix**: Corrected `project-documenation` → `project-documentation`

#### Documentation Restructure
- **README.md Rewrite**: Transformed from example project README to dual-purpose documentation that:
  - Documents the starter kit itself
  - Serves as a template for real projects
  - Includes file classification (synced vs template vs project-specific)
  - Has dedicated "For AI Agents" section
- **Changelog Format**: Established changelog as living document for this starter kit

#### AIRules Cleanup
- **Removed Obsolete Rules**: Deleted unused rule files:
  - `context7.md` (no longer used)
  - `linear.md` (no longer used)
  - `Playwright.md` (no longer used)
- **AGENTS.md Updates**: Updated all import paths to reflect new folder names

#### Sync System Planning
- **Phase 2 Planning Document**: Created `project-documentation/sync-system-planning.md` with:
  - File classification scheme (core/synced vs template vs project-specific)
  - Workflow design (pull from project → starter kit → push to others)
  - Registry concept for managing multiple projects
  - AI-assisted sync considerations

---

### September 19, 2025

#### Major Project Structure Reorganization
- **Agent Configuration Restructure**: Organized agent files into `dot-Claude(Global)/Agents/` structure
- **AI Rules System**: Created comprehensive `AIRules/` directory with specialized configuration files
- **Command Framework**: Added structured command system for standardized workflows
- **Specify Integration**: Implemented `.specify/` configuration with constitution, templates, and scripts
- **Global Configuration**: Added `dot-Claude(Global)/` with agent definitions, commands, and utilities
- **Project Commands**: Created `dot-Claude(Project)/commands/` for project-specific workflows

#### Configuration Enhancements
- **CLAUDE.md Simplification**: Streamlined to focus on importing AGENTS.md
- **AGENTS.md Creation**: Centralized agent guidance file with modular rule imports
- **Binary Tools**: Added `bin/cl` utility script for YOLO/SAFE mode toggling
