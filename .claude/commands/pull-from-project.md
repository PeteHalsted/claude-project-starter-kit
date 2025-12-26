# Pull From Project

Pull AIRules and git hooks changes from a real project back into the starter kit. Master only.

## Step 1: Verify Master mode

```bash
if [[ ! -f ".claude/master.txt" ]]; then
  echo "ERROR: Not in starter kit. This command only works from the master repo."
  exit 1
fi
```

## Step 2: Get project path

Ask user: "Which project to pull from?"

Suggest common paths:
- `~/projects/mysite.nextagedesigns`
- `~/projects/brochure-site-builder`

Or accept custom path.

## Step 3: Validate project

```bash
PROJECT_PATH="[user provided path]"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "ERROR: Path does not exist: $PROJECT_PATH"
  exit 1
fi

if [[ ! -d "$PROJECT_PATH/AIRules" ]]; then
  echo "ERROR: No AIRules/ folder in project"
  exit 1
fi
```

## Step 4: Compare AIRules files

```bash
for project_file in "$PROJECT_PATH/AIRules"/*.md; do
  filename=$(basename "$project_file")
  kit_file="./airules/$filename"

  # Skip projectrules.md - always project-specific
  [[ "$filename" == "projectrules.md" ]] && continue

  if [[ ! -f "$kit_file" ]]; then
    echo "NEW: $filename"
  elif diff -q "$project_file" "$kit_file" > /dev/null 2>&1; then
    echo "IDENTICAL: $filename"
  else
    echo "DIFFERS: $filename"
  fi
done
```

## Step 5: Compare git hooks

```bash
# Only compare hooks that exist in starter kit (canonical set)
for kit_hook in ./_git-hooks-project/*; do
  hookname=$(basename "$kit_hook")
  project_hook="$PROJECT_PATH/.git/hooks/$hookname"

  if [[ ! -f "$project_hook" ]]; then
    echo "MISSING IN PROJECT: $hookname"
  elif diff -q "$kit_hook" "$project_hook" > /dev/null 2>&1; then
    echo "IDENTICAL: $hookname"
  else
    echo "DIFFERS: $hookname"
  fi
done
```

## Step 6: For DIFFERS AIRules files

Show diff and ask:
```bash
diff "./airules/$filename" "$PROJECT_PATH/AIRules/$filename"
```
"Pull project version? (y/n)"

## Step 7: For NEW AIRules files

Show first 30 lines, ask: "Add to starter kit? (y/n)"

## Step 8: For DIFFERS git hooks

Show diff and ask:
```bash
diff "./_git-hooks-project/$hookname" "$PROJECT_PATH/.git/hooks/$hookname"
```
"Pull project version? (y/n)"

## Step 9: Apply AIRules

```bash
cp "$PROJECT_PATH/AIRules/$filename" "./airules/$filename"
```

## Step 10: Apply git hooks

```bash
cp "$PROJECT_PATH/.git/hooks/$hookname" "./_git-hooks-project/$hookname"
```

## Step 11: Remind

If NEW AIRules files added: "Update AGENTS.md template to include new import."
