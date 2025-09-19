---
description: Create a checkpoint with  git commits 
category: version-control-git
allowed-tools: Bash, Read, Glob
source: https://github.com/PeteHalsted/claude-project-starter-kit
---

# Claude Command: CheckPoint

This command helps you create checkpoint by doing commit.

## Usage

To create a checkpoint, just type:
```
/checkpoint
```


## What This Command Does

1. Checks which files are staged with `git status`
2. If 0 files are staged, automatically adds all modified and new files with `git add`
3. Of there is nothing to commit do nothing
3. Creates a commit message using "YYYY-MM-DD_HH:MM.SS Checkpoint"
4. Perform the commit 
