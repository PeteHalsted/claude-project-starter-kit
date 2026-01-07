# Beads Update Check

Check for beads updates, analyze changelog, and guide updates to our hooks/skills.

## 1. Check versions

```bash
bd version
brew info beads --json | jq -r '.[0].versions.stable'
```

Compare installed vs latest. If same, report "beads is up to date" and stop.

## 2. Fetch changelog

If update available, fetch the releases page:

```
https://github.com/steveyegge/beads/releases
```

Use WebFetch to get release notes for all versions between current and latest.

## 3. Analyze changes

For each version in the upgrade path, identify:

### Breaking Changes
- Command syntax changes
- Removed commands/flags
- Behavior changes that could break existing workflows
- Database migration requirements

### New Features
- New commands
- New flags on existing commands
- New workflow capabilities

### Bug Fixes
- Relevant fixes for issues we may have encountered

### Deprecations
- Features marked for removal
- Migration paths recommended

## 4. Compare against our customizations

Read our beads integration files:
- `_claude-global/hooks/beads-workflow.md` - Slim workflow guide
- `_claude-global/skills/beads/SKILL.md` - Full command reference
- `project-documentation/beads-setup.md` - Setup documentation

Identify:
- Commands we document that have changed
- New commands we should add to our docs
- Workflow changes we should consider adopting
- Any conflicts with our custom label workflow

## 5. Generate update report

Present findings:

```
## Beads Update Report

**Current**: X.X.X
**Latest**: Y.Y.Y
**Versions to upgrade**: [list]

### Breaking Changes
[list or "None"]

### New Features Worth Adopting
[list with brief explanation]

### Required Updates to Our Files
- [ ] beads-workflow.md: [changes needed]
- [ ] SKILL.md: [changes needed]
- [ ] beads-setup.md: [changes needed]

### Recommended Actions
1. [action]
2. [action]
```

## 6. If user approves

Run the upgrade:
```bash
brew upgrade beads
bd version  # verify
```

Then make the identified changes to:
- `_claude-global/hooks/beads-workflow.md`
- `_claude-global/skills/beads/SKILL.md`
- `project-documentation/beads-setup.md`

## 7. Sync to global (IMPORTANT)

**WARNING**: User is in MASTER MODE. `~/.claude/` is source of truth.
Running `/sync-global` after editing local files will OVERWRITE your changes.

After editing `_claude-global/` files, manually copy to global:
```bash
cp _claude-global/skills/beads/SKILL.md ~/.claude/skills/beads/SKILL.md
cp _claude-global/hooks/beads-workflow.md ~/.claude/hooks/beads-workflow.md
```

Do NOT run `/sync-global` - it pulls FROM global, not TO global.
