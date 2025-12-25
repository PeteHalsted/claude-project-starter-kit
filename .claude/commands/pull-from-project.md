# Pull From Project

Pull AIRules changes from a real project back into the starter kit. Master only.

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

## Step 4: Compare files

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

## Step 5: For DIFFERS files

Show diff and ask:
```bash
diff "./airules/$filename" "$PROJECT_PATH/AIRules/$filename"
```
"Pull project version? (y/n)"

## Step 6: For NEW files

Show first 30 lines, ask: "Add to starter kit? (y/n)"

## Step 7: Apply

```bash
cp "$PROJECT_PATH/AIRules/$filename" "./airules/$filename"
```

## Step 8: Remind

If NEW files added: "Update AGENTS.md template to include new import."
