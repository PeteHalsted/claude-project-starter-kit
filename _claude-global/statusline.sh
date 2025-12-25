#!/bin/bash
# Custom Claude Code statusline - Pete Halsted
# Line 1: Core info (directory, branch, version, model)
# Line 2: Native Claude metrics (context, cost, duration, lines changed)
# Line 3: ccusage output (5hr limits, burn rate)

# ==========================================
# SETTINGS - ADJUST THESE AS NEEDED
# ==========================================
# Fudge factor (in tokens) to add to current_usage to approximate actual context window
# Accounts for system prompt, tools, memory files, etc. not captured in current_usage
FUDGE_FACTOR=43000

# Debug mode: Set to 1 to write input JSON to debug file
# Toggle manually: DEBUG_STATUSLINE=0 (off) or DEBUG_STATUSLINE=1 (on)
DEBUG_STATUSLINE=0
DEBUG_FILE="$HOME/.claude/statusline-input.json"

input=$(cat)

# Write debug output if enabled
if [ "$DEBUG_STATUSLINE" -eq 1 ]; then
  echo "$input" | jq '.' > "$DEBUG_FILE" 2>/dev/null
fi

# ---- Color helpers ----
use_color=1
[ -n "$NO_COLOR" ] && use_color=0

green() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;158m'; fi; }
yellow() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;215m'; fi; }
red() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;203m'; fi; }
cyan() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;117m'; fi; }
gray() { if [ "$use_color" -eq 1 ]; then printf '\033[38;5;249m'; fi; }
rst() { if [ "$use_color" -eq 1 ]; then printf '\033[0m'; fi; }

# ---- Check for jq ----
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not installed"
  exit 1
fi

# ==========================================
# LINE 1: CORE INFO
# ==========================================

# Directory
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "N/A"' | sed "s|^$HOME|~|g")

# Git branch
git_branch=$(git branch --show-current 2>/dev/null || echo "no-git")

# CC version
version=$(echo "$input" | jq -r '.version // "N/A"')

# Model
model_display=$(echo "$input" | jq -r '.model.display_name // "N/A"')

printf '📁 %s%s%s  🌿 %s  📟 %s  🤖 %s\n' \
  "$(cyan)" "$current_dir" "$(rst)" "$git_branch" "$version" "$model_display"

# ==========================================
# LINE 2: NATIVE CLAUDE METRICS
# ==========================================

# Token counts - use current_usage to approximate context window
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
usage=$(echo "$input" | jq '.context_window.current_usage')

if [ "$usage" != "null" ] && [ "$window_size" -gt 0 ]; then
  current_tokens=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
else
  current_tokens=0
fi

# Always add fudge factor for system overhead (memory files, tools, etc.)
current_tokens=$((current_tokens + FUDGE_FACTOR))
pct=$(( current_tokens * 100 / window_size ))

# Format in K
current_k=$((current_tokens / 1000))
window_k=$((window_size / 1000))

# Progress bar (20 blocks)
filled=$(( pct * 20 / 100 ))
empty=$(( 20 - filled ))
bar="$(printf '█%.0s' $(seq 1 $filled) 2>/dev/null)$(printf '░%.0s' $(seq 1 $empty) 2>/dev/null)"

# Color based on percentage
if [ "$pct" -gt 90 ]; then
  pct_color=$(red)
elif [ "$pct" -gt 75 ]; then
  pct_color=$(yellow)
else
  pct_color=$(green)
fi


# Cost
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Duration (convert ms to hr + min)
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
duration_min=$((duration_ms / 60000))
duration_hr=$((duration_min / 60))
duration_min_remainder=$((duration_min % 60))

# Lines changed
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

printf '📊 %s%dK / %dK = %d%% %s%s %s  💰 $%.2f  ⏱️  %dh %dm  📝 +%d -%d\n' \
  "$pct_color" "$current_k" "$window_k" "$pct" "$bar" "$(rst)" "$compaction_badge" \
  "$total_cost" "$duration_hr" "$duration_min_remainder" "$lines_added" "$lines_removed"

# ==========================================
# LINE 3: CCUSAGE (5HR LIMITS & BURN RATE)
# ==========================================

# DISABLED FOR NOW - uncomment to re-enable
# if command -v ccusage >/dev/null 2>&1; then
#   echo -n "$input" | ccusage statusline --cost-source auto --visual-burn-rate emoji-text --context-low-threshold 60 --context-medium-threshold 90
# else
#   printf '%sccusage not installed%s\n' "$(yellow)" "$(rst)"
# fi
