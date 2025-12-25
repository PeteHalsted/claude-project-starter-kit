## Tooling for shell interactions (Install if missing)

**IMPORTANT**: These are bash commands to use via Bash/mcp__acp__Bash tool, NOT direct tool calls.

**Finding FILES?** use `fd` via bash
- `mcp__acp__Bash: fd '*.tsx' src/` - Find React components
- `mcp__acp__Bash: fd -e md docs/` - Find markdown files
- `mcp__acp__Bash: fd -t d node_modules` - Find directories only

**Finding TEXT/strings?** 
- **Claude Code**: Use built-in Grep tool (optimized wrapper for rg)
- **Other agents**: use `rg` via bash
- `mcp__acp__Bash: rg "useAuth" --type ts` - Search in TypeScript files
- `mcp__acp__Bash: rg "TODO|FIXME" src/` - Find action items
- `mcp__acp__Bash: rg -A 3 -B 1 "error"` - Show context around matches

**Finding CODE STRUCTURE?** use `ast-grep` via bash
- `mcp__acp__Bash: ast-grep --pattern 'function $NAME() { $$$ }'` - Find function definitions
- `mcp__acp__Bash: ast-grep --pattern 'interface $NAME { $$$ }'` - Find TypeScript interfaces

**SELECTING from multiple results?** pipe to `fzf` via bash
- `mcp__acp__Bash: fd '*.tsx' | fzf` - Interactive file selection
- `mcp__acp__Bash: rg -l "useAuth" | fzf | xargs code` - Search and open in editor

**Interacting with JSON?** use `jq` via bash
- `mcp__acp__Bash: cat package.json | jq '.dependencies'` - Extract dependencies
- `mcp__acp__Bash: curl api/users | jq '.[].name'` - Parse API responses

**Interacting with YAML or XML?** use `yq` via bash
- `mcp__acp__Bash: yq '.services.web.ports' docker-compose.yml` - Extract YAML values
