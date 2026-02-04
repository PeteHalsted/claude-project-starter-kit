# Async Hooks Analysis for Claude Code Starter Kit

**Date:** 2026-02-04
**Scope:** All hooks in `_claude-global/hooks/` and `_git-hooks-project/`
**Reference:** [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)

---

## How `async: true` Works

Added in Claude Code 2.1.0, the `async: true` option on command hooks (`type: "command"` only) runs the hook in a background process instead of blocking Claude's execution.

### Key Behaviors

- **Non-blocking:** Claude continues working immediately; it does not wait for the hook to finish.
- **No decision control:** Response fields like `decision`, `permissionDecision`, and `continue` have **no effect** because the action they would have controlled has already completed by the time the hook finishes.
- **Output delivery is deferred:** If the hook produces a JSON response with `systemMessage` or `additionalContext`, that content is delivered to Claude on the **next conversation turn**.
- **No deduplication:** Each firing creates a separate background process. If the same async hook fires 10 times, 10 processes run.
- **Only for command hooks:** Prompt-based (`type: "prompt"`) and agent-based (`type: "agent"`) hooks cannot be async.
- **Snapshot isolation:** Hooks are snapshotted at session startup. Mid-session edits to hook config do not take effect until the next session.

### Configuration

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write",
      "hooks": [{
        "type": "command",
        "command": "./my-script.sh",
        "async": true,
        "timeout": 120
      }]
    }]
  }
}
```

### Ideal Use Cases

- Logging and metrics collection
- Notifications (Slack, desktop alerts, etc.)
- Memory/knowledge-base storage operations
- Background test runners (informational, not gating)
- Any side-effect where the result does not need to influence Claude's next action

### Anti-patterns (Never Use Async For)

- **Blocking dangerous commands** (the command will have already executed)
- **Permission decisions** (`permissionDecision` is ignored on async hooks)
- **Prompt validation** (the prompt will have already been processed)
- **Any hook whose purpose is to PREVENT an action**

---

## Hook Inventory and Analysis

### Settings Configuration Summary

All hooks are configured in `_claude-global/settings.json`. The current configuration uses these hook events:

| Event | Hooks Registered |
|-------|-----------------|
| `SessionStart` | beads-inject.sh |
| `PreCompact` | beads-inject.sh |
| `UserPromptSubmit` | architect_enforcer.sh, active-now-reminder.sh |
| `PreToolUse` (Bash) | block-db-commands.sh, git-guard.sh, dev-server-guard.sh |
| `PreToolUse` (mcp__acp__Bash) | block-db-commands.sh, git-guard.sh, dev-server-guard.sh |
| `PreToolUse` (Edit) | block-console-log.sh |
| `PreToolUse` (Write) | block-console-log.sh |
| `PreToolUse` (Skill) | pre-gitpro.sh |
| `Stop` | bead-comment-reminder.sh |

**None currently use `async: true`.** All are synchronous and blocking.

---

### Per-Hook Analysis

#### 1. `architect_enforcer.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `UserPromptSubmit` |
| **Purpose** | Analyzes recent transcript for sycophantic behavior (excessive agreement, apologies). Injects a "Principal Engineer" persona correction or maintenance prompt into context. |
| **Mechanism** | Reads transcript, greps for sycophantic patterns, outputs system-level context injection via stdout (exit 0). |
| **Currently Blocking?** | Yes (synchronous), but it never blocks the prompt -- it always exits 0 and just adds context. |
| **Async Candidate?** | NO |
| **Reasoning** | The hook's entire purpose is to inject context *before* Claude processes the user's prompt. If run async, the context would arrive on the *next* turn, making it useless for influencing the current response. The hook is also fast (reads a file, greps 3 lines) with a 5s timeout. No benefit to making it async. |

#### 2. `active-now-reminder.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `UserPromptSubmit` |
| **Purpose** | Checks if there is an `active-now` bead claimed in a beads project. If not, injects a reminder to claim one before making code changes. |
| **Mechanism** | Runs `bd list --label active-now --json`, checks count, outputs reminder via stdout (exit 0). |
| **Currently Blocking?** | Yes (synchronous), but never blocks the prompt -- always exits 0. |
| **Async Candidate?** | NO |
| **Reasoning** | Same as architect_enforcer: the reminder must appear *before* Claude starts working on the current prompt, or it defeats the purpose. If async, Claude would start coding without a bead, then get a "you forgot to claim a bead" message after the fact. The `bd list` command is fast. No benefit. |

