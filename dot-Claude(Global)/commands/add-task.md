# /add-task

**Description**: Create Archon tasks from a markdown task file and update the file with Archon IDs.

**Usage**: `/add-task @task.md [project_name]`

**Parameters**:
- `@task.md`: Task file to parse and create tasks from
- `project_name`: Optional target Archon project name

## Workflow

### 1. **Project Resolution**
- If project_name provided: Search Archon for exact match
- If no project_name: Parse task file directory name for project identifier
- Prompt user for project selection if multiple matches found

### 2. **Task File Parsing**
- Parse markdown file for task entries: `- [ ] T001 [P] Description`
- Extract task pattern, parallel markers, and phase groupings
- Group tasks by Phase (Phase 3.1, Phase 3.2, etc.)
- Extract dependencies from task descriptions and phase headers

### 3. **Task Creation in Archon**
For each task, create with enhanced context:

**Title Format**: `[Task ID] [P?] [Brief Title]`
- Example: `T001 [P] Create contact schema`

**Description Template**:
```
[Original Task Description]

Business Context: [Extracted from phase/section context]

Technical Requirements:
- Follow TanStack Start patterns and Drizzle ORM conventions
- [Specific requirements extracted from task content]
- [File path requirements from mentioned paths]

Testing Requirements (for test creation tasks):
- ALWAYS include task number in describe blocks: `describe("T012 - functionName", () => { ... })`
- This enables easy cross-referencing between task.md and test output
- Example: `describe("T012 - getContacts", () => {` instead of `describe("getContacts", () => {`

References:
- [Auto-detected reference files based on task content]
- Architecture: /project-documentation/MFing-Bible-of-TanStack-Start.md
- Constitution: /.specify/memory/constitution.md

Prerequisites: [Extracted dependencies]

Success Criteria:
- [Task-specific acceptance criteria]
- [File creation/modification requirements]
- [Pattern compliance requirements]
- For test tasks: describe blocks must include task numbers for cross-referencing
```

**Task Properties**:
- `status`: "todo"
- `assignee`: "AI IDE Agent"
- `feature`: Auto-detected from phase or task content
- `task_order`: Sequential based on task ID number

### 4. **File Update with Archon IDs**
After successful task creation:

**Update Process**:
1. Capture returned Archon UUID from each `manage_task("create", ...)` call
2. Find corresponding line in original task.md file
3. Append Archon ID as HTML comment: `<!-- archon:UUID -->`
4. Preserve all original formatting and content

**Format Result**:
```markdown
## Phase 3.2: Tests First (TDD)
- [ ] T012 [P] Create contract test for getContacts <!-- archon:2a512642-2978-4349-948c-681b7541ae18 -->
- [ ] T013 [P] Create contract test for createContact <!-- archon:b28c423d-6cdc-4728-bc56-8b5057ad945b -->
```

**Implementation**:
- Use regex to match task lines: `/- \[ \] T\d{3}/`
- Preserve exact spacing and formatting
- Handle parallel tasks correctly
- Backup original file before modification

### 5. **Context Enhancement**

**Business Context Auto-Detection**:
- Phase 3.1 → "Database schema creation and migration foundation"
- Phase 3.2 → "Test-driven development with contract and integration tests"
- Phase 3.3 → "Core business logic implementation"
- Phase 3.4 → "Third-party service integration"
- Phase 3.5 → "User interface and final polish"

**Reference Files Auto-Detection**:
- Schema tasks → Add data-model.md reference
- Auth tasks → Add MFing-Bible-of-Clerk.md reference
- Server function tasks → Add MFing-Bible-of-TanStack-Start.md reference
- Test tasks → Add contracts/ directory references

**Feature Classification**:
- T001-T011 → "database-migration"
- T012-T025 → "testing-foundation"
- T026-T032 → "core-implementation"
- T033-T037 → "integration"
- T038-T045 → "ui-polish"

### 6. **Parallel Task Handling**
- Tasks marked with `[P]` get task_order values allowing parallel execution
- Group parallel tasks with same base order
- Sequential tasks get incremental orders

## Example Output

```
✅ Parsed 45 tasks from @tasks.md
📋 Target Project: NextAge Designs Client Portal - User Management & Billing
🔄 Creating tasks in Archon...

Phase 3.1: Setup & Database Migration
✅ T001 [P] Create contact schema (created: d2f03115-4c93-4931-a210-979d12010ad7)
✅ T002 [P] Create product schema (created: b54fa89b-5ae0-4dab-a73a-b479960f7fe6)
...

📝 Updating task.md file with Archon IDs...
✅ File updated: All tasks now have Archon ID references

📊 Summary:
- 45 tasks created successfully
- 11 parallel execution groups identified
- 5 phases organized
- Task file updated with bidirectional linking
```

## Error Handling
- **File not found**: Clear error with file path
- **Project ambiguity**: Interactive project selection
- **Duplicate tasks**: Check existing and prompt for action
- **Parse errors**: Show line numbers and issues
- **File update errors**: Backup restoration and retry options

## Integration Benefits
- **Seamless workflow**: `/add-task` creates tasks, `/execute-task` runs them
- **Bidirectional sync**: Task.md ↔ Archon always linked
- **Human readable**: HTML comments hidden, task.md stays clean
