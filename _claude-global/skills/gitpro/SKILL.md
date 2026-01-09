---
name: gitpro
description: ALWAYS use this skill for ALL git operations. NEVER run git commit, git add, git push, git merge, git checkout -b, or git branch -m directly. This skill automates git workflows with conventional commits, automatic changelog updates, semantic version bumping, and consistent formatting. Use when user requests checkpoint, commit, rename branch, merge, or create new branch operations.
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: ~/.claude/skills/gitpro/scripts/create-token.sh
          timeout: 5
---

# GitPro

Git workflow automation for common operations with intelligent defaults and best practices.

## CRITICAL: Skill Execution Rules

**When this skill is invoked, you MUST:**
1. Follow the execution steps EXACTLY as documented - do NOT improvise or use direct git commands
2. Use the skill's base directory for all resources: `~/.claude/skills/gitpro/`
3. Execute steps sequentially as written in each workflow
4. Use the provided scripts and references from the base directory
5. Report progress and results as the skill, not as Claude running bash commands

**FORBIDDEN while executing this skill:**
- Running `git commit` directly instead of following the workflow
- Skipping steps or improvising "faster" alternatives
- Using relative paths for scripts (always use full base directory path)
- Abandoning the skill workflow to "just do it yourself"

**Base Directory**: `~/.claude/skills/gitpro/`

Git workflow automation for common operations with intelligent defaults and best practices.

## Quick Start

Invoke this skill when the user requests:
- **"checkpoint"** or **"do a checkpoint"** - Quick timestamped safety commit
- **"commit"** or **"do a commit"** - Full conventional commit with changelog
- **"rename branch"** or **"rename the branch to X"** - Intelligent branch renaming
- **"merge to main"** - Merge current branch to main with version bump
- **"merge from X"** - Merge branch X into current branch
- **"merge"** alone - Ask for clarification (to main or from branch?)
- **"create new branch"** or **"create branch called X"** - Branch creation

## Core Operations

### Checkpoint - Quick Safety Commit

Create fast timestamped commits during active work without analysis overhead.

**When to use:**
- User says "checkpoint" or "do a checkpoint" - Quick timestamped commit only
- AI agents completing phases - Custom message with timestamp

**Execution steps:**
1. Run `git status` to check staged files
2. If no files staged, run `git add -A` to stage all changes
3. If nothing to commit, exit with message "No changes to checkpoint"
4. Execute `bash ~/.claude/skills/gitpro/scripts/get_timestamp.sh` to get local timezone timestamp
5. Determine commit message format:
   - **If invoked by user manually**: `[timestamp] Checkpoint`
   - **If invoked by AI with custom message**: `[custom message] - [timestamp]`
6. **Bead notes update (if active-now bead exists):**
   - Check if `.beads/` directory exists in repository root
   - **If .beads/ exists:**
     - Run `bd list --label active-now --json 2>/dev/null | jq -r '.[0].id // empty'` to get active bead ID
     - **If active bead exists:**
       - Update notes with current status using format:
         ```
         Working: [brief description of current work]
         File: [primary file being modified]
         Last: [what was just checkpointed]
         Next: [immediate next step if known]
         ```
       - Run `bd update <bead-id> --notes "<status>"`
       - Report: "Updated bead <bead-id> notes"
     - **If no active bead:** Skip silently
   - **If .beads/ does not exist:** Skip this step
7. Run `git commit -m "[message]"` with appropriate format   
8. Report success to user

**Key characteristics:**
- No diff analysis required
- No changelog updates
- No conventional commit format
- No TypeScript or toast validation (speed over compliance)
- Fast execution for frequent use during development
- Optional custom message prefix for workflow automation
- **Bead notes:** Auto-updates active-now bead with current status

**Example outputs:**
- Manual: `2025-10-29_16:23.45 Checkpoint`
- With message: `Phase 3.1: Setup - 2025-10-29_16:23.45`
- With message: `Pre-tasks baseline - 2025-10-29_16:23.45`

### Commit - Comprehensive Conventional Commit

