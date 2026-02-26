# Constitution

<!--
WHAT BELONGS HERE: Critical rules with enforcement. Violations are CRITICAL ERRORS.
WHAT DOESN'T: Implementation tips, how-to guidance (those go in development-guidelines-py.md).
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

## III. Python Quality (Zero Tolerance)

**No type errors or lint violations in committed code.** Enforced by git pre-commit hook.

**Ruff and type checker diagnostics are authoritative.** These errors are NOT suggestions - they are quality failures. Ignoring reported errors is a CRITICAL FAILURE.

| Forbidden Pattern | Why | Fix |
|-------------------|-----|-----|
| `# type: ignore` | Hides type errors | Fix the type issue |
| `# noqa` | Hides lint errors | Fix the lint issue |
| `Any` type | Disables type checking | Use proper types |
| Unused imports | Dead code | DELETE |

| Error | Fix |
|-------|-----|
| F401 (unused import) | DELETE |
| F841 (unused variable) | DELETE |
| E501 (line too long) | Reformat |
| Type mismatch | Fix at source |

## IV. No Print Statements

**print() is FORBIDDEN in production code.** Enforced by PreToolUse hook.

Use Python's `logging` module with structured loggers.

```python
import logging
logger = logging.getLogger(__name__)
logger.info("message")
logger.error("error message", exc_info=True)
```

## V. Database & Naming

| Convention | Rule |
|------------|------|
| Tables | Singular (`user` not `users`) |
| Primary keys | `{table}id` (e.g., `userid`) using UUID v7 |
| Foreign keys | Match parent PK name |
| DB fields | `lowercase` |
| Python variables | `snake_case` |
| Classes | `PascalCase` |

**Entity names**: Use actual database names in code. `contact` not `prospect`.

**AI restriction**: NEVER run migration commands (`alembic upgrade`, `alembic revision`). Request human assistance.

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

## VIII. Timezone-Aware Code (Zero Tolerance)

**Every line of code that touches time MUST consider timezone.**

**Before writing ANY time-related code, ask**: "What timezone is this stored in? What timezone does the consumer expect?"

**Core principle**: If data is stored in local time, query logic MUST use the same local time. If data is stored in UTC, convert to local before user-facing display/filtering. Never mix conventions — match your query boundaries to your storage format.

| Forbidden | Why | Fix |
|-----------|-----|-----|
| `datetime.now()` without tz | Naive datetime, ambiguous on servers | `datetime.now(tz)` with explicit timezone |
| `date.today()` in user-facing code | Server date ≠ user's date across tz boundaries | Derive from timezone-aware `datetime.now(tz)` |
| API queries with implicit "today" | API may use different tz than stored data | Pass explicit date in the correct tz |
| UTC query boundaries on local-time data | Creates mid-day cutoffs for non-UTC users | Query in the same tz the data was stored in |

**This applies to**: database queries, API calls, date filtering, log display, scheduling, status lines, summaries, check-ins — everything.

**Why this rule exists**: Mismatched timezone conventions between storage and query logic create silent mid-day cutoffs, showing users wrong data. This has caused repeated bugs across projects.

## IX. Async Best Practices

**Never block the event loop.**

| Forbidden | Use Instead |
|-----------|-------------|
| `time.sleep()` | `await asyncio.sleep()` |
| `requests.get()` | `httpx.AsyncClient` or `aiohttp` |
| Sync file I/O in async | `aiofiles` |
| Blocking DB calls | async drivers (asyncpg, etc.) |

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

- Python 3.11+ required. Type hints on all functions.
- Production code NEVER imports from `docs/`, `specs/`, `project-documentation/`.
- Test with real APIs, not mocks.
- Architecture separation: validation inline in production code, not imported from spec files.

## XII. Type Checker Usage

**Use pyright or mypy for type checking.** Provides type-aware analysis superior to text-based search.

**When to use type checker vs Grep:**
- **Type checker**: Type-aware queries ("what type is this?", "what implements this protocol?")
- **Grep**: Text pattern matching ("find all TODO comments", "find hardcoded strings")

**Diagnostics**: Type checker provides real-time Python errors. See Section III — ignoring these is a CRITICAL FAILURE.
