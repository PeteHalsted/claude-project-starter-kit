---
name: gitpro
description: ALWAYS use this skill for ALL git operations. NEVER run git commit, git add, git push, git merge, git checkout -b, or git branch -m directly. This skill automates git workflows with conventional commits, automatic changelog updates, semantic version bumping, and consistent formatting. Use when user requests checkpoint, commit, rename branch, merge, or create new branch operations.
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
6. **CRITICAL**: Prefix ALL git commands with `GITPRO_RUNNING=1` to bypass the git-guard hook (e.g., `GITPRO_RUNNING=1 git add -A`)

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
- **"merge"** or **"merge the branch"** - Complete merge workflow
- **"create new branch"** or **"create branch called X"** - Branch creation

## Core Operations

### Checkpoint - Quick Safety Commit

Create fast timestamped commits during active work without analysis overhead.

**When to use:**
- User says "checkpoint" or "do a checkpoint" - Quick timestamped commit only
- AI agents completing phases - Custom message with timestamp

**Execution steps:**
1. Run `git status` to check staged files
2. If no files staged, run `GITPRO_RUNNING=1 git add -A` to stage all changes
3. If nothing to commit, exit with message "No changes to checkpoint"
4. Execute `bash ~/.claude/skills/gitpro/scripts/get_timestamp.sh` to get local timezone timestamp
5. Determine commit message format:
   - **If invoked by user manually**: `[timestamp] Checkpoint`
   - **If invoked by AI with custom message**: `[custom message] - [timestamp]`
6. Run `GITPRO_RUNNING=1 git commit -m "[message]"` with appropriate format
7. Report success to user

**Key characteristics:**
- No diff analysis required
- No changelog updates
- No conventional commit format
- Fast execution for frequent use during development
- Optional custom message prefix for workflow automation

**Example outputs:**
- Manual: `2025-10-29_16:23.45 Checkpoint`
- With message: `Phase 3.1: Setup - 2025-10-29_16:23.45`
- With message: `Pre-tasks baseline - 2025-10-29_16:23.45`

### Commit - Comprehensive Conventional Commit

Create full conventional commits with changelog integration and proper formatting.

**When to use:** User says "commit" or "do a commit"