Create full conventional commits with changelog integration and proper formatting.

**When to use:** User says "commit" or "do a commit"

**Execution steps:**
1. Run `git status` to check current state
2. **Beads sync (pre-commit):**
   - Check if `.beads/` directory exists in repository root
   - **If .beads/ exists:** Run `bd sync` to commit any pending beads changes
   - **If .beads/ does not exist:** Skip this step
3. Run `git add -A` to stage ALL changes (modifications, additions, deletions)
4. Run `git diff --staged --name-only` to get list of changed files
5. **Auto-rename wt-* branch (first meaningful commit):**
   - Get current branch: `git branch --show-current`
   - **If branch matches `wt-*` pattern** (e.g., `wt-petehalsted`):
     - Analyze staged changes to determine descriptive branch name using kebab-case
     - Store old branch name (the wt-* name)
     - Run `git branch -m [descriptive-name]` to rename locally
     - **Clean up old remote (if exists):**
       - Check: `git ls-remote --heads origin [old-wt-branch]`
       - If exists: `git push origin --delete [old-wt-branch]`
     - Report: "Auto-renamed: [old-wt-branch] → [descriptive-name]"
   - **Otherwise:** Skip (branch already has descriptive name)
6. **Conditional changelog update:**
   - Check if `changelog.md` exists in the repository root
   - **If changelog.md exists:**
     - Read first 30-50 lines to understand date format and entry pattern
     - Add new entry at top for today's date following the established pattern
     - Summarize the staged changes
     - Run `git add changelog.md` to stage the updated changelog
   - **If changelog.md does NOT exist:**
     - Skip changelog update
     - Add note to final report: "No changelog updated (changelog.md not found in repository)"
7. **TypeScript validation**: Handled by git pre-commit hook (zero tolerance). Gitpro does not duplicate this check.
8. **Code quality validation (toast check - WARNING only):**
   - Check if `package.json` contains a `lint:toast` script
   - **If lint:toast exists:**
     - Run `npm run lint:toast 2>&1 | head -20` to check for toast usage
     - **If violations found:** Report warning in commit output:
       ```
       ⚠️ TOAST USAGE DETECTED in staged files
       Toast messages are deprecated per Constitution Section XI.
       Consider migrating to contextual feedback patterns.
       See: project-documentation/contextual-feedback-over-toasts.md
       ```
     - Continue with commit (warning only, not blocking - progressive migration)
   - **If lint:toast does not exist:** Skip this check
9. Analyze all changes to determine appropriate commit type
10. Load `~/.claude/skills/gitpro/references/commit-types.md` for commit format guidance
11. Create comprehensive commit message using format: `<emoji> <type>: <description>`
12. **Version bumping (hotfix exception):**
    - Check current branch with `git branch --show-current`
    - **If on `main` branch AND commit is a fix/hotfix:**
      - Run `npm version patch --no-git-tag-version` to bump version (uses root package.json)
      - Capture new version from output
      - Run `git add package.json package-lock.json`
      - Include version files in the commit (step 14)
      - Run `git tag [version]` after commit
    - **Otherwise:** Skip version bumping (only done during merge workflow)
13. **Bead notes update (if active-now bead exists):**
    - Check if `.beads/` directory exists in repository root
    - **If .beads/ exists:**
      - Run `bd list --label active-now --json 2>/dev/null | jq -r '.[0].id // empty'` to get active bead ID
      - **If active bead exists:**
        - Analyze the committed changes to summarize current status
        - Update notes with current status using format:
          ```
          Working: [brief description of current work]
          File: [primary file(s) modified in this commit]
          Last: [summary of what was just committed]
          Next: [immediate next step if known, or "Ready for testing" if work complete]
          ```
        - Run `bd update <bead-id> --notes "<status>"`
        - Report: "Updated bead <bead-id> notes"
      - **If no active bead:** Skip silently
    - **If .beads/ does not exist:** Skip this step    
