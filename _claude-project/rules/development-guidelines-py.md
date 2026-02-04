# Development Guidelines

<!--
WHAT BELONGS HERE: Implementation tips, how-to guidance, best practices, soft recommendations.
WHAT DOESN'T: Critical rules with enforcement (those go in constitution-py.md).
Rule of thumb: If violation is a CRITICAL ERROR, it's constitution. If it's guidance, it's here.
-->

**Note**: Critical rules (Python quality, database, security) are in constitution-py.md. This document covers implementation guidance.

## Code Quality Tips

### Optional Handling
When working with Optional types, use explicit checks:
```python
# ❌ WRONG - truthy check can miss valid falsy values
if user:
    process(user)

# ✅ CORRECT - explicit None check
if user is not None:
    process(user)
```

### Type Narrowing
Use isinstance and type guards for safe narrowing:
```python
from typing import TypeGuard

def is_valid_user(obj: object) -> TypeGuard[User]:
    return isinstance(obj, User) and obj.email is not None
```

## Structured Logging

All logging uses Python's logging module with structured output.

```python
import logging
logger = logging.getLogger(__name__)

logger.info("Processing request", extra={"user_id": user_id})
logger.error("Request failed", exc_info=True, extra={"request_id": req_id})
logger.debug("Debug context", extra={"data": data})
```

**Collaborative Debugging**: Human runs dev server, AI monitors via `tail -f logs/app.log`.

## Documentation Standards

**Location priority:**
1. Follow specific instructions in prompt or user request
2. Special files (`changelog.md`, `README.md`, `CLAUDE.md`) follow predefined locations
3. Temporary documents (disposable) go in `project-documentation/temporary`
4. Permanent documentation goes in `project-documentation`

**Content rules:**
- Only include current state, not historical decisions
- Follow existing file structure and style
- Check existing subfolders for suitable location

## Environment Configuration

- Preserve existing configuration when adding env vars
- Check for existing `.env` files before creating
- Read current values first, add only new variables
- Use `python-dotenv` or `pydantic-settings` for env management

## Development Workflow

**Core Commands**:
- `python -m pytest`: Run tests
- `ruff check .`: Lint code
- `ruff format .`: Format code
- `pyright` or `mypy .`: Type checking

### Database Query Access (psql)

For read-only queries and exports, use psql directly:

```bash
DATABASE_URL=$(grep "^DATABASE_URL=" .env | cut -d'=' -f2- | cut -d'#' -f1 | xargs)
psql "$DATABASE_URL" -c "SELECT * FROM tablename;"
```

## Code Health

- **Unused Code**: Ruff F401/F841 detects unused imports/variables
- **Manual Verification**: Check for indirect usage before deleting flagged code

## FastAPI Guidelines

### Dependency Injection
Use FastAPI's `Depends` for shared resources:
```python
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session

@app.get("/users")
async def get_users(db: AsyncSession = Depends(get_db)):
    ...
```

### Pydantic Models
Use Pydantic for request/response validation:
```python
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    email: str = Field(..., description="User email")
    name: str = Field(..., min_length=1)
```

## Async Patterns

### Task Groups (Python 3.11+)
```python
async with asyncio.TaskGroup() as tg:
    task1 = tg.create_task(fetch_user(user_id))
    task2 = tg.create_task(fetch_settings(user_id))
# Both complete or all cancelled on error
```

### Graceful Shutdown
Handle SIGTERM/SIGINT for clean shutdown:
```python
async def shutdown():
    # Close connections, flush buffers
    await db.close()
    await scheduler.shutdown()
```
