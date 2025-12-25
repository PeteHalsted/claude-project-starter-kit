---
name: dispatching-parallel-agents
description: Use when facing 3+ independent tasks that can be executed without shared state or dependencies - dispatches multiple Claude agents to work concurrently on debugging, research, coding, or any parallelizable work
---

# Dispatching Parallel Agents

## Overview

When you have multiple independent tasks, executing them sequentially wastes time and context. Each task can happen in parallel.

**Core principle:** Dispatch one agent per independent task. Let them work concurrently to maximize speed and minimize context usage.

## When to Use

**Use parallel agents when you have 3+ independent tasks in ANY of these categories:**

### 🐛 Debugging & Fixes
- Multiple test files failing with different root causes
- Independent subsystems broken separately
- Unrelated bugs across different features

### 🔍 Research & Investigation
- Multiple framework/library features to investigate
- Different implementation approaches to evaluate
- Independent API endpoints or patterns to explore
- Tech stack component validation

### 💻 Coding & Implementation
- Independent feature components to build
- Multiple unrelated bug fixes
- Separate refactoring tasks
- Independent utility functions or modules

### 📚 Documentation & Analysis
- Multiple files to document
- Independent architecture reviews
- Separate code analysis tasks

### ✅ Testing & Verification
- Independent test suites to write
- Multiple integration test scenarios
- Separate validation tasks

**Don't use when:**
- Tasks are related (completing one affects others)
- Need to understand full system state first
- Agents would interfere with each other (editing same files)
- Tasks have dependencies (need output from task A to start task B)

## The Pattern

### 1. Identify Independent Tasks

Look for work that can be done without coordination.

### 2. Create Focused Agent Tasks

Each agent gets:
- **Specific scope:** One clear deliverable
- **Clear goal:** What to accomplish
- **Constraints:** What not to touch
- **Expected output:** What to return

### 3. Dispatch in Parallel

Use the Task tool to launch multiple agents in a single message.

### 4. Review and Integrate

When agents return:
- Read each summary
- Verify outputs don't conflict
- Integrate findings/code
- Run validation as needed

## Key Benefits

1. **Speed** - N problems solved in time of 1
2. **Context Savings** - Each agent has narrow scope
3. **Focus** - Agents don't get distracted by unrelated issues
4. **Independence** - No blocking or interference

## Proactive Usage Guidelines

**Always look for opportunities to parallelize:**

- **Starting a feature?** Research multiple aspects in parallel
- **Multiple bugs?** Fix independently in parallel
- **Building components?** Create unrelated ones in parallel
- **Writing docs?** Document separate sections in parallel
- **Investigating issues?** Explore different areas in parallel

**Default mindset:** "Can these tasks run in parallel?"

If yes → dispatch parallel agents
If no → identify the dependencies and parallelize what you can