14. Run `git commit -m "<message>"` to commit everything together (if version not already committed)
15. **Beads sync (post-commit):**
    - Check if `.beads/` directory exists in repository root
    - **If .beads/ exists:** Run `bd sync` to commit any beads changes made during the session
    - **If .beads/ does not exist:** Skip this step
16. **Automatic push (non-main branches only):**
    - Get current branch with `git branch --show-current`
    - **If NOT on `main` branch:**
      - Run `git push` (or `git push -u origin [branch-name]` if no upstream)
      - Report successful commit and push to user
    - **If on `main` branch:**
      - Skip automatic push to prevent unintended CI/CD triggers
      - Report successful commit with reminder to manually push when ready
17. Report success to user with commit message, push status, changelog update status, TypeScript status, beads sync status, bead notes update, branch rename (if applicable), and any toast warnings

**Key characteristics:**
- Commits ALL changes together (no logical splitting)
- Changelog included in same commit (if changelog.md exists in repository)
- Uses conventional commit format with emojis
- Comprehensive commit messages
- **Auto-rename:** Automatically renames `wt-*` branches to descriptive names on first commit
- **TypeScript validation:** Handled by git pre-commit hook (zero tolerance)
- **Toast validation:** Warns about deprecated toast usage (non-blocking)
- **Beads sync:** Automatic pre/post-commit sync (if .beads/ exists)
- **Bead notes:** Auto-updates active-now bead with current status summary
- **Hotfix exception:** Version bumps on `main` for fixes/hotfixes only
- **Auto-push:** Automatically pushes to remote after commit (non-main branches only)
- **Main branch safety:** Skips auto-push on `main` to prevent unintended CI/CD triggers

**Example output:** `✨ feat: add user authentication with JWT tokens`

### Rename Branch - Intelligent Branch Naming

Rename current branch based on actual work being done.

**When to use:** User says "rename branch" or "rename the branch to X"

**Execution steps:**
1. Store current branch name: `git branch --show-current` (needed for remote cleanup)
2. If user provided explicit name, skip to step 5
3. Run `git diff main...HEAD` to see what changed
4. Analyze changed files to determine descriptive branch name using kebab-case
5. Run `git branch -m [new-branch-name]` to rename locally
6. **Clean up old remote branch (if exists):**
   - Check if old branch exists on remote: `git ls-remote --heads origin [old-branch-name]`
   - **If exists:** Run `git push origin --delete [old-branch-name]`
   - Report: "Deleted old remote branch: [old-branch-name]"
7. **Push new branch with tracking:**
   - Run `git push -u origin [new-branch-name]`
8. Run `git branch -vv` to verify rename and tracking
9. Report: "Renamed: [old-branch-name] → [new-branch-name] (tracking origin)"

**Branch naming convention:** Use kebab-case descriptive names (e.g., `client-onboarding-and-billing`, `fix-auth-redirect`, `feature-dashboard`)

### Merge to Main - Complete Merge Workflow

Execute full merge workflow from commit through version bumping, branch cleanup, and creating new working branch.

**CRITICAL** This workflow must only push changes once when completely finished. If you push changes multiple times, you may trigger multiple CI/CD pipelines that will conflict and cause a failure!

**When to use:** User says "merge to main"

**If user says just "merge":** Ask for clarification: "Do you want to merge to main, or merge from another branch?"

**Execution steps:**
1. Get username for branch naming: `GITPRO_USER=$(whoami)` - used for `wt-${GITPRO_USER}` branch
2. Run `git status` to check for uncommitted changes
3. If changes exist, execute full Commit workflow first (includes TypeScript validation)
4. Get current branch name with `git branch --show-current`
5. Run `git push origin [current-branch]` to push current branch
6. Run `git checkout main` to switch to main
7. Run `git pull` to update main
8. Run `git merge [current-branch]` to merge
9. **Intelligent version bumping (MUST COMPLETE BEFORE PUSH):**
   - Run `git log --oneline main~10..main` to analyze recent commits
   - Determine version bump type by examining commit messages:
     - **Major bump** if any commit contains: `BREAKING CHANGE`, exclamation mark (!) after type, or `major` in description
     - **Minor bump** if any commit contains: `feat:`, `✨`, or `feature` indicators
     - **Patch bump** otherwise (fixes, chores, docs, refactors)
   - **Bump version (uses root package.json as single source of truth):**
     - Run `npm version [major|minor|patch] --no-git-tag-version` to bump version
     - Capture the new version number from output (e.g., `v1.5.1`)
   - **Explicitly commit version bump:**
     - Run `git add package.json package-lock.json`
     - Run `git commit -m "🔖 chore: bump version to [version]"`
     - Run `git tag [version]` (e.g., `v1.5.1`)
   - **WAIT for this step to complete before proceeding to step 10**