#### 3. `beads-inject.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `SessionStart`, `PreCompact` |
| **Purpose** | Injects the beads workflow documentation (from `beads-workflow.md`) into Claude's context at session start and before compaction. Only activates if `.beads/` directory exists. |
| **Mechanism** | Checks for `.beads/` directory, cats the workflow markdown file to stdout (exit 0). |
| **Currently Blocking?** | Yes (synchronous), but never blocks -- always exits 0 with context. |
| **Async Candidate?** | NO |
| **Reasoning** | Context injection at `SessionStart` and `PreCompact` must happen synchronously so Claude has the beads workflow knowledge *before* it starts processing. If async, the workflow docs would arrive a turn late, potentially after Claude has already violated beads conventions. The hook is also trivially fast (cat a small markdown file). |

#### 4. `block-db-commands.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `PreToolUse` (Bash, mcp__acp__Bash) |
| **Purpose** | **Safety-critical.** Blocks database migration commands (`db:generate`, `db:migrate`, `db:push`, `drizzle-kit`) from being executed by Claude. Enforces the constitutional rule that AI must never run drizzle commands. |
| **Mechanism** | Reads tool input, greps for DB commands, returns `permissionDecision: "deny"` if matched. |
| **Currently Blocking?** | Yes -- this is a hard blocker. Returns deny decision. |
| **Async Candidate?** | **ABSOLUTELY NOT** |
| **Reasoning** | This is a safety guardrail. Its entire purpose is to prevent the command from executing. If async, the database command would run unblocked, and the "deny" decision would be silently ignored. Making this async would completely disable the protection. |

#### 5. `git-guard.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `PreToolUse` (Bash, mcp__acp__Bash) |
| **Purpose** | **Safety-critical.** Enforces that all git write operations (add, commit, push, merge, branch creation) go through the `gitpro` skill. Blocks destructive git operations (reset, restore, revert, clean) entirely. Delegates non-standard operations (stash, cherry-pick, rebase, pull) to the user. |
| **Mechanism** | Parses compound commands, checks each git subcommand against whitelist/blocklist, returns `permissionDecision: "deny"` for violations. Supports token-based bypass when gitpro skill is active. |
| **Currently Blocking?** | Yes -- hard blocker with deny decisions. |
| **Async Candidate?** | **ABSOLUTELY NOT** |
| **Reasoning** | This is the most comprehensive safety hook in the kit. It prevents destructive git operations and enforces workflow discipline. If async, `git reset --hard`, `git push --force`, or unauthorized commits would execute unblocked. This would be catastrophic. |

#### 6. `dev-server-guard.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `PreToolUse` (Bash, mcp__acp__Bash) |
| **Purpose** | **Safety-critical.** Prevents Claude from starting, killing, or restarting the development server. Enforces the protocol that the user manages the dev server. |
| **Mechanism** | Checks for `npm run dev`, `pkill.*vite`, etc. Returns `permissionDecision: "deny"` if matched. Has emergency override via `SKIP_SERVER_GUARD=1`. |
| **Currently Blocking?** | Yes -- hard blocker with deny decisions. |
| **Async Candidate?** | **ABSOLUTELY NOT** |
| **Reasoning** | Same pattern as the other safety hooks. The entire point is to prevent the command from executing. Async would render it useless: Claude would kill your dev server or start a conflicting one, then get a belated "oh you shouldn't have done that" message. |

#### 7. `block-console-log.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `PreToolUse` (Edit, Write) |
| **Purpose** | **Code quality enforcer.** Blocks Claude from writing `console.log/error/warn/info/debug` statements in TypeScript/JavaScript files for projects that use Pino for structured logging. |
| **Mechanism** | Checks for `pino` in package.json, then greps the content being written for console.* patterns. Returns `permissionDecision: "deny"` if found. |
| **Currently Blocking?** | Yes -- hard blocker with deny decisions. |
| **Async Candidate?** | **NO** |
| **Reasoning** | This prevents bad code from being written in the first place. If async, the console.log would be written to the file, and the hook's deny decision would be ignored. Claude would then need a separate cleanup step. The hook is also fast (string matching on already-available content) with a 5s timeout. |

