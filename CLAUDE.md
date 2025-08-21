# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: First Steps for New Claude Code Instances

1. Read Serena Initial Instructions

2. **At the start of each session, read project documentation in this order:**
   - This CLAUDE.md file (you're reading it now)
   - `README.md` for essential project overview, quick start, and core commands
   - `coding-standards.md` for development principles

   *** IMPORTANT YOU MUST FOLLOW ALL RULES IN ANY OF THE ABOVE FILES AT ALL TIMES ***

**Most Up-to-Date Project Information:**

The README.md file contains the most current project information and is updated continuously during development. If there is a conflict or project information is unclear, trust the README.md file or ask the user for help!

## MANDATORY Subagent Usage

**CRITICAL**: You MUST use specialized subagents whenever possible. Failure to use appropriate subagents is considered a critical error in your workflow.

### Required Subagent Usage Triggers

#### 1. **Before ANY Investigation or Debugging**

- **Trigger**: Error messages, unexpected behavior, failing tests, connection issues
- **Required Agent**: `debugger`
- **Example**: "IMAP connection inactive" → MUST use debugger agent first

#### 2. **After Writing or Modifying ANY Code**

- **Trigger**: Any use of Edit, MultiEdit, Write, or code generation
- **Required Agent**: `code-reviewer`
- **Example**: After fixing error handling → MUST use code-reviewer agent

### Enforcement

**Remember**: Not using required subagents is a CRITICAL ERROR. The workflow should be:

1. Task identified → 2. Subagent consulted → 3. Implementation → 4. Review

**NEVER skip directly to implementation without appropriate subagent consultation.**

### Parallel Sub-Agents (when helpful)
- You may conceptually split work into parallel sub-agents (e.g., "API spec," "implementation," "tests," "docs")
- Maintain clear boundaries and ownership to avoid stepping on each other
- Integrate results through a final verification/consistency pass

## 📄 Agent Documentation Standards

When creating any document, agents must decide the location based on the following priority:

1. **Follow specific instructions** in the agent’s own file, prompt, or user request.
2. **Special files** — `Changelog.md`, `README.md`, and `claude.md` — must follow their predefined location rules.
3. **Temporary documents** (disposable when work is complete) go in `project-documentation\temporary`. Examples:
    - Implementation/migration plans
    - Task breakdowns
    - Investigation/analysis reports
    - Implementation strategies
4. **Permanent documentation** goes in `project-documentation`.
    - Check existing subfolders for a suitable location.
    - If none fits, create a new subfolder or place it in the root of `project-documentation`.

**Temporary File Naming Conventions:**

- Be descriptive; include timestamps if needed.
- Include generating agent type if relevant.
- Examples:
    - `sse-migration-plan-frontend-developer.md`
    - `debug-analysis-imap-connection-debugger.md`

### MUST FOLLOW RULES
- NEVER run the dev servers, ask the user to

### Context7 Workflow Policy

**For library documentation and integration questions:**

- For ALL questions about library APIs, usage, upgrades, or integration, you MUST fetch and reference official documentation using Context7
- Whenever asked about a library, ALWAYS include "use context7" at the end of your prompt to request the most up-to-date docs and code examples
- If using a Model Context Protocol (MCP) server with Context7, you MUST call `resolve-library-id` for the library name first, then use `get-library-docs` to pull in current documentation
- Never rely only on prior model training or guesses—defer to the retrieved Context7 documentation for accuracy

**Examples:**

- ✅ Good: `How do I add schema validation with Zod in Express? use context7`
- ❌ Not allowed: Answers about a library without referencing up-to-date docs from Context7
- If multiple libraries are involved, repeat the above steps for each before answering

## Project-Specific Rules
