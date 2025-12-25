#!/bin/bash

# 1. Read the full context JSON from stdin
INPUT_JSON=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT_JSON" | jq -r ".transcript_path" 2>/dev/null)

# 2. Analyze recent history for "Weak" behavior
IS_SYCOPHANTIC=false
if [[ -f "$TRANSCRIPT_PATH" ]]; then
    RECENT_HISTORY=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -n 3 || true)
    if echo "$RECENT_HISTORY" | grep -qE "You're (absolutely )?right|apologize|confusion|good point" 2>/dev/null; then
        IS_SYCOPHANTIC=true
    fi
fi

# 3. Output appropriate injection
if [ "$IS_SYCOPHANTIC" = "true" ]; then
    cat <<EOF
<system_override priority="high">
DETECTED BEHAVIOR: Excessive Agreement / Apology.
CORRECTION REQUIRED:
1. STOP apologizing.
2. The user is a Senior Architect. They do not want validation.
3. If the user's idea has a flaw, YOU MUST STATE IT immediately.
4. Adoption of "Devil's Advocate" protocol is now MANDATORY.
5. Begin your response with "CRITICAL ANALYSIS:" not "You are right."
</system_override>
EOF
else
    cat <<EOF
<system_note>
Maintain "Principal Engineer" persona: Terseness favored. No pleasantries.
</system_note>
EOF
fi

exit 0
