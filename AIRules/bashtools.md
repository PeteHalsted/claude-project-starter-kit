## Tooling for shell interactions (Install if missing)

**Finding FILES?** use `fd`
- `fd '*.tsx' src/` - Find React components
- `fd -e md docs/` - Find markdown files
- `fd -t d node_modules` - Find directories only

<!-- Claude Code doesn't need rg, it has an optomized grep that is a wrapper for rg but gemini needs rg -->
**Finding TEXT/strings?** use `rg`
- `rg "useAuth" --type ts` - Search in TypeScript files
- `rg "TODO|FIXME" src/` - Find action items
- `rg -A 3 -B 1 "error"` - Show context around matches

**Finding CODE STRUCTURE?** use `ast-grep`
- `ast-grep --pattern 'function $NAME() { $$$ }'` - Find function definitions
- `ast-grep --pattern 'interface $NAME { $$$ }'` - Find TypeScript interfaces

**SELECTING from multiple results?** pipe to `fzf`
- `fd '*.tsx' | fzf` - Interactive file selection
- `rg -l "useAuth" | fzf | xargs code` - Search and open in editor

**Interacting with JSON?** use `jq`
- `cat package.json | jq '.dependencies'` - Extract dependencies
- `curl api/users | jq '.[].name'` - Parse API responses

**Interacting with YAML or XML?** use `yq`
- `yq '.services.web.ports' docker-compose.yml` - Extract YAML values