#### 8. `pre-gitpro.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `PreToolUse` (Skill) |
| **Purpose** | **Quality gate.** Runs validation checks before the `gitpro` skill executes: TypeScript type checking, TODO tracking validation (beads), and toast usage checks. Blocks gitpro if validation fails. |
| **Mechanism** | Detects project type (Node/Python), runs type checker (`npm run check-types` or `pyright`/`mypy`), validates TODO comments against beads, checks toast usage. Returns `permissionDecision: "deny"` on failure. |
| **Currently Blocking?** | Yes -- hard blocker with deny decisions. Timeout is 120s (the longest of any hook). |
| **Async Candidate?** | **NO** |
| **Reasoning** | This is a pre-commit quality gate. Its entire purpose is to block the gitpro skill from creating a commit if there are type errors or invalid TODOs. If async, gitpro would proceed with the commit while type-checking runs in the background, defeating the validation purpose. However, the 120s timeout is noteworthy -- this is the slowest hook and would benefit most from being faster, but its blocking nature is essential. |

#### 9. `bead-comment-reminder.sh`

| Attribute | Value |
|-----------|-------|
| **Event** | `Stop` |
| **Purpose** | **Informational reminder.** When Claude finishes responding, checks if significant work was done (5+ edits OR 3+ files touched) on an active bead. If so, suggests adding a bead comment to preserve context. |
| **Mechanism** | Reads transcript, counts Edit/Write tool calls and unique files. Outputs a `<system-reminder>` if thresholds are met. Always exits 0 -- never blocks. |
| **Currently Blocking?** | Yes (synchronous), but never actually blocks -- always exits 0 with optional context. |
| **Async Candidate?** | **YES -- BEST CANDIDATE** |
| **Reasoning** | This is the strongest async candidate in the entire kit. It is purely informational: it suggests (but does not require) that Claude add a bead comment. It never returns a `decision: "block"`. The `Stop` event means Claude has already finished its work. Even if the reminder arrives on the next turn instead of the current one, the effect is the same -- Claude would see it when the user sends their next message. The transcript analysis (grep + count) could take a moment on large transcripts, and making it async would eliminate that latency entirely. |

#### 10. `beads-workflow.md` (not a hook script)

This is a documentation file consumed by `beads-inject.sh`, not a hook itself. No async analysis needed.

---

### Project-Level Hook: `pre-commit` (Git Hook)

| Attribute | Value |
|-----------|-------|
| **Location** | `_git-hooks-project/pre-commit` |
| **Type** | Git hook (not a Claude Code hook) |
| **Purpose** | Blocks direct `git commit` commands and directs users to the GitPro skill. Has emergency bypass via `SKIP_GIT_GUARD=1`. |
| **Async Candidate?** | N/A -- this is a git hook, not a Claude Code hook. The `async: true` option does not apply to git hooks. |

---

## Summary Table

| # | Hook Name | Event | Purpose | Currently Blocking? | Async Candidate? | Reasoning |
|---|-----------|-------|---------|---------------------|-------------------|-----------|
| 1 | `architect_enforcer.sh` | UserPromptSubmit | Persona/tone injection | Sync (non-blocking behavior) | No | Context must arrive before current turn |
| 2 | `active-now-reminder.sh` | UserPromptSubmit | Bead claiming reminder | Sync (non-blocking behavior) | No | Reminder must precede Claude's response |
| 3 | `beads-inject.sh` | SessionStart, PreCompact | Workflow docs injection | Sync (non-blocking behavior) | No | Context must be available immediately |
| 4 | `block-db-commands.sh` | PreToolUse (Bash) | Block DB migrations | **Hard blocker (deny)** | **NEVER** | Safety-critical; async = no protection |
| 5 | `git-guard.sh` | PreToolUse (Bash) | Enforce gitpro, block destructive git | **Hard blocker (deny)** | **NEVER** | Safety-critical; most comprehensive guard |
| 6 | `dev-server-guard.sh` | PreToolUse (Bash) | Block dev server management | **Hard blocker (deny)** | **NEVER** | Safety-critical; prevents server conflicts |
| 7 | `block-console-log.sh` | PreToolUse (Edit/Write) | Enforce Pino over console.log | **Hard blocker (deny)** | **No** | Must prevent bad code from being written |
| 8 | `pre-gitpro.sh` | PreToolUse (Skill) | Pre-commit quality gate | **Hard blocker (deny)** | **No** | Must block commit if validation fails |
| 9 | `bead-comment-reminder.sh` | Stop | Suggest bead comment after work | Sync (non-blocking behavior) | **YES** | Purely informational; deferred delivery is fine |
| 10 | `pre-commit` (git hook) | Git pre-commit | Block direct git commits | N/A (git hook) | N/A | Not a Claude Code hook |

