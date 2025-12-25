# Claude Code Setup Guide

Installation, configuration, and maintenance for Claude Code.

## Installation

### macOS (Homebrew)

```bash
brew install claude-code
```

### npm (Cross-platform)

```bash
npm install -g @anthropic-ai/claude-code
```

### Verify Installation

```bash
claude --version
```

## Initial Configuration

### 1. Copy Global Config

Copy the starter kit's global configuration to your home directory:

```bash
cp -r /path/to/starter-kit/_claude-global/* ~/.claude/
```

This installs:
- `skills/gitpro/` - Git workflow automation with conventional commits
- `hooks/` - Safety guards (git-guard, block-db-commands, dev-server-guard)
- `settings.json` - Default permissions and hook configuration
- `statusline.sh` - Custom status line

### 2. Install Recommended Plugins

From within Claude Code, install plugins from the official marketplace:

```
/plugin install frontend-design@claude-code-plugins
```

**Available official plugins:**
- `frontend-design` - Production-grade UI design guidance (recommended)
- `typescript-lsp` - TypeScript/JavaScript code intelligence (see LSP section below)
- `plugin-dev` - Plugin/skill development toolkit

Browse all available plugins:
```
/plugin
```
Then navigate to the **Discover** tab.

### 3. Configure Plugin Auto-Updates

Official Anthropic plugins auto-update by default. To manually update:

```
/plugin marketplace update claude-code-plugins
```

## Updates

### Update Claude Code

Claude Code auto-updates by default. To manually update:

**Homebrew:**
```bash
brew upgrade claude-code
```

**npm:**
```bash
npm update -g @anthropic-ai/claude-code
```

### Update Plugins

Plugins from official marketplaces auto-update at startup. To force update:

```
/plugin marketplace update
```

### Disable Auto-Updates

Set environment variable to disable all auto-updates:

```bash
export DISABLE_AUTOUPDATER=1
```

## Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| `settings.json` | `~/.claude/` | Global settings, permissions, hooks |
| `settings.local.json` | `project/.claude/` | Project-specific settings |
| `skills/` | `~/.claude/skills/` | Global skills |
| `hooks/` | `~/.claude/hooks/` | Global hook scripts |

## Default Settings

The starter kit configures:

```json
{
  "permissions": {
    "allow": ["Skill(gitpro)"],
    "defaultMode": "bypassPermissions"
  }
}
```

- **bypassPermissions** - YOLO mode by default (no permission prompts)
- **Skill(gitpro)** - Auto-allow gitpro skill invocation

Use **Shift+Tab** within Claude Code to temporarily switch modes for specific operations.

## LSP Support (Code Intelligence)

**Status: Currently broken (Dec 2025)** - Known initialization bugs prevent LSP from working reliably. Revisit with future Claude Code updates.

Claude Code 2.0.74+ has native LSP support for go-to-definition, find-references, hover, and diagnostics. Setup requires installing both the language server binary and the official plugin.

### TypeScript Setup

**1. Install the language server binary:**
```bash
npm install -g typescript-language-server typescript
```

**2. Verify installation:**
```bash
which typescript-language-server
typescript-language-server --version
```

**3. Install the plugin via `/plugin` UI:**
- Run `/plugin` in Claude Code
- Go to **Discover** tab → **Code intelligence** section
- Install `typescript-lsp`

**4. Test it works:**
Ask Claude to use LSP on a TypeScript file:
```
Use the TypeScript LSP to go to the definition of MyFunction in src/index.ts
```

### Other Languages

Similar LSP plugins available in the marketplace:
- `pyright-lsp` - Python (requires `pip install pyright`)
- `rust-lsp` - Rust (requires rust-analyzer)

### Troubleshooting

If you see "No LSP server available for file type":
- Verify `typescript-language-server` is in PATH
- Check `/plugin` → **Errors** tab for issues
- Disable and re-enable the plugin
- Restart Claude Code from a fresh shell

Known bugs exist with LSP initialization. See [GitHub issues](https://github.com/anthropics/claude-code/issues?q=LSP).

## Troubleshooting

### Plugin command not recognized

Ensure Claude Code version 1.0.33 or later:
```bash
claude --version
```

### Hooks not executing

Check hook file permissions:
```bash
chmod +x ~/.claude/hooks/*.sh
```

### Skills not loading

Restart Claude Code after adding/modifying skills. Skills are loaded at startup.
