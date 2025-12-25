# Beads Issue Tracking Guide

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

## Core Concepts

### Beads Status = Quality Gates

Beads has 3 built-in status values that represent quality gates:

- **`open`** - Brand new, untouched bead
- **`in_progress`** - Bead has entered the workflow (touched)
- **`closed`** - Bead is deployed to production (finished)

**CRITICAL**: A bead is only closed when deployed to production, not when code is written or tested.

### Labels = Workflow Stages

Labels track the actual workflow stages. Beads can have multiple labels:

**Workflow Labels:**
- **`coding`** - Actively being developed (code not yet complete)
- **`needs-testing`** - Code complete, ready for QA testing
- **`tested-local`** - QA passed, ready for deployment
- **`deployed`** - Live in production (bead should also be `status: closed`)

**Modifier Labels:**
- **`active-now`** - THE ONE thing being worked on RIGHT NOW (only 1 bead can have this)
- **`tech-debt`** - AI cut corners, needs cleanup (tracked separately from normal workflow)

### User Queries = Filter by Labels

When asking about work, **use the word "label" in your question** to trigger label filtering:

**Simple Queries:**
- **"What are we coding?"** → `bd list --label coding --json`
- **"What is open?"** → `bd list --status open --json` (brand new beads)
- **"What needs testing?"** → `bd list --label needs-testing --json`
- **"What's tested and ready to deploy?"** → `bd list --label tested-local --json`
- **"What tech-debt do we have?"** → `bd list --label tech-debt --json`
- **"What am I actively working on right now?"** → `bd list --label active-now --json`

**Complex Queries:**
- **"What beads with label tech-debt do we have that need testing?"** → `bd list --label tech-debt --label needs-testing --json`

## Quick Start Commands

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Issue title" -p 1 --deps discovered-from:nad-123 --json
bd create "Subtask" --parent <epic-id> --json  # Hierarchical subtask
```

**Claim and work on issues:**
```bash
# Claim work
bd update nad-42 --status in_progress --json

# Mark as actively coding right now
bd label add nad-42 coding --json
bd label add nad-42 active-now --json

# Update priority
bd update nad-42 --priority 1 --json
```

**Complete work:**
```bash
# Code complete, ready for testing
bd label remove nad-42 active-now --json
bd label remove nad-42 coding --json
bd label add nad-42 needs-testing --json

# Testing passed
bd label remove nad-42 needs-testing --json
bd label add nad-42 tested-local --json

# Deployed to production
bd label remove nad-42 tested-local --json
bd label add nad-42 deployed --json
bd close nad-42 --reason "Deployed to production" --json
```

**Managing dependencies:**
```bash
# Add blocking dependency
bd dep add nad-456 nad-123 --type blocks --json

# Add related dependency
bd dep add nad-456 nad-123 --type related --json

# Add discovered-from dependency
bd dep add nad-456 nad-123 --type discovered-from --json

# Show dependency tree
bd dep tree nad-456 --json
```

## Issue Types

- **`bug`** - Something broken
- **`feature`** - New functionality
- **`task`** - Work item (tests, docs, refactoring)
- **`epic`** - Large feature with subtasks (meta-task, not actionable work)
- **`chore`** - Maintenance (dependencies, tooling)

## Priorities

- **`0`** - Critical (security, data loss, broken builds)
- **`1`** - High (major features, important bugs)
- **`2`** - Medium (default)
- **`3`** - Low (polish, optimization)
- **`4`** - Backlog (future ideas)

## Workflow Progression

```bash
# 1. Claim work and start coding
bd update nad-42 --status in_progress --json
bd label add nad-42 coding --json
bd label add nad-42 active-now --json

# 2. Code complete, ready for testing
bd label remove nad-42 active-now --json
bd label remove nad-42 coding --json
bd label add nad-42 needs-testing --json

# 3. Testing passed, ready for deployment
bd label remove nad-42 needs-testing --json
bd label add nad-42 tested-local --json

# 4. Deployed to production
bd label remove nad-42 tested-local --json
bd label add nad-42 deployed --json
bd close nad-42 --reason "Deployed to production" --json
```

## Session Recovery After Crash

```bash
# Find what was actively being worked on
bd list --label active-now --json
# Should return exactly ONE bead (or zero if nothing was active)
```

## Rich Context Fields

Preserve context across sessions with rich metadata:

**`--design` flag** - Implementation guidance:
```bash
bd create "Implement webhook handler" -t task -p 1 \
  --design "Use TanStack server function pattern per MFing-Bible. Handle stripe.subscription.updated. Update websiteproject.status to 'suspended' on failure. Log with Adze namespace 'stripe:webhook'" \
  --json
```

**`--acceptance` flag** - Completion criteria:
```bash
bd create "Fix contact form validation" -t bug -p 1 \
  --acceptance "Email field rejects addresses without @ symbol. E2E tested with invalid emails." \
  --json
