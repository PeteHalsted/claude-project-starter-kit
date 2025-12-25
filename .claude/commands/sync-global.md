# Sync Global Claude Config

Sync between `~/.claude/` (installed) and `_claude-global/` (starter kit).

## Watched Locations (Whitelist)

**Folders** (full recursive scan):
- `hooks/`
- `skills/`
- `Agents/` (if exists)
- `commands/` (if exists)

**Root files**:
- `settings.json`
- `statusline.sh`

Everything else is runtime data (projects, debug, plugins, etc.) - ignored.

## Execution Steps

### 1. Detect Mode
Run: `test -f .claude/master.txt && echo MASTER || echo CONSUMER`

- **MASTER**: Your `~/.claude/` is truth → update `_claude-global/` to match
- **CONSUMER**: Starter kit is truth → update your `~/.claude/`

### 2. List Kit Files (watched locations only)
```bash
fd -t f . _claude-global/hooks _claude-global/skills _claude-global/Agents _claude-global/commands 2>/dev/null
ls _claude-global/settings.json _claude-global/statusline.sh 2>/dev/null
```

### 3. List Global Files (watched locations only)
```bash
fd -t f . ~/.claude/hooks ~/.claude/skills ~/.claude/Agents ~/.claude/commands 2>/dev/null
ls ~/.claude/settings.json ~/.claude/statusline.sh 2>/dev/null
```

### 4. Compare Each File
For each file found, compare kit ↔ global using `md5 -q`:
- **IDENTICAL**: Hashes match
- **DIFFERS**: Hashes don't match
- **MISSING_IN_GLOBAL**: Kit has it, global doesn't
- **ONLY_IN_GLOBAL**: Global has it, kit doesn't

## Analysis Rules

### Master Mode (kit follows global)
- **DIFFERS**: Read both, recommend updating kit from global
- **ONLY_IN_GLOBAL**: Ask if it should be added to kit
- **MISSING_IN_GLOBAL**: Flag as intentionally removed?

### Consumer Mode (global follows kit)
- **DIFFERS**: Compare, check for customizations, recommend action
- **MISSING_IN_GLOBAL**: Ask if user wants to install
- **ONLY_IN_GLOBAL**: Note it exists, no action needed

## Output Format

```
## Sync Analysis: [MASTER|CONSUMER] Mode

### Summary
- Identical: X files
- Different: Y files
- Missing: Z files
- Extra: W files

### Files Needing Attention

#### [filename] - DIFFERS
- **Global**: [description]
- **Kit**: [description]
- **Recommendation**: [action]

### Proposed Actions
1. [action]
2. [action]

Proceed? (yes / no / select specific)
```

## Critical Rules

- **Fail fast**: Stop on first error, report clearly
- **Exclude noise**: plugins/, debug/, chrome/, statsig/, logs, caches
- **Hash first**: Only AI-analyze files that differ
- **Never auto-apply**: Always ask before writing
