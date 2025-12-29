#!/bin/bash
# Bead comment reminder hook
# Type: Stop
# Purpose: Remind AI to add bead comment after code changes

# Only runs if .beads/ exists (beads project)
[ ! -d ".beads" ] && exit 0

# Check for active-now bead
ACTIVE_BEAD=$(bd list --label active-now --json 2>/dev/null | jq -r '.[0].id // empty')
[ -z "$ACTIVE_BEAD" ] && exit 0

# Get transcript path from stdin (Stop hook receives JSON input)
INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
[ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ] && exit 0

# Count Edit/Write tool calls in transcript
EDIT_COUNT=$(grep -c '"tool":"Edit"\|"tool":"Write"\|"name":"Edit"\|"name":"Write"' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Count unique files touched (significant work indicator)
FILE_COUNT=$(grep -oE '"file_path":"[^"]+"|"filePath":"[^"]+"' "$TRANSCRIPT_PATH" 2>/dev/null | sort -u | wc -l | tr -d ' ')

# Threshold: meaningful work = 5+ edits OR 3+ files
# Not every edit. Not just major features. The middle ground.
if [ "$EDIT_COUNT" -ge 5 ] || [ "$FILE_COUNT" -ge 3 ]; then
  cat <<EOF
<system-reminder>
Bead comment check ($EDIT_COUNT edits, $FILE_COUNT files). Worth preserving?
  bd comments add $ACTIVE_BEAD "<what you did and why>"
Skip if trivial. Add if losing this context would set someone back.
</system-reminder>
EOF
fi

exit 0
