# Git Hooks (Project-Local)

These hooks are installed **per-project** in `.git/hooks/`, not globally.

## Installation

```bash
cp _git-hooks-project/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## What the pre-commit Hook Does

1. **TypeScript Validation** (BLOCKING)
   - Runs `npm run check-types` on staged .ts/.tsx files
   - Blocks commit if ANY TypeScript errors in staged files
   - Skips if project doesn't have `check-types` script
   - Bypass for checkpoints: `SKIP_TS_CHECK=1`

2. **Beads Sync** (if .beads/ exists)
   - Imports latest JSONL to database
   - Flushes pending database changes to JSONL
   - Stages JSONL files if modified

3. **TODO Validation** (if .beads/ exists)
   - Scans code for `TODO(xxx-NNN):` patterns
   - Verifies each referenced bead exists and is open
   - Blocks commit if untracked TODOs found

## Bypass Options

| Variable | Effect |
|----------|--------|
| `SKIP_TS_CHECK=1` | Skip TypeScript validation (checkpoints) |
| `SKIP_ALL_HOOKS=1` | Skip everything (emergency only) |

## Why Local Hooks Instead of Global?

**DO NOT use global hooks** (`git config --global core.hooksPath`). This breaks beads.

When you set a global hooks path:
1. Git ignores ALL local hooks in every repository
2. Beads' built-in hooks stop running
3. Database sync breaks

## Hooks Included

| Hook | Purpose |
|------|---------|
| `pre-commit` | TypeScript + Beads sync + TODO validation |
| `pre-merge-commit` | Same as pre-commit, runs during merge commits |