10. **Push main WITH version bump (after step 9 completes):**
    - Run `git push` to push main (includes merge commit AND version bump commit)
    - Run `git push --tags` to push version tags
    - **CRITICAL:** Both the merge AND the version bump commit must be included in the push
11. **Delete merged source branch (cleanup):**
    - Store the source branch name from step 4 (the branch that was merged)
    - Verify branch is merged: `git branch --merged main | grep [source-branch]`
    - **If verified merged:**
      - Delete local branch: `git branch -d [source-branch]`
      - Delete remote branch: `git push origin --delete [source-branch]`
      - Report: "🗑️ Deleted merged branch: [source-branch]"
    - **If NOT verified merged:** Skip deletion with warning (safety first)
12. **Create fresh user working branch (with safety check):**
    - Check if `wt-${GITPRO_USER}` branch exists: `git branch --list wt-${GITPRO_USER}`
    - **If wt-${GITPRO_USER} exists:**
      - Check for unmerged commits: `git branch --no-merged main`
      - **If wt-${GITPRO_USER} has unmerged commits:**
        - STOP and report error: "⚠️ Cannot create wt-${GITPRO_USER}: existing branch has unmerged commits. Please rename, merge, or delete the old branch first."
        - Exit merge workflow (main is already merged and pushed successfully)
      - **If wt-${GITPRO_USER} is fully merged:**
        - **Check for beads worktree blocking deletion:**
          - Run `git worktree list | grep wt-${GITPRO_USER}` to check if worktree exists
          - If worktree exists: Run `git worktree remove .git/beads-worktrees/wt-${GITPRO_USER} --force 2>/dev/null || true`
        - Delete old branch: `git branch -D wt-${GITPRO_USER}`
        - Log: "Deleted old wt-${GITPRO_USER} branch (fully merged to main)"
    - Create fresh branch from current main: `git checkout -b wt-${GITPRO_USER}`
    - Push with upstream tracking: `git push -u origin wt-${GITPRO_USER}`
    - Report: "✅ Created fresh wt-${GITPRO_USER} branch from main (tracking origin)"
13. Report success with summary of operations including version bump, branch cleanup, and new working branch

**Result:** Clean merge to main with semantic version bump (single push includes both merge and version commits), source branch cleanup, plus fresh `wt-${GITPRO_USER}` branch ready for next feature (pushed with tracking).

