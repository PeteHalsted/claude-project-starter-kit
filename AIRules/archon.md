# Archon MCP Integration

**Research**: Always check Archon first → `mcp__archon__rag_search_knowledge_base()` → `mcp__archon__rag_search_code_examples()` → External if needed
**Tasks**: Only when user explicitly requests

## Decision Tree
```
USER REQUEST
├── Research/Questions → Knowledge Base (always)
├── "Work on task X" → Task Execution Workflow
├── "Create project Y" → Project Creation Workflow
├── "Add tasks" → Task Creation Workflow
└── Other → Use tools as needed
```

## Core Workflows

### Research (Always Use)
```bash
mcp__archon__rag_search_knowledge_base(query="topic", match_count=5)
mcp__archon__rag_search_code_examples(query="implementation", match_count=3)
mcp__archon__rag_get_available_sources()  # if needed
```

### Task Execution: "Work on task X"
```bash
1. mcp__archon__find_tasks(task_id="X")
2. mcp__archon__manage_task(action="update", task_id="X", status="doing")
3. Research using knowledge base above
4. Implement code
5. mcp__archon__manage_task(action="update", task_id="X", status="review")
```

### Project Creation: "Create project Y"
```bash
mcp__archon__manage_project(action="create", title="Y", description="...")
# Get project_id from response for next steps
```

### Task Creation: "Add tasks to project Y"
```bash
mcp__archon__manage_task(
  action="create",
  project_id="Y",
  title="task name",
  description="details",
  feature="group",
  task_order=10
)
```
## Quick Reference

**Projects:**
- List: `mcp__archon__find_projects()`
- Get: `mcp__archon__find_projects(project_id="...")`
- Create: `mcp__archon__manage_project(action="create", title="...", description="...")`

**Tasks:**
- List: `mcp__archon__find_tasks(project_id="...")`
- Get: `mcp__archon__find_tasks(task_id="...")`
- Filter: `mcp__archon__find_tasks(filter_by="status", filter_value="todo")`
- Create: `mcp__archon__manage_task(action="create", project_id="...", title="...")`
- Update: `mcp__archon__manage_task(action="update", task_id="...", status="doing|review|done")`

**Knowledge:**
- Search docs: `mcp__archon__rag_search_knowledge_base(query="...", match_count=5)`
- Search code: `mcp__archon__rag_search_code_examples(query="...", match_count=3)`

## Error Handling
- Task/Project not found → List available options to user
- No research results → Try broader terms, then external research
- Unclear request → Ask for task ID or project ID

## Status Flow
`todo` → `doing` → `review` → `done`
Never mark `done` unless user ask you to do so.
