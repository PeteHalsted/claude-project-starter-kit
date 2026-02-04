# Replace Beads with Claude Code Tasks: Exploration

**Status:** Research complete, decision pending
**Date:** 2025-01-26
**Source:** X thread by @nummanali + hands-on testing

---

## Executive Summary

Claude Code now has built-in task management (TaskCreate, TaskUpdate, TaskGet, TaskList). Can it replace beads for persistent issue tracking?

**Answer:** Partially. There's a fundamental tension between two use cases that share one mechanism.

---

## How Tasks Work

### Storage
```
~/.claude/tasks/{list-id}/*.json
```

Each task is a JSON file:
```json
{
  "id": "1",
  "subject": "Fix auth bug",
  "description": "Details here",
  "status": "pending|in_progress|completed",
  "blocks": ["2", "3"],
  "blockedBy": ["0"],
  "metadata": {"anything": "you want"}
}
```

### Persistence Control

| `CLAUDE_CODE_TASK_LIST_ID` | List ID | Persistence |
|----------------------------|---------|-------------|
| Not set | Random UUID | Session-only |
| Set to "my-project" | "my-project" | Cross-session |

**Per-project setup:**
```json
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_TASK_LIST_ID": "project-name"
  }
}
```

### Behavior
- Tasks persist to disk immediately
- Dependencies enforced (blockedBy prevents work)
- Completed tasks are **deleted** from disk
- Metadata preserved but not actively used by Claude

---

## The Core Tension

Two use cases, one mechanism:

### Use Case 1: Plan Execution (Claude-Driven)
- Claude creates tasks from a plan
- Claude works through them autonomously
- Claude marks them complete
- Tasks are transient implementation details

### Use Case 2: Backlog Management (Human-Driven)
- Human creates issues/backlog items
- Human assigns work: "work on task #X"
- Human verifies and marks complete
- Tasks are persistent project artifacts

**Problem:** With `CLAUDE_CODE_TASK_LIST_ID` set, both use cases write to the same list. Claude's autonomous plan tasks mix with human-managed backlog items.

---

## Options Analysis

### Option 1: Don't Replace Beads
- Tasks = session-scoped plan execution (no env var)
- Beads = persistent backlog
- **Pros:** Clean separation, no conflicts
- **Cons:** Two systems to maintain

### Option 2: Metadata Namespacing
- Set env var for persistence
- Tag tasks: `metadata.source: "plan"` vs `"backlog"`
- CLAUDE.md rules for handling each type
- **Pros:** Single system, full persistence
- **Cons:** Requires discipline, cleanup of orphaned plan tasks

### Option 3: Context-Aware Switching
- Doesn't work with single env var
- Would need dynamic list ID switching
- **Not viable**

### Option 4: Accept the Merge
- Set env var, everything persists
- A plan IS the backlog for that work
- Orphaned plan tasks become backlog items
- **Pros:** Simple mental model
- **Cons:** List can get cluttered, no audit trail (completed = deleted)

---

## Beads Features vs Tasks

| Feature | Beads | Tasks | Gap? |
|---------|-------|-------|------|
| Cross-session persistence | Yes | Yes (with env var) | No |
| Human-managed backlog | Yes | Yes | No |
| Claude auto-creates for plans | No | Yes | Feature, but causes mixing |
| Audit trail (completed items) | Yes | No (deleted) | **Yes** |
| Workflow stages | Custom | Via metadata | No |
| Dependencies | Manual | Built-in | Tasks better |
| Tech debt tracking | TODO refs | metadata + TODO refs | No |
| Session recovery | bd -l | TaskList | No |
| Human visibility | .beads/*.md | ~/.claude/tasks/*.json | Different location |

**Key gap:** Completed task deletion. No history of what was done.

---

## If Replacing Beads

### Required Setup Per Project

1. `.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_TASK_LIST_ID": "unique-project-id"
  }
}
```

2. CLAUDE.md workflow rules (if human-directed mode wanted):
```markdown
## Task Workflow
- When human creates backlog: tag metadata.source = "backlog"
- When Claude creates for plan: tag metadata.source = "plan"
- Plan tasks can be deleted on completion
- Backlog tasks: mark completed but consider archiving first
- Only work on tasks when explicitly assigned
```

3. Consider hook to inject workflow on SessionStart

### Migration Steps
1. Add settings.json to project
2. Add CLAUDE.md rules
3. Convert .beads/*.md to tasks (manual or scripted)
4. Remove .beads/ directory
5. Update global hooks to not inject beads for migrated projects

---

## Test Project

Location: `/Users/petehalsted/projects/tasks-test/`

```
tasks-test/
├── .claude/settings.json    # CLAUDE_CODE_TASK_LIST_ID="tasks-test"
├── CLAUDE.md                # Human-directed workflow rules
└── TEST-INSTRUCTIONS.md     # Full test protocol

~/.claude/tasks/tasks-test/
├── 1.json  # in_progress, blocks #2
├── 2.json  # pending, blocked by #1
├── 3.json  # pending, blocked by #2
└── 4.json  # pending, unblocked (tech-debt)
```

---

## Open Questions

1. **Audit trail:** Completed tasks are deleted. Need external archiving?
2. **Plan pollution:** How to clean up orphaned plan tasks between sessions?
3. **Concurrency:** Multiple Claude sessions same project - race conditions?
4. **ID collisions:** Same `CLAUDE_CODE_TASK_LIST_ID` across projects = shared list (bug or feature?)

---

## Recommendation

**For now:** Keep beads for persistent backlog, use tasks for session-scoped plan execution (no env var).

**Revisit when:**
- Need for built-in dependency management outweighs audit trail loss
- Anthropic adds completed task archiving
- Workflow rules prove reliable in testing

---

## References

- X thread: https://x.com/nummanali/status/2014684862985175205
- Task storage: `~/.claude/tasks/`
- Test project: `/Users/petehalsted/projects/tasks-test/`