```

**`--notes` flag** - Additional context:
```bash
bd update nad-42 --notes "Found during testing that this also affects the prospects import flow. May need follow-up task." --json
```

## AI Agent Autonomy Boundaries

**AI can freely manage:**
- Create beads: `bd create`
- Claim work: `bd update <id> --status in_progress`
- Add labels: `bd label add <id> coding`, `bd label add <id> active-now`
- Mark code complete: `bd label add <id> needs-testing`
  - ✅ This is "done" from AI's perspective - code is written, type-checked, ready to demo
  - Use language: "Implementation complete and ready for testing"

**AI MUST NEVER do without user direction:**
- Mark as tested: `bd label add <id> tested-local` ← USER ONLY (after QA)
- Mark as deployed: `bd label add <id> deployed` ← USER ONLY (after deployment)
- Close beads: `bd close <id>` ← USER ONLY (final confirmation)

**Why**: User is QA. Only user verifies testing and deployment.

**Terminology Guide:**
- ✅ "Implementation complete" = moved to `needs-testing`
- ❌ "Testing complete" = moved to `tested-local` (AI cannot say this)
- ❌ "Work complete" or "Done" = closed (AI cannot say this)

## Workflow for AI Agents

1. **Check ready work**: `bd ready --json` shows unblocked issues
   - Filter out epic beads (meta-tasks, not actionable)
2. **Claim task**: `bd update <id> --status in_progress --json`
3. **Mark active**: `bd label add <id> coding --json` and `bd label add <id> active-now --json`
4. **Work on it**: Implement, test, document
5. **Discover new work?** Create linked issue: `bd create "Found bug" -p 1 --deps discovered-from:<parent-id> --json`
6. **Mark code complete**: Remove `active-now` and `coding`, add `needs-testing`
7. **Commit together**: Always commit `.beads/issues.jsonl` with code changes

## Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed

## CLI-Only Integration

Use bd CLI via bash with `--json` flag:

```bash
bd ready --json
bd create "Task title" -t task -p 2 --json
bd update nad-42 --status in_progress --json
bd list --label coding --json
```

**Why CLI instead of MCP:**
- Zero upfront context cost
- Only pays context when used
- Simpler, more transparent

## Advanced Features

**Dependency Types:**
- `blocks` - Hard blocker (affects `bd ready`)
- `related` - Soft relationship
- `parent-child` - Epic/subtask hierarchy
- `discovered-from` - Found during implementation

**Label Filtering:**
```bash
# AND: Must have BOTH labels
bd list --label tech-debt --label needs-testing --json

# OR: Must have AT LEAST ONE label
bd list --label-any bug,critical --json
```

## Managing AI Planning Documents

Store AI-generated planning docs in `history/` directory:
- PLAN.md, IMPLEMENTATION.md, ARCHITECTURE.md, etc.
- Keeps repository root clean
- Easy to exclude from version control
- Preserves planning history

## Tech-Debt Tracking (AI TODO Comments)

**CRITICAL**: All TODO/FIXME/HACK/XXX comments in code MUST be tracked as beads with `tech-debt` label.

### When AI Writes TODO Comments

**MANDATORY PROTOCOL:**

1. **Create beads issue immediately**:
   ```bash
   ISSUE_ID=$(bd create "Complete: [description]" -t task -p 1 -d "TODO comment in code" --json | jq -r '.id')
   bd label add "$ISSUE_ID" tech-debt --json
   bd update "$ISSUE_ID" --notes "Location: $FILE:$LINE
   Code Comment: $FULL_COMMENT_TEXT
   Current Behavior: [what code does now]
   Impact: [what breaks or is limited]
   Action Required: [specific steps]" --json
   ```

2. **Write TODO comment with bead ID**:
   ```javascript
   // TODO(nad-XXX): Description of what needs to be done
   ```

3. **Alert user**:
   ```
   ⚠️ TODO(nad-XXX) comment tracked: [description]
   Location: $FILE:$LINE
   ```

### When Completing TODO Items

1. **Implement the code**
2. **Find bead ID** from TODO comment: `// TODO(nad-XXX): ...`
3. **Remove the comment**
4. **Close the bead**: `bd close nad-XXX --reason "Implemented" --json`
5. **Alert user**: `✅ TODO completed: nad-XXX`

### Enforcement: Git Pre-Commit Hook

Pre-commit hook validates TODO tracking before allowing commits. Scans all tracked files for TODO comments and ensures each has a corresponding bead.

**How it works:**

The pre-commit hook in `.git/hooks/pre-commit` combines two functions:
1. **Beads sync** - Ensures database is synced with JSONL before querying (prevents "Database out of sync" errors)
2. **TODO validation** - Scans code for TODO comments and verifies each has a tracked bead

**Important:** This is a LOCAL hook per-project, not a global hook. Each beads project should have its own pre-commit hook that chains beads sync with any project-specific validation.

**Why local hooks instead of global:**
- Global hooks (`git config --global core.hooksPath`) override ALL repos
- This breaks beads' built-in hooks (post-checkout, post-merge, pre-push)
- Local hooks allow each project to control its own workflow
- Beads hooks work naturally when no global override exists

### Why This Exists

**Problem**: AI writes `// TODO: Implement X` instead of implementing X. Code ships with placeholders.

**Solution**: Force immediate tracking in beads. Pre-commit hook prevents untracked TODOs from entering git history.

## Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Use "label" keyword in queries to trigger label filtering
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Store AI planning docs in `history/` directory
- ✅ CREATE BEADS ISSUE for EVERY TODO comment with `tech-debt` label
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems
- ❌ NEVER commit code with TODO comments without beads issue

For more details, see official beads documentation at https://github.com/steveyegge/beads
