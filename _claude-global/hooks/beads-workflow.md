# Beads Workflow Guide

**IMPORTANT**: This project uses **bd (beads)** for persistent issue tracking. For command reference, run `bd --help` or `bd <command> --help`.

## Beads vs TodoWrite

| Tool | Use For |
|------|---------|
| **Beads** | Multi-session work, dependencies, discovered issues, anything that persists |
| **TodoWrite** | Single-session execution tracking, ephemeral task lists |

When in doubt, prefer beads - persistence you don't need beats lost context.

## Status = Quality Gates

Beads has 3 built-in status values:

- **`open`** - Brand new, untouched
- **`in_progress`** - Work has started
- **`closed`** - Deployed to production

**CRITICAL**: A bead is only closed when deployed to production.

## Labels = Workflow Stages

Labels track actual workflow progression:

**Workflow Labels:**
- **`coding`** - Actively being developed
- **`needs-testing`** - Code complete, ready for QA
- **`tested-local`** - QA passed, ready for deployment
- **`deployed`** - Live in production (also `status: closed`)

**Modifier Labels:**
- **`active-now`** - THE ONE thing being worked on RIGHT NOW (only 1 bead)
- **`tech-debt`** - AI cut corners, needs cleanup

## AI Agent Autonomy Boundaries

**AI can freely do:**
- Create beads: `bd create`
- Claim work: `bd update <id> --status in_progress`
- Add labels: `bd label add <id> coding`, `bd label add <id> active-now`
- Mark code complete: `bd label add <id> needs-testing`
  - Use language: "Implementation complete and ready for testing"

**AI MUST NEVER do without user direction:**
- Mark as tested: `bd label add <id> tested-local` - USER ONLY
- Mark as deployed: `bd label add <id> deployed` - USER ONLY
- Close beads: `bd close <id>` - USER ONLY

**Why**: User is QA. Only user verifies testing and deployment.

## Workflow Progression

```bash
# 1. Claim work and start coding
bd update nad-42 --status in_progress
bd label add nad-42 coding
bd label add nad-42 active-now

# 2. Code complete, ready for testing
bd label remove nad-42 active-now
bd label remove nad-42 coding
bd label add nad-42 needs-testing

# 3. [USER] Testing passed
bd label remove nad-42 needs-testing
bd label add nad-42 tested-local

# 4. [USER] Deployed to production
bd label remove nad-42 tested-local
bd label add nad-42 deployed
bd close nad-42 --reason "Deployed to production"
```

## Key Commands

```bash
# Finding work
bd ready                           # Show unblocked issues
bd status                          # Project health overview
bd list --label active-now         # Session recovery

# Completing work
bd close nad-42 --suggest-next     # Close and show newly unblocked (v0.37)
bd close nad-1 nad-2 nad-3         # Bulk close multiple issues

# Dependencies
bd dep add <issue> <depends-on>    # Add dependency
bd blocked                         # Show blocked issues

# Sync
bd sync                            # Sync with git remote
bd sync --status                   # Check sync status
```

## Rich Context Fields

Preserve context across sessions:

```bash
# Design guidance
bd create "Implement webhook handler" -t task -p 1 \
  --design "Use TanStack server function pattern. Handle stripe.subscription.updated."

# Acceptance criteria
bd create "Fix contact form validation" -t bug -p 1 \
  --acceptance "Email field rejects addresses without @. E2E tested."

# Notes during work
bd update nad-42 --notes "Found this also affects prospects import. May need follow-up."
```

## Session Recovery

```bash
# Find what was actively being worked on
bd list --label active-now
# Should return exactly ONE bead (or zero if nothing was active)
```

## Tech-Debt Tracking

**All TODO/FIXME comments in code MUST be tracked as beads with `tech-debt` label.**

### When AI Writes TODO Comments

1. Create beads issue immediately with `tech-debt` label
2. Write TODO comment with bead ID: `// TODO(nad-XXX): Description`
3. Alert user: `TODO(nad-XXX) comment tracked: [description]`

### When Completing TODO Items

1. Implement the code
2. Find bead ID from TODO comment
3. Remove the comment
4. Close the bead: `bd close nad-XXX --reason "Implemented"`

## Priorities

- **0** - Critical (security, data loss, broken builds)
- **1** - High (major features, important bugs)
- **2** - Medium (default)
- **3** - Low (polish, optimization)
- **4** - Backlog (future ideas)

## Issue Types

- **bug** - Something broken
- **feature** - New functionality
- **task** - Work item (tests, docs, refactoring)
- **epic** - Large feature with subtasks (meta-task, not actionable)
- **chore** - Maintenance (dependencies, tooling)

## Important Rules

- Use bd for persistent task tracking
- Use TodoWrite for ephemeral session execution
- Always use `--json` flag for programmatic use
- Link discovered work with `discovered-from` dependencies
- CREATE BEADS ISSUE for EVERY TODO comment with `tech-debt` label
- NEVER commit code with TODO comments without beads issue
