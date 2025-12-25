# Changelog

All notable changes to the Claude Project Starter Kit will be documented here.

## Format Guide

- Entries are organized chronologically by date: `### Month Day, Year`
- Group related changes under section headings: `#### Section Name`
- Focus on key changes, new features, and functional improvements
- This is NOT a dump of git commits - document meaningful changes only

---

### December 25, 2025

#### Folder Naming Convention Overhaul
- **Underscore Prefix Convention**: Renamed all "dot-" folders to use underscore prefix for cleaner naming:
  - `dot-Claude(Global)` → `_claude-global`
  - `dot-Claude(Project)` → `_claude-project`
  - `dot-git-hooks(Project)` → `_git-hooks`
  - `dot-specify(Project)` → `_specify`
  - `dot-gemini(Project)` → `_gemini`
  - `AIRules` → `airules`
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
