# Changelog

All notable changes will be documented in this file.

We are not tracking these entries by version or function, but in chronological order. 
There should be a heading for each date '### July 2, 2025'
Within the day there can be sections headings for group related changes
This is not just a dummp of git comments! This is to document key changes, new features, functional improvements.
I don't care that you reorganized the documentation folder, it doesn't effect the function of the application!

### September 19, 2025

#### Major Project Structure Reorganization
- **Agent Configuration Restructure**: Moved all agent files from scattered `Agents/` subdirectories to organized `dot-Claude(Global)/Agents/` structure
- **AI Rules System**: Created comprehensive `AIRules/` directory with specialized configuration files:
  - `development-guidelines.md` - Implementation standards and code quality rules
  - `archon.md` - Archon MCP integration workflows and decision trees
  - `Playwright.md` - Browser automation guidelines
  - `bashtools.md` - Shell interaction tooling standards
  - `Documentation.md` - Agent documentation location standards
- **Command Framework**: Added structured command system in `dot-Claude(Global)/commands/` for standardized workflows
- **Specify Integration**: Implemented `.specify/` configuration with constitution, templates, and automation scripts
- **Global Configuration**: Added `dot-Claude(Global)/` with agent definitions, commands, and shared utilities
- **Project Commands**: Created `dot-Claude(Project)/commands/` for project-specific workflows

#### Configuration Enhancements
- **CLAUDE.md Simplification**: Streamlined main configuration file to focus on mandatory subagent usage
- **AGENTS.md Creation**: New centralized agent guidance file with comprehensive rule imports
- **Binary Tools**: Added `bin/cl` utility script for enhanced development workflow