# Constitution

<!--
WHAT BELONGS HERE: Critical rules with enforcement. Violations are CRITICAL ERRORS.
WHAT DOESN'T: Implementation tips, how-to guidance (those go in development-guidelines.md).
Rule of thumb: If hook-enforced or causes breakage, it's here. If it's guidance, it's not.
-->

Global rules for all projects. Violations are critical errors.

## I. The Third-Party Library Rule

**Default assumption**: If something doesn't work, YOU ARE USING IT WRONG.

Before blaming any library:
1. Use **Ref MCP** to read official documentation
2. Search for GitHub issues or Stack Overflow confirming the bug
3. Only claim library bug if you find **multiple independent sources** documenting it

Never blame the library without proof. The fault is almost certainly in your code.

## II. Questions Before Code

**When asked a question, ANSWER IT FIRST.**

| Allowed | Forbidden |
|---------|-----------|
| Investigate codebase | Write code in response to question |
| Research (web, Ref, Exa) | Change code in response to question |
| Read/analyze files | Assume what code to write |

**Why?** Until the question is answered and user responds with direction, any code is guesswork.

**Exception**: User explicitly says "do it", "implement this", "fix that bug".

## III. TypeScript Quality (Zero Tolerance)

**No TypeScript errors in committed code.** Enforced by git pre-commit hook.

**LSP diagnostics are authoritative.** The LSP tool provides real-time TypeScript diagnostics. These errors are NOT suggestions - they are compilation failures. Ignoring LSP-reported errors is a CRITICAL FAILURE.

| Forbidden Pattern | Why | Fix |
|-------------------|-----|-----|
| `_unusedVar` | Hides dead code | DELETE the code |
| `: any` | Disables type checking | Use proper types |
| `// @ts-ignore` | Hides errors | Fix the issue |
| `as any` | Bypasses checking | Type narrowing |

| Error | Fix |
|-------|-----|
| TS6133 (unused) | DELETE |
| TS7006 (implicit any) | Add type |
| TS2339 (property missing) | Fix type def |
| TS2322 (type mismatch) | Fix at source |

## IV. No Console.log

**console.log is FORBIDDEN.** Enforced by PreToolUse hook.

Use Pino structured logging with namespaced loggers.

## V. Database & Naming

| Convention | Rule |
|------------|------|
| Tables | Singular (`user` not `users`) |
| Primary keys | `{table}id` (e.g., `userid`) using UUID v7 |
| Foreign keys | Match parent PK name |
| DB fields | `lowercase` |
| TS variables | `camelCase` |
| Underscores | **FORBIDDEN** for word separation |

**Entity names**: Use actual database names in code. `contact` not `prospect`.

**AI restriction**: NEVER run migration commands (`db:generate`, `db:migrate`, `db:push`). Request human assistance.

## VI. Security

- Environment variables for all secrets. NEVER hardcode.
- Never overwrite env vars without explicit consent.
- No schema modifications (`DROP`, `ALTER`, `CREATE`) without approval.
- Error messages must not expose internal details.

## VII. Early Development Philosophy

**No backward compatibility.** Breaking changes preferred over technical debt.

- Complete replacement over gradual migration
- Drop deprecated code entirely after migration
- No compatibility layers
- Single source of truth

## VIII. No Toast Messages

Toasts are deprecated. Use contextual feedback instead. See `development-guidelines.md` for alternatives.

**Exception**: Clipboard copy confirmation only.

**Cleanup**: When editing files with toasts, migrate them.

## IX. Timezone-Aware Code (Zero Tolerance)

**Every line of code that touches time MUST consider timezone.**

**Before writing ANY time-related code, ask**: "What timezone is this stored in? What timezone does the consumer expect?"

**Core principle**: If data is stored in local time, query logic MUST use the same local time. If data is stored in UTC, convert to local before user-facing display/filtering. Never mix conventions — match your query boundaries to your storage format.

