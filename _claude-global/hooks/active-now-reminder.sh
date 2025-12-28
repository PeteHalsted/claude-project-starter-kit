#!/bin/bash
# Active-now bead reminder hook
# Type: UserPromptSubmit
# Purpose: Remind AI to claim a bead before making code changes

# Only runs if .beads/ exists (beads project)
[ ! -d ".beads" ] && exit 0

# Check for active-now bead
ACTIVE=$(bd list --label active-now --json 2>/dev/null | jq -r 'length')

if [ "$ACTIVE" = "0" ]; then
  cat <<'EOF'
<system-reminder>
No active-now bead. Before making code changes:
1. Find relevant bead: `bd ready` or `bd list`
2. Claim it: `bd update <id> --status in_progress && bd label add <id> active-now`
3. Or create new: `bd create "..." -t task && bd label add <id> active-now`
</system-reminder>
EOF
fi

exit 0
