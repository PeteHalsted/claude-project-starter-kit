# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: First Steps for New Claude Code Instances

1. Read Serena Inital Instructions

2. **At the start of each session, read project documentation in this order:**
   - This CLAUDE.md file (you're reading it now)
   - Readme files for up-to-date project information,basic tech stack, commom commands, enviroment requirements
     - ** Any `**/README.md` docs across the project
     - ** Any `**/README.*.md` docs across the project
   - `project-documentation\developmentguidelines.md` for development principles
   - `project-documentation\projectstructure.md` for project folder structure, file naming conventions, basic architechure

   *** IMPORTANT YOU MUST FOLLOW ALL RULES IN ANY OF THE ABOVE FILES AT ALL TIMES ***

3. ** Before making ANY changes:**
   - Review `README.md` for up-to-date project information,basic tech stack, commom commands, enviroment requirements
   - Review `project-documentation\developmentguidelines.md` for development principles
   - Review `project-documentation\projectstructure.md` for project folder structure, file naming conventions, basic architechure

    **_Most Up-to-Date Project Information_**

    To find the most up-to-date project information, review the README.md file in the root of the project. This file is updated continuously during development and is likely more up-to-date on the overall structure than this CLAUDE.md file  ***ALWAYS*** follow the rules and instructions in all, but if there is a conflict or project information is unclear, trust the README.md file or ask the user for help!

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


## 📄 Agent Documentation Standards

When creating any document, agents must decide the location based on the following priority:

1. **Follow specific instructions** in the agent’s own file, prompt, or user request.
2. **Special files** — `Changelog.md`, `README.md`, `README.*.md`, and `claude.md` — must follow their predefined location rules.
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
- NEVER run the dev servers, as the user to, he likely has them running, and if you run them it will block ports and cause issues	


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

### Linear Integration Policy

**IMPORTANT**: When creating Linear issues for this codebase:

- **Project Association**: ALL issues related to this codebase MUST be associated with the "mysite.nextagedesigns" project
- **Project ID**: `237d3c83-4e70-418d-bb16-08d51c135e8e`
- **Team**: Nextage (ID: `5a4aca93-64c4-433e-9827-ec4ac97b76f5`)

**When creating issues via Linear MCP:**
Always include the project parameter:
```
project: "mysite.nextagedesigns"
```

**When moving items to Linear backlog:**
- When the user requests to "move to Linear backlog" or similar, ALWAYS:
  1. Create the Linear issue(s) with appropriate details
  2. Remove the corresponding sections from the planning/documentation files
  3. This prevents duplication and ensures Linear is the single source of truth for backlog items

This ensures all issues are properly tracked within the project context.