---

## Recommendations

### 1. Make `bead-comment-reminder.sh` async

This is the only hook that is a clear candidate. Add `"async": true` to its configuration in `settings.json`:

```json
"Stop": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "~/.claude/hooks/bead-comment-reminder.sh",
        "timeout": 5,
        "async": true
      }
    ]
  }
]
```

**Why:** The hook is purely informational (never blocks Claude from stopping), processes the transcript (I/O that could be slow on large sessions), and the reminder is equally useful arriving on the next conversation turn. This removes a synchronous wait from every single stop event.

### 2. Do NOT make any PreToolUse hooks async

All five PreToolUse hooks (`block-db-commands.sh`, `git-guard.sh`, `dev-server-guard.sh`, `block-console-log.sh`, `pre-gitpro.sh`) exist specifically to **prevent actions**. Making them async would silently disable their protection. This is the single most important takeaway from this analysis.

### 3. Do NOT make context-injection hooks async

`architect_enforcer.sh`, `active-now-reminder.sh`, and `beads-inject.sh` all inject context that must be available **before** Claude processes the current turn. Async delivery would delay the context by one turn, defeating their purpose.

### 4. Consider async for future informational hooks

If the starter kit adds new hooks for any of these purposes, they would be good async candidates:
- **Logging/analytics:** Recording tool usage patterns, session duration, etc.
- **Notifications:** Sending desktop or Slack notifications when Claude finishes
- **Background testing:** Running tests after file writes for informational feedback (not as a gate)
- **Knowledge base updates:** Saving context to memory systems

### 5. Watch the `pre-gitpro.sh` timeout

At 120 seconds, `pre-gitpro.sh` is by far the slowest hook. It runs `npm run check-types` and potentially `pyright`/`mypy`, which can be slow. This hook **cannot** be async (it must gate commits), but consider:
- Caching type-check results when files haven't changed
- Running only on changed files rather than the full project
- Using `tsc --noEmit --incremental` for faster subsequent checks

---

## Risks and Caveats

### General `async: true` Risks

1. **Silent failures:** Async hooks fail silently. If an async hook crashes, you won't see the error unless you're in debug/verbose mode (`claude --debug` or `Ctrl+O`). This makes debugging harder.

2. **No deduplication:** Each async hook firing creates a new process. If Claude makes 20 file edits in rapid succession and you have an async PostToolUse hook, you get 20 concurrent background processes. This could cause resource exhaustion or race conditions.

3. **Deferred output timing:** Async hook output arrives on the "next conversation turn." If the session is idle (no new user message), the output waits indefinitely. This means the bead-comment-reminder would only surface when the user sends their next message, not immediately after Claude stops.

4. **No control flow:** Async hooks cannot use `continue: false` to stop Claude, `decision: "block"` to prevent actions, or `permissionDecision` to gate permissions. All control-flow fields are silently ignored.

### Starter Kit-Specific Risks

5. **Accidental async on safety hooks:** If someone copies a hook config and adds `async: true` without understanding the implications, they could disable a safety guard (e.g., `block-db-commands.sh` running async = no database protection). Consider adding a comment in `settings.json` near safety hooks: `// NEVER set async:true - safety critical`.

6. **Hook snapshot isolation:** Hooks are snapshotted at session startup. If you change a hook from sync to async (or vice versa), the change only takes effect in new sessions. This can cause confusion during testing.

7. **The `bead-comment-reminder.sh` edge case:** When made async, the reminder will arrive when the user sends their next prompt. If the user's next action is to close the session, they'll never see the reminder. This is a minor risk since the reminder is advisory, not mandatory.

---

## Sources

- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Boris Cherny announcement on async hooks](https://www.threads.com/@boris_cherny/post/DT8obEVkiRI/)
- [claude-flow Issue #1017: async: true support](https://github.com/ruvnet/claude-flow/issues/1017)
