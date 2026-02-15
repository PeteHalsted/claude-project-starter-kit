# Sync CPL

Install or update CPL (Claude Project Launcher) from the starter kit repo source.

## Step 1: Resolve starter kit path

```bash
CONFIG_FILE="$HOME/.claude/starter-kit-config.json"
if [ -f "$CONFIG_FILE" ]; then
  KIT_PATH=$(grep -o '"starterKitPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
fi
```

If `KIT_PATH` is empty or the config file doesn't exist, tell the user to run `/sync-global` from the starter kit repo first.

## Step 2: Run the sync script

```bash
"$KIT_PATH/_cpl/sync-cpl.sh" --force
```

## Step 3: Report the results

After running, report what happened:
- Was it a fresh install or an update?
- What version was installed?
- Were there any compilation errors?

If there were errors, investigate and suggest fixes.
