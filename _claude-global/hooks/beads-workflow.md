# Beads Workflow (Slim)

**This project uses beads (`bd`) for persistent issue tracking.**

## Critical Rules

| Tool | Use For |
|------|---------|
| **Beads** | Multi-session work, dependencies, discovered issues |
| **TodoWrite** | Single-session execution tracking only |

## AI Autonomy Boundaries

**AI CAN do freely:**
- `bd create`, `bd update --status in_progress`, `bd label add/remove`
- Mark code complete: `bd label add <id> needs-testing`

**AI MUST NEVER do (user only):**
- `bd label add <id> tested-local` - USER ONLY
- `bd label add <id> deployed` - USER ONLY
- `bd close <id>` - USER ONLY

## Active-Now Rule

Non-trivial code changes require an `active-now` bead:
```bash
bd list --label active-now  # Session recovery - should return 0 or 1 bead
```

Before closing: ALWAYS `bd label remove <id> active-now` first.

## Tech-Debt Rule

ALL TODO/FIXME comments MUST have a beads issue:
```bash
// TODO(nad-XXX): Description  # Format required
```

---
**For full command reference and workflows, invoke the `beads` skill.**