**Execution steps:**
1. Run `git status` to check current state
2. Run `GITPRO_RUNNING=1 git add -A` to stage ALL changes (modifications, additions, deletions)
3. Run `git diff --staged` to understand what is being committed
4. **Conditional changelog update:**
   - Check if `changelog.md` exists in the repository root
   - **If changelog.md exists:**
     - Read first 30-50 lines to understand date format and entry pattern
     - Add new entry at top for today's date following the established pattern
     - Summarize the staged changes (already known from step 3's diff analysis)
     - Run `GITPRO_RUNNING=1 git add changelog.md` to stage the updated changelog
   - **If changelog.md does NOT exist:**
     - Skip changelog update
     - Add note to final report: "No changelog updated (changelog.md not found in repository)"
5. Analyze all changes to determine appropriate commit type
6. Load `~/.claude/skills/gitpro/references/commit-types.md` for commit format guidance
7. Create comprehensive commit message using format: `<emoji> <type>: <description>`
8. **Version bumping (hotfix exception):**
   - Check current branch with `git branch --show-current`
   - **If on `main` branch AND commit is a fix/hotfix:**
     - Run `cd apps/web && npm version patch` to bump version
     - This auto-commits version change and creates git tag
   - **Otherwise:** Skip version bumping (only done during merge workflow)
9. Run `GITPRO_RUNNING=1 git commit -m "<message>"` to commit everything together (if version not already committed)
10. **Automatic push (non-main branches only):**
   - Get current branch with `git branch --show-current`
   - **If NOT on `main` branch:**
     - Run `GITPRO_RUNNING=1 git push` (or `GITPRO_RUNNING=1 git push -u origin [branch-name]` if no upstream)
     - Report successful commit and push to user
   - **If on `main` branch:**
     - Skip automatic push to prevent unintended CI/CD triggers
     - Report successful commit with reminder to manually push when ready
11. Report success to user with commit message, push status, and changelog update status

**Key characteristics:**
- Commits ALL changes together (no logical splitting)
- Changelog included in same commit (if changelog.md exists in repository)
- Uses conventional commit format with emojis
- Comprehensive commit messages
- **Hotfix exception:** Version bumps on `main` for fixes/hotfixes only
- **Auto-push:** Automatically pushes to remote after commit (non-main branches only)
- **Main branch safety:** Skips auto-push on `main` to prevent unintended CI/CD triggers

**Example output:** `✨ feat: add user authentication with JWT tokens`

### Rename Branch - Intelligent Branch Naming

Rename current branch based on actual work being done.

**When to use:** User says "rename branch" or "rename the branch to X"

**Execution steps:**
1. If user provided explicit name, skip to step 4
2. Run `git diff main...HEAD` to see what changed
3. Analyze changed files to determine descriptive branch name using kebab-case
4. Run `GITPRO_RUNNING=1 git branch -m [new-branch-name]` to rename
5. Run `git branch` to verify the rename
6. Report new branch name to user

**Branch naming convention:** Use kebab-case descriptive names (e.g., `client-onboarding-and-billing`, `fix-auth-redirect`, `feature-dashboard`)

### Merge - Complete Merge Workflow

Execute full merge workflow from commit through version bumping and creating new working branch.

**When to use:** User says "merge" or "merge the branch"

**Execution steps:**
1. Run `git status` to check for uncommitted changes
2. If changes exist, execute full Commit workflow first
3. Get current branch name with `git branch --show-current`
4. Run `GITPRO_RUNNING=1 git push origin [current-branch]` to push current branch
5. Run `git checkout main` to switch to main
6. Run `git pull` to update main
7. Run `GITPRO_RUNNING=1 git merge [current-branch]` to merge
8. **Intelligent version bumping:**
   - Run `git log --oneline main~10..main` to analyze recent commits
   - Determine version bump type by examining commit messages:
     - **Major bump** if any commit contains: `BREAKING CHANGE`, exclamation mark (!) after type, or `major` in description
     - **Minor bump** if any commit contains: `feat:`, `✨`, or `feature` indicators
     - **Patch bump** otherwise (fixes, chores, docs, refactors)
   - Run `cd apps/web && npm version [major|minor|patch]` based on analysis
   - This automatically commits version change and creates git tag
9. Run `GITPRO_RUNNING=1 git push && GITPRO_RUNNING=1 git push --tags` to push merged main with version tag
10. **Create fresh working-title branch (with safety check):**
   - Check if `working-title` branch exists: `git branch --list working-title`
   - **If working-title exists:**
     - Check for unmerged commits: `git branch --no-merged main`
     - **If working-title has unmerged commits:**
       - STOP and report error: "⚠️ Cannot create working-title: existing branch has unmerged commits. Please rename, merge, or delete the old branch first."
       - Exit merge workflow (main is already merged and pushed successfully)
     - **If working-title is fully merged:**
       - Delete old branch: `GITPRO_RUNNING=1 git branch -D working-title`
       - Log: "Deleted old working-title branch (fully merged to main)"
   - Create fresh working-title from current main: `GITPRO_RUNNING=1 git checkout -b working-title`
   - Report: "✅ Created fresh working-title branch from main"
11. Report success with summary of operations including version bump and new working branch

**Result:** Clean merge to main with automatic semantic version bump and fresh `working-title` branch ready for next feature.

### New Branch - Create Working Branch

Create new branch with specified or default name.

**When to use:** User says "create new branch" or "create branch called X"

**Execution steps:**
1. Run `git status` to check for uncommitted changes
2. If changes exist, ask user: "There are uncommitted changes. Commit or checkpoint first? (commit/checkpoint/continue)"
3. If user chooses commit, execute Commit workflow
4. If user chooses checkpoint, execute Checkpoint workflow
5. Determine branch name: use provided name or default to `working-title`
6. Run `GITPRO_RUNNING=1 git checkout -b [branch-name]` to create and switch
7. Run `GITPRO_RUNNING=1 git push -u origin [branch-name]` to push and track
8. Report success with new branch name

**Default branch name:** `working-title`

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
