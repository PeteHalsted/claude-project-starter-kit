## CRITICAL: Git Reset/Checkout/Revert Forbidden

**ABSOLUTE RULE**: You are FORBIDDEN from running ANY of these commands without EXPLICIT user instruction:
- `git checkout <file>` - Reverts file changes
- `git reset` - Resets commits or staging
- `git revert` - Reverts commits
- `git restore` - Restores working tree files
- `git clean` - Removes untracked files

**Why This Rule Exists**: These commands DESTROY WORK. You have repeatedly used `git checkout` to "fix" mistakes, which instead deleted hours of completed work.

**What To Do Instead**:
- If you make a mistake in a file: Use Read/Edit/Write tools to fix it
- If you're unsure about changes: Ask the user what they want
- If the user says "stop": STOP. Do not touch anything
- NEVER assume reverting code is the solution

**ONLY Exception**: User explicitly says "revert the file" or "checkout the file" or "reset the changes"

**Violation Consequences**: Using these commands without explicit instruction is a CRITICAL ERROR equivalent to data loss.

## Proactive Use of Subagents and Skills

**Use subagents and skills proactively** to improve efficiency, preserve context, and leverage specialized capabilities:

### When to Use Subagents:
- **Codebase exploration**: Use `Explore` agent for understanding structure, finding patterns, or answering architectural questions
- **Isolated investigations**: Launch agents for self-contained tasks to preserve main conversation context
- **Parallel work**: Use `dispatching-parallel-agents` skill when multiple independent tasks can run concurrently
- **Planning**: Use `Plan` agent for breaking down complex features
- **Code review**: Use `requesting-code-review` skill after completing major work

### When to Use Skills:
- **Debugging workflows**: Use `systematic-debugging` or `root-cause-tracing` for structured investigation
- **Development workflows**: Use `subagent-driven-development` for spec-kit task execution
- **Documentation**: Use `feature-documentation-cleanup` after completing features
- **Git operations**: Use `gitpro` for ALL git operations (see ABSOLUTE RULE below)

**Principle**: Skills and agents handle their own orchestration. Trust them to dispatch subagents when beneficial. Use them proactively to save context, enable parallelism, and leverage specialized workflows.

## ABSOLUTE RULE: Git Operations via GitPro Skill ONLY

**FORBIDDEN**: You are FORBIDDEN from running ANY of these git commands directly:
- `git commit` - ALWAYS use gitpro skill instead
- `git add` - ALWAYS use gitpro skill instead (handles staging as part of workflow)
- `git push` - ALWAYS use gitpro skill instead (automatic after commits)
- `git merge` - ALWAYS use gitpro skill instead
- `git checkout -b` / `git switch -b` - ALWAYS use gitpro skill instead (branch creation)
- `git branch -m` - ALWAYS use gitpro skill instead (branch renaming)

**REQUIRED**: ALWAYS invoke the gitpro skill when user says:
- "commit" or "do a commit" → Invoke Skill tool: `{"skill": "gitpro"}`
- "checkpoint" or "do a checkpoint" → Invoke Skill tool: `{"skill": "gitpro"}`
- "merge" or "merge the branch" → Invoke Skill tool: `{"skill": "gitpro"}`
- "rename branch" or "rename the branch to X" → Invoke Skill tool: `{"skill": "gitpro"}`
- "create new branch" or "create branch called X" → Invoke Skill tool: `{"skill": "gitpro"}`

**Why This Rule Exists**: The gitpro skill ensures:
- Conventional commit format with emojis (e.g., `✨ feat:`, `🐛 fix:`)
- Automatic changelog updates (reads format, adds entry for today)
- Proper semantic version bumping (analyzes commits for major/minor/patch)
- Automatic push to remote (non-main branches)
- Consistent workflow across all git operations
- Single source of truth for git workflows

**Violation Consequences**: 
- Bypassing gitpro breaks changelog tracking
- Skips version management
- Loses conventional commit format
- Creates inconsistent git history
- **PreToolUse hook will BLOCK these operations** - you will receive a denial message

**Emergency Override**: If gitpro skill has a bug and you need to bypass:
1. Request user to set environment variable: `SKIP_GIT_GUARD=1`
2. Only then run git commands directly
3. Immediately inform user that gitpro was bypassed and why

**Read-Only Operations ALLOWED** (without gitpro):
- `git status` - Check repository state
- `git log` - View commit history
- `git diff` - View changes
- `git show` - Show commit details
- `git branch` - List branches (without flags)
- `git fetch` - Fetch from remote
- `git stash` - Stash changes temporarily

**ONLY Exception**: User explicitly instructs you to use direct git commands (extremely rare edge cases).
