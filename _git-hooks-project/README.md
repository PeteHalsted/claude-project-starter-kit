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

## Bypass Options

| Variable | Effect |
|----------|--------|
| `SKIP_TS_CHECK=1` | Skip TypeScript validation (checkpoints) |
| `SKIP_ALL_HOOKS=1` | Skip everything (emergency only) |

## Why Local Hooks Instead of Global?

**DO NOT use global hooks** (`git config --global core.hooksPath`). This overrides local hooks.

When you set a global hooks path:
1. Git ignores ALL local hooks in every repository
2. Project-specific hooks stop running

## Hooks Included

| Hook | Purpose |
|------|---------|
| `pre-commit` | TypeScript validation |
| `pre-merge-commit` | Same as pre-commit, runs during merge commits |
