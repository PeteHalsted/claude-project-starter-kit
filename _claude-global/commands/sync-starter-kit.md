# Sync Starter Kit

Sync this project with the Claude Project Starter Kit. One-way sync: starter kit → project.

## Step 1: Run the sync script

```bash
~/.claude/scripts/sync-starter-kit.sh
```

## Step 2: Report findings from EACH section

After running the script, you MUST report on ALL sections:

### Rules (.claude/rules/)
Script compares starter kit's `.claude/rules/` with project's `.claude/rules/`.
- List IDENTICAL files (brief)
- List DIFFERS files with what changed
- List NEW files available from kit
- List PROJECT-ONLY files

Note: `projectrules.md` is always skipped (project-specific).

### Git Hooks
Script compares `_git-hooks-project/` (kit) with `.git/hooks/` (project).
Script outputs for each hook: OK, MISSING, DIFFERS, or NOT EXECUTABLE.
- OK = project hook matches kit hook
- MISSING = kit has hook, project doesn't
- DIFFERS = both have hook but content differs
- NOT EXECUTABLE = exists but needs chmod +x

### CLAUDE.md
- If missing: OK (optional - .claude/rules/ auto-discovers)
- If has legacy @AGENTS.md import: WARN - deprecated
- If has legacy @AIRules imports: WARN - migrate needed

### Skills (.claude/skills/)
Script compares starter kit's `_claude-project/skills/` with project's `.claude/skills/`.
- List IDENTICAL skills (brief)
- List DIFFERS skills with what changed
- List NEW skills available from kit
- List PROJECT-ONLY skills
- Detect deprecated shadcn-ui MCP that should be removed

### MCP Rule Dependencies
Script checks MCP-dependent rules against installed MCPs:
- RULE WITHOUT MCP: Rule exists but MCP not installed → suggest delete or install
- MCP WITHOUT RULE: MCP installed but rule missing → suggest add rule
- OK: Both rule and MCP present

Global MCPs (checked via `claude mcp list`): Ref, exa

### Legacy Check
- If AGENTS.md exists: WARN - deprecated, suggest deletion
- If AIRules/ folder exists: WARN - migrate to .claude/rules/

## Step 3: Take actions

For each issue found, ask user what to do:

### Rules actions
- DIFFERS: "Update [file] with kit version?"
- NEW: "Add [file] to project?" → copy to .claude/rules/
- PROJECT-ONLY: "Keep as custom or delete?"

### Skills actions
- NEW: "Install [skill] to project?" → copy to .claude/skills/
- DIFFERS: "Update [skill] with kit version?"
- DEPRECATED MCP: "Remove shadcn-ui MCP?" → `claude mcp remove shadcn-ui`

### Hook actions
- Copy missing hooks
- Make executable: `chmod +x .git/hooks/*`

### Legacy migration actions
If AGENTS.md or AIRules/ exist:
1. Copy any project-specific rules to .claude/rules/
2. Delete AGENTS.md
3. Delete AIRules/ folder
4. Update CLAUDE.md to remove legacy imports

## Output format

```
=== SYNC ANALYSIS ===

Rules: X identical, Y differs, Z new
Git Hooks: X ok, Y needs attention
CLAUDE.md: [OK | WARNING: has legacy imports]
Legacy: [OK | WARNING: AGENTS.md/AIRules found]

=== DETAILS ===
[details for each section]

=== PROPOSED ACTIONS ===
1. [action]
2. [action]

Proceed? [y/n/select]
```

## Native Rules Directory

Starter kit templates in `_claude-project/rules/` sync to project's `.claude/rules/`:
- All `.md` files auto-discovered (no imports needed)
- Subdirectories supported (e.g., `integrations/`)
- Path-targeting via YAML frontmatter (see project-documentation/path-targeting-rules.md)
- MCP-dependent rules checked against installed MCPs

Structure:
```
_claude-project/rules/          # Kit rule templates
└── (syncs to)
    project/.claude/rules/      # Project rules (auto-discovered)
    ├── constitution.md         # Core rules
    ├── development-guidelines.md
    ├── git.md
    ├── bashtools.md
    ├── projectrules.md         # Project-specific (never synced)
    └── integrations/
        ├── ref.md              # MCP: Ref (global)
        └── exa.md              # MCP: exa (global)

_claude-project/skills/         # Kit skill templates
└── (syncs to)
    project/.claude/skills/     # Project skills
    └── shadcn/                 # shadcn/ui skill (replaces MCP)
        ├── SKILL.md
        ├── cli.md
        ├── customization.md
        ├── mcp.md
        └── rules/
```
