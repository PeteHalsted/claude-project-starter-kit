# Git Hooks (Project-Local)

These hooks are designed to be installed **per-project** in `.git/hooks/`, not globally.

## Why Local Hooks Instead of Global?

**DO NOT use global hooks** (`git config --global core.hooksPath`). This breaks beads.

When you set a global hooks path:
1. Git ignores ALL local hooks in every repository
2. Beads' built-in hooks (`post-checkout`, `post-merge`, `pre-push`) stop running
3. Database sync breaks → "Database out of sync with JSONL" errors
4. Your custom hooks run, but beads can't find its data

## Installation

For each project using beads with TODO validation:

```bash
# Copy the hook to your project
cp dot-git-hooks(Project-Local)/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## What the pre-commit Hook Does

The hook combines two functions:

1. **Beads Sync** - Ensures database is synced before querying
   - Imports latest JSONL to database (fixes post-checkout/merge sync issues)
   - Flushes pending database changes to JSONL
   - Stages JSONL files if modified

2. **TODO Validation** - Ensures all TODO comments have tracked beads
   - Scans code for `TODO(xxx-yyy):` patterns
   - Verifies each referenced bead exists and is open
   - Blocks commit if untracked TODOs are found

## For Projects Without TODO Validation

If you just want beads to work (no TODO enforcement), don't install this hook.
Beads' built-in hooks handle everything automatically.

## Hooks Included

| Hook | Purpose |
|------|---------|
| `pre-commit` | Beads sync + TODO validation |
| `pre-merge-commit` | Same as pre-commit, runs during merge commits |

## Beads Built-in Hooks

When you run `bd init`, beads installs these hooks automatically:
- `post-checkout` - Imports JSONL after branch switch
- `post-merge` - Imports JSONL after merge/pull
- `pre-push` - Exports database before push

These work automatically when no global hooks path overrides them.