**Key characteristics:**
- Single push to main (merge commit + version bump commit together)
- Explicit git commands for version bump (monorepo-compatible, doesn't rely on npm auto-commit)
- Automatic semantic version analysis from commit messages
- **Branch cleanup:** Deletes merged source branch (local and remote) after successful merge
- Fresh user-specific working branch (`wt-${username}`) created from updated main and pushed with tracking
- **Multi-user safe:** Each user gets their own working branch (e.g., `wt-pete`, `wt-john`)
- **Beads worktree cleanup:** Removes any beads worktrees that block branch deletion

### Merge from Branch - Pull Changes into Current Branch

Merge another branch into your current working branch. Useful for pulling in cloud session work or getting updates from main.

**When to use:** User says "merge from X" where X is a branch name

**If user says just "merge":** Ask for clarification: "Do you want to merge to main, or merge from another branch?"

**Execution steps:**
1. Get current branch name: `git branch --show-current`
2. Run `git fetch origin` to ensure we have latest remote refs
3. Determine source branch:
   - If user specified a branch name, use it
   - Check if it exists locally: `git branch --list [branch]`
   - Check if it exists on remote: `git branch -r --list origin/[branch]`
   - **If branch not found:** Report error and exit
4. Run `git merge origin/[branch]` (or local branch if no remote)
5. **If merge conflicts:**
   - Report: "⚠️ Merge conflicts detected. Please resolve conflicts and run 'commit' when ready."
   - Exit workflow (user must resolve manually)
6. **If merge successful:**
   - Report: "✅ Merged [branch] into [current-branch]"
7. **Branch deletion prompt (unless protected):**
   - **If source branch is `main` or `master`:** Skip deletion entirely (never prompt)
   - **Otherwise:** Ask user: "Delete branch [branch]? (y/n)"
   - **If user confirms yes:**
     - Delete local branch (if exists): `git branch -d [branch]`
     - Delete remote branch (if exists): `git push origin --delete [branch]`
     - Report: "🗑️ Deleted branch: [branch]"
   - **If user says no:** Skip deletion
8. Report success with summary

**Key characteristics:**
- Fetches latest remote state before merging
- Handles both local and remote branches
- **Protected branches:** Never offers to delete `main` or `master`
- **Optional cleanup:** Prompts for deletion of non-protected source branches
- **Conflict handling:** Exits gracefully if conflicts occur, user resolves manually
- No version bumping (that only happens in merge-to-main)
- No changelog updates

**Example usage:**
- `merge from claude/analyze-open-beads-U93jg` - Pull cloud session work
- `merge from main` - Get latest main updates (never prompts for deletion)
- `merge from feature-x` - Pull another feature branch (prompts for deletion)

### New Branch - Create Working Branch

Create new branch with specified or default name.

**When to use:** User says "create new branch" or "create branch called X"

**Execution steps:**
1. Get username for default branch naming: `GITPRO_USER=$(whoami)`
2. Run `git status` to check for uncommitted changes
3. If changes exist, ask user: "There are uncommitted changes. Commit or checkpoint first? (commit/checkpoint/continue)"
4. If user chooses commit, execute Commit workflow
5. If user chooses checkpoint, execute Checkpoint workflow
6. Determine branch name: use provided name or default to `wt-${GITPRO_USER}`
7. Run `git checkout -b [branch-name]` to create and switch
8. Run `git push -u origin [branch-name]` to push and track
9. Report success with new branch name

**Default branch name:** `wt-${username}` (e.g., `wt-pete`, `wt-john`)

## Validation Summary

| Check | Checkpoint | Commit | Merge to Main | Merge from X |
|-------|------------|--------|---------------|--------------|
| TypeScript errors | Skip | Via pre-commit hook | Via pre-commit hook | Skip |
| Toast usage | Skip | Warning | Via Commit | Skip |
| Changelog update | Skip | Yes | Via Commit | Skip |
| Beads sync | Skip | If .beads/ exists | Via Commit | Skip |
| Bead notes update | If active-now exists | If active-now exists | Via Commit | Skip |
| Version bump | Skip | Hotfix only | Yes | Skip |
| Branch cleanup | Skip | Skip | Auto (source branch) | Prompt (unless main/master) |
| Auto-rename wt-* | Skip | Yes (first commit) | Via Commit | Skip |

## Available Tools

### GitHub CLI (`gh`)

Verified available commands:
- `gh repo view` - View repository information
- `gh issue list` - List issues
- `gh pr list` - List pull requests
- `gh pr create` - Create pull request
- Full authentication confirmed with proper token scopes

Use GitHub CLI commands when operations require GitHub API interaction beyond basic git operations.

### Helper Scripts

**scripts/get_timestamp.sh**
- Returns local timezone timestamp in format: `YYYY-MM-DD_HH:MM.SS`
- Used for checkpoint commits
- Execute with: `bash ~/.claude/skills/gitpro/scripts/get_timestamp.sh`

## References

**references/commit-types.md**
- Conventional commit types with emojis
- Commit format guidelines
- Best practices for commit messages
- Load when creating commits for format reference
