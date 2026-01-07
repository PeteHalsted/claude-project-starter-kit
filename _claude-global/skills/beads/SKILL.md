---
name: beads
description: Issue tracking and workflow management with beads (bd). Use this skill when you need command reference, workflow examples, session recovery protocols, or dependency management guidance. Invoke when working with beads issues or when the slim hook reference is insufficient.
---

# Beads Skill

Full reference for beads (`bd`) issue tracking CLI. For critical rules, see the injected hook context.

## Trigger Phrases

**"beads state"** or **"show me beads state"**
When user asks for beads state, run:
```bash
bd list                      # All non-closed (open + in_progress, includes active-now)
```
Present grouped by status: active-now highlighted first, then in_progress, then open.

## Status = Quality Gates

- **`open`** - Brand new, untouched
- **`in_progress`** - Work has started
- **`closed`** - Deployed to production

**CRITICAL**: A bead is only closed when deployed to production.

## Labels = Workflow Stages

**Workflow Labels:**
- **`coding`** - Actively being developed
- **`needs-testing`** - Code complete, ready for QA
- **`tested-local`** - QA passed, ready for deployment
- **`deployed`** - Live in production (also `status: closed`)

**Modifier Labels:**
- **`active-now`** - THE ONE thing being worked on RIGHT NOW (only 1 bead)
- **`tech-debt`** - AI cut corners, needs cleanup

## Workflow Progression

Steps 3-4: AI executes when user requests. Never proactively.

```bash
# 1. Claim work and start coding
bd update nad-42 --status in_progress
bd label add nad-42 coding
bd label add nad-42 active-now

# 2. Code complete, ready for testing
bd label remove nad-42 active-now
bd label remove nad-42 coding
bd label add nad-42 needs-testing

# 3. Testing passed (on user request)
bd label remove nad-42 needs-testing
bd label add nad-42 tested-local

# 4. Deployed to production (on user request)
bd label remove nad-42 tested-local
bd label remove nad-42 active-now   # ALWAYS remove before close
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
bd close nad-42 --suggest-next     # Close and show newly unblocked
bd close nad-1 nad-2 nad-3         # Bulk close multiple issues
bd delete nad-42 --reason "Duplicate of nad-38"  # Delete with audit trail (v0.41+)

# Dependencies
bd dep add <issue> <depends-on>                      # Blocking (default)
bd dep add <issue> --blocked-by <other>              # Clearer alias (v0.44+)
bd dep add <issue> --depends-on <other>              # Clearer alias (v0.44+)
bd dep add <issue> <depends-on> --type related       # Related issues
bd dep add <issue> <depends-on> --type discovered-from
bd dep add <issue> <depends-on> --type parent-child  # Epic/subtask
bd blocked                                           # Show blocked issues
bd dep tree <issue>                                  # Show dependency tree

# Sync
bd sync                            # Sync with git remote
bd sync --status                   # Check sync status
```

## Rich Context Fields

```bash
# Design guidance
bd create "Implement webhook handler" -t task -p 1 \
  --design "Use TanStack server function pattern."

# Acceptance criteria
bd create "Fix contact form validation" -t bug -p 1 \
  --acceptance "Email field rejects addresses without @."

# Notes on create (v0.43+)
bd create "Add export feature" -t task -p 1 \
  --notes "User requested CSV and JSON formats"

# Notes during work
bd update nad-42 --notes "Found this also affects prospects import."
```

## Session Recovery Protocol

**Field usage for recovery:**

| Field | Purpose | Mutability |
|-------|---------|------------|
| `design` | Where we're going (architectural intent) | Immutable |
| `acceptance` | What counts as done | Immutable |
| `notes` | Where we are now (current status) | Replace at git commit |
| `comments` | How we got here (action trail) | Append as you work |

**Notes** are auto-updated by gitpro at commit time.

**Comments** preserve the action trail:
```bash
bd comments add <id> "Completed webhook validation, moving to error handling"
bd comments add <id> "Discovered edge case, created nad-47 for follow-up"
bd comments add <id> "Switched from float to flex - CSS limitation"
```

## Tech-Debt Tracking

When AI writes TODO comments:
1. Create beads issue with `tech-debt` label
2. Write TODO with bead ID: `// TODO(nad-XXX): Description`
3. Alert user: `TODO(nad-XXX) comment tracked`

When completing TODO items:
1. Implement the code
2. Remove the comment
3. Close the bead: `bd close nad-XXX --reason "Implemented"`

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
- **epic** - Large feature with subtasks
- **chore** - Maintenance (dependencies, tooling)
