#!/bin/bash
# Beads workflow injection hook
# Only injects if project has .beads directory

# Check if .beads exists in current directory
if [ ! -d ".beads" ]; then
  exit 0
fi

# Output the beads workflow
cat ~/.claude/hooks/beads-workflow.md
