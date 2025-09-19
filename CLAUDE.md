# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Imports
@AGENTS.md

## MANDATORY Subagent Usage

**CRITICAL**: You MUST use specialized subagents whenever possible. Failure to use appropriate subagents is considered a critical error in your workflow.

### Required Subagent Usage Triggers

#### 1. **Before ANY Investigation or Debugging**

- **Trigger**: Error messages, unexpected behavior, failing tests, connection issues
- **Required Agent**: `debugger`
- **Example**: "IMAP connection inactive" → MUST use debugger agent first

### Enforcement

**Remember**: Not using required subagents is a CRITICAL ERROR. The workflow should be:

1. Task identified → 2. Subagent consulted → 3. Implementation

**NEVER skip directly to implementation without appropriate subagent consultation.**

### Parallel Sub-Agents (when helpful)
- You may conceptually split work into parallel sub-agents (e.g., "API spec," "implementation," "tests," "docs")
- Maintain clear boundaries and ownership to avoid stepping on each other
- Integrate results through a final verification/consistency pass