| Forbidden | Why | Fix |
|-----------|-----|-----|
| Getting current time without explicit tz | Naive/ambiguous timestamps | Always specify timezone explicitly |
| "Today" without tz in user-facing code | Server date ≠ user's date across tz boundaries | Derive from timezone-aware now |
| API queries with implicit "today" | API may use different tz than stored data | Pass explicit date in the correct tz |
| UTC query boundaries on local-time data | Creates mid-day cutoffs for non-UTC users | Query in the same tz the data was stored in |

**This applies to**: database queries, API calls, date filtering, log display, scheduling, status lines, summaries, check-ins — everything.

**Why this rule exists**: Mismatched timezone conventions between storage and query logic create silent mid-day cutoffs, showing users wrong data. This has caused repeated bugs across projects.

## X. Debugging Protocol

**New code is guilty until proven innocent.**

1. **Assume recent changes broke it** - Check code from last session/PR first
2. **Trust stable infrastructure** - Production code (weeks old) is probably correct
3. **Reproduce** - Minimal reproduction case
4. **Isolate** - Identify failing component
5. **Root cause** - Trace to source, not symptoms
6. **Fix** - Implement with verification
7. **Defend** - Add test to prevent regression

## XI. Code Standards

- TypeScript required. Functional components with hooks.
- Production code NEVER imports from `docs/`, `specs/`, `project-documentation/`.
- Test with real APIs, not mocks.
- Architecture separation: validation inline in production code, not imported from spec files.

## XII. Server-Side Static Assets

**Never use `import.meta.url` for runtime file reads.** Bundlers (Vite, Rollup, esbuild) rewrite the path and do not copy the referenced files into the build output. This causes silent production failures.

| Pattern | Result |
|---------|--------|
| `readFileSync` + `import.meta.url` | **BROKEN** — file not found in production |
| `readFileSync` + `process.cwd()` | **CORRECT** — predictable path in all environments |

**Rules:**
- Static assets loaded at runtime (templates, images, PDFs) go in `server-assets/` at the app root
- Resolve paths via `process.cwd()` (e.g., `resolve(process.cwd(), 'server-assets/email/template.html')`)
- The Dockerfile must `COPY` `server-assets/` into the production image
- Never place runtime-loaded files inside `src/` — bundlers will not include them

## XIII. LSP Tool Usage

**Use LSP for semantic code intelligence.** The LSP tool provides type-aware analysis superior to text-based search.

| Operation | Use For |
|-----------|---------|
| `goToDefinition` | Find where symbol is defined |
| `findReferences` | Find all usages of a symbol |
| `hover` | Get type info and documentation |
| `documentSymbol` | List all symbols in a file |
| `workspaceSymbol` | Search symbols across codebase |
| `goToImplementation` | Find interface implementations |
| `incomingCalls` | Find callers of a function |
| `outgoingCalls` | Find functions called by a function |

**When to use LSP vs Grep:**
- **LSP**: Type-aware queries ("what calls this function?", "what implements this interface?")
- **Grep**: Text pattern matching ("find all TODO comments", "find hardcoded strings")

**Diagnostics**: LSP provides real-time TypeScript errors. See Section III — ignoring these is a CRITICAL FAILURE.

## XIV. Fail Fast, Fail Loud (Zero Tolerance)

**Every error MUST be visible to the user.** Silently swallowed errors are worse than crashes.

**Default mental model**: When writing any code that can fail, the FIRST question is "how will the user know this failed?" If the answer is "they won't" — the code is wrong.

| Forbidden | Why | Fix |
|-----------|-----|-----|
| `onError` that sets state nobody reads | Silent failure | Ensure error state is always rendered |
| `catch` that only logs | User sees nothing | Re-throw or surface to UI |
| Error stored in variable with no UI | Dead error | Wire it to visible feedback |
| `try/catch` that returns default value | Masks the problem | Let it throw or show error state |
| Mutation error handlers that don't match display conditions | Error set but never shown | Verify the error rendering path end-to-end |

**When writing error handlers**: Trace the FULL path from error occurrence to user visibility. If any link in the chain is broken, the error is swallowed.

**When reviewing code**: Look for `onError`, `catch`, `.catch()` — verify each one surfaces to the user, not just to logs or dead state.

