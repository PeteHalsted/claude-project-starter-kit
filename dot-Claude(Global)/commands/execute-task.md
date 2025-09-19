# /execute-task

**Description**: Execute tasks for a specified phase with Archon integration and parallel processing.

**Usage**: `/execute-task <task-file-path> <phase>`

**Parameters**:
- `task-file-path`: Path to tasks.md file (e.g., "specs/001-users-petehalsted-projects/tasks.md")
- `phase`: Phase identifier (e.g., "3.2", "3.3", "4.1") or "all" for all phases

**Examples**:
- `/execute-task specs/001-users-petehalsted-projects/tasks.md 3.2`
- `/execute-task specs/001-users-petehalsted-projects/tasks.md all`

## Workflow

### 1. **Task Discovery**
- Parse tasks.md file for the specified phase
- Extract Archon IDs from HTML comments: `<!-- archon:UUID -->`
- **Direct lookup**: Use `mcp__archon__find_tasks(task_id="UUID")` for instant task retrieval

### 2. **Task Execution**
For each task in the phase:

**Pre-Execution**:
- Direct Archon lookup using UUID from tasks.md
- Update Archon task status to "doing"
- Create TodoWrite entry for tracking

**Research Phase**:
- Use `mcp__archon__rag_search_knowledge_base()` for relevant documentation
- Use `mcp__archon__rag_search_code_examples()` for implementation patterns
- Review task folder context and specification files

**Execution Phase**:
- Execute task following TDD principles if specified
- Implement according to task description and success criteria
- Use parallel agents for tasks marked `[P]`
- Validate all success criteria are met

**Post-Execution**:
- Update Archon task status to "review"
- Update tasks.md: change `[ ]` to `[x]` for completed task
- Mark TodoWrite entry as completed

### 3. **Parallel Processing**
- Tasks marked with `[P]` can run in parallel within the same phase
- Sequential dependency checking between phases
- Resource management for concurrent operations

### 4. **Phase Dependencies**
- Validate prerequisites before starting each phase
- Halt execution if dependency requirements not met
- **Phase order**: 3.1 → 3.2 → 3.3 → 3.4 → 3.5

### 5. **Error Handling**
- **Task not found**: Error with clear message about missing UUID
- **Dependency failures**: Halt with prerequisite information
- **Task failures**: Keep Archon status as "doing", report to user

## Output Format

### Single Phase:
```
🚀 PHASE 3.2 EXECUTION STARTED
📋 Found 14 tasks (11 parallel)
✅ PHASE 3.2 COMPLETE (14/14 tasks)
```

### All Phases:
```
🚀 ALL PHASES EXECUTION STARTED
📊 Phases: 3.1 (11 tasks), 3.2 (14 tasks), 3.3 (7 tasks), 3.4 (5 tasks), 3.5 (7 tasks)

🏗️ === PHASE 3.1: Setup & Database Migration ===
✅ PHASE 3.1 COMPLETE (11/11 tasks)

🧪 === PHASE 3.2: Tests First (TDD) ===
⚠️ PREREQUISITE CHECK: Phase 3.1 complete ✅
✅ PHASE 3.2 COMPLETE (14/14 tasks)

🎉 ALL PHASES EXECUTION COMPLETE
├── Total tasks completed: 45/45
├── Archon tasks in review: 45
├── Tasks.md fully updated: ✅
└── Project validation: ✅
```

## Task File Format

**Required format for task entries:**
```markdown
- [ ] T012 [P] Task description <!-- archon:2a512642-2978-4349-948c-681b7541ae18 -->
```

**Format elements:**
- `[ ]` or `[x]`: Completion status
- `T012`: Task number for human reference
- `[P]`: Optional parallel execution marker
- Task description: Human-readable task details
- `<!-- archon:UUID -->`: Hidden Archon task ID for direct lookup
