# Sync Starter Kit

Sync this project with the Claude Project Starter Kit. One-way sync: starter kit → project.

## Step 1: Run the sync script

```bash
~/.claude/scripts/sync-starter-kit.sh
```

## Step 2: Report findings from EACH section

After running the script, you MUST report on ALL sections:

### AIRules
- List IDENTICAL files (brief)
- List DIFFERS files with what changed
- List NEW files available from kit
- List PROJECT-ONLY files

### Git Hooks
Script compares `_git-hooks-project/` (kit) with `.git/hooks/` (project).
Script outputs for each hook: OK, MISSING, DIFFERS, or NOT EXECUTABLE.
- OK = project hook matches kit hook
- MISSING = kit has hook, project doesn't
- DIFFERS = both have hook but content differs
- NOT EXECUTABLE = exists but needs chmod +x

### CLAUDE.md (IMPORTANT)
- If missing: offer to create minimal version
- If ANY extra content beyond `@AGENTS.md` import: **WARN** - show extra content, suggest moving to AIRules/projectrules.md
- If minimal (only imports @AGENTS.md): confirm OK

### AGENTS.md (IMPORTANT - Intelligent Merge)
You MUST perform intelligent analysis:

1. **Read both files** (both are in project ROOT, not AIRules/):
   - Get starter kit path from `~/.claude/starter-kit-config.json` (field: `starterKitPath`)
   - Read `{starterKitPath}/AGENTS.md` for canonical import order
   - Read `./AGENTS.md` (current project root) for current state

2. **Determine canonical order** (constitution.md LAST for recency bias):
```
@readme.md
@airules/bashtools.md
@airules/ClaudeChrome.md
@airules/shadcn.md
@airules/ref.md
@airules/exa.md
@airules/development-guidelines.md
@airules/git.md
@airules/beads.md
@airules/projectrules.md
@airules/constitution.md
```

3. **Analyze project's AGENTS.md**:
   - Which imports are enabled vs commented out?
   - Are they in the wrong order?
   - Any imports missing that kit has?
   - Any project-specific imports not in kit?
   - Any non-import content?

4. **Propose merged version**:
   - Use kit's order
   - Preserve project's enabled/disabled state
   - New imports: ask enable or comment out
   - Project-specific imports: keep at end, mark as custom
   - Non-import content: preserve, announce

5. **Show diff and ask for approval**

## Step 3: Take actions

For each issue found, ask user what to do:

### AIRules actions
- DIFFERS: "Update [file] with kit version?"
- NEW: "Add [file] to project?" → if yes, also add import to AGENTS.md
- PROJECT-ONLY: "Keep as custom or delete?"

### Hook actions
- Copy missing hooks
- Make executable: `chmod +x .git/hooks/*`

### CLAUDE.md actions
- If bloated: show what to remove or move to projectrules.md
- If missing: create minimal version

### AGENTS.md actions
- Show before/after diff
- Apply if approved

## Output format

```
=== SYNC ANALYSIS ===

AIRules: X identical, Y differs, Z new
Git Hooks: X ok, Y needs attention
CLAUDE.md: [OK | WARNING: X lines, should be ~7]
AGENTS.md: [OK | NEEDS REORDER | X new imports available]

=== DETAILS ===
[details for each section]

=== PROPOSED ACTIONS ===
1. [action]
2. [action]

Proceed? [y/n/select]
```
