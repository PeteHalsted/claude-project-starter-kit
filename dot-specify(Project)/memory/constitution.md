# NextAge Designs Client Portal Constitution

## Core Principles

### I. Unified Full-Stack Architecture
This project is built on a unified TanStack Start architecture. All development must adhere to this stack, which includes:
- **Framework**: TanStack Start (unified full-stack)
- **Database**: PostgreSQL with Drizzle ORM
- **Authentication**: Clerk with RBAC (admin/client roles)
- **State Management**: TanStack Query with SWR-style caching

### II. Critical Implementation Patterns (The Bibles)
All development MUST strictly follow the patterns documented in the "MF'ing Bibles" and production examples.
- **`MFing-Bible-of-TanStack-Start.md`**: Governs server functions, routing, and data loading. The `loaderDeps` → `loader` → server function pattern is mandatory for data fetching.
- **`MFing-Bible-of-Clerk.md`**: Governs all authentication. The JIT Profile Sync pattern is the single source of truth for user profile synchronization.

### III. Database & Naming Conventions
The database schema and naming conventions are non-negotiable.
- **Table Naming**: Singular (e.g., `user`, not `users`).
- **Primary Keys**: Table name suffixed with `id` (e.g., `userid`). All new primary keys MUST use UUID v7 format (`uuid_generate_v7()`) for time-ordered UUIDs with better database performance and natural sort order.
- **Foreign Keys**: Foreign keys in child tables should match the parent table primary key name whenever possible (e.g., `customer.customerid` → `invoice.customerid`). For multiple foreign keys to the same parent table, use functional prefixes (e.g., `invoice.salesmanemployeeid` and `invoice.manageremployeeid`).
- **Field Naming**: `lowercase` for PostgreSQL schema fields, `camelCase` for TypeScript variables. Underscores are forbidden for word separation.
- **Entity Names in Code**: ALWAYS use actual database entity names in code, never abstracted or aliased names. Code should reference `contact` if that's the database entity, not `prospect` or other abstractions. This makes debugging and maintenance significantly easier as you can search the codebase and find every usage quickly and reliably.
- **Schema Location**: All database schemas reside in `packages/shared/src/db/schema/` and are imported via `@mysite/shared/db`.
- **Schema Changes**: The `db:generate` -> `db:migrate` workflow is mandatory. `db:push` is forbidden in production. All database commands must be run from project root and will execute in the shared workspace context.
- **AI Database Command Restrictions**: AI agents MUST NEVER run drizzle commands (`npm run db:generate`, `npm run db:migrate`, `npm run db:push`, or `npx drizzle-kit` commands). These commands require human interaction due to interactive prompts and potential data risks. AI agents must request human assistance for all database schema operations.
- **Database Schema Patterns**: BEFORE creating any new schema file, AI agents MUST read an existing schema file (e.g., `contact.ts`, `invoice.ts`) to verify the established pattern. This project uses Drizzle's built-in type inference (`$inferSelect`, `$inferInsert`) and does NOT use `drizzle-zod`. Schema files must follow this exact structure:
  ```typescript
  import { sql } from "drizzle-orm";
  import { pgTable, uuid, varchar, ... } from "drizzle-orm/pg-core";
  
  export const tablename = pgTable("tablename", { /* columns */ });
  
  // TypeScript types for the schema
  export type TableName = typeof tablename.$inferSelect;
  export type NewTableName = typeof tablename.$inferInsert;
  ```
  Do NOT import or use `drizzle-zod`, `createInsertSchema`, or `createSelectSchema`. All validation schemas are defined inline in server functions per the Architecture Separation rule.

### IV. Code Quality & Styling
Code must adhere to the project's established quality and style standards.
- **TypeScript**: All new code must be in TypeScript. Use functional components with hooks.
- **Type Checking**: AI agents MUST run `npm run check-types` immediately after creating or modifying TypeScript files. All type errors must be fixed BEFORE any git commits. Type checking is non-negotiable and catches critical errors that would otherwise require human debugging.
- **Architecture Separation**: Production code (in `apps/`, `packages/`, `src/`, `lib/`) MUST NEVER import from specification/documentation folders (`specs/`, `docs/`, `project-documentation/`). Specs are reference documentation only. All Zod schemas, types, and validation must be defined inline in production code files.
- **Testing**: Test integrations with real APIs, not mocks.
- **Monorepo Structure**: The project uses npm workspaces with the following organization:
  - **Shared Package** (`packages/shared/`): Database schemas, logger, utilities, constants, and types shared across all apps
  - **Web App** (`apps/web/`): TanStack Start application with routes, components, and server functions
  - **Workers** (`apps/workers/`): Background job processors and scheduled tasks
  - **Import Pattern**: Always use `@mysite/shared/*` imports for shared code (e.g., `@mysite/shared/db`, `@mysite/shared/logger`, `@mysite/shared/utils`)
- **File Organization**: Follow the mandatory directory structure below:
  - **Shared Package Structure**:
    - `packages/shared/src/db/` - Database client, schemas, and migrations
    - `packages/shared/src/logger/` - Adze logger configuration
    - `packages/shared/src/utils/` - Shared utility functions
    - `packages/shared/src/constants/` - Shared constants and configuration
    - `packages/shared/src/types/` - Shared TypeScript types
  - **Web App Structure**:
    - `apps/web/src/routes/` - ONLY route files with `createFileRoute()` or `createServerRoute()` exports
    - `apps/web/src/components/{feature}/` - React components organized by feature (e.g., `components/prospects/`, `components/regions/`, `components/ui/`)
    - `apps/web/src/lib/serverFunctions/` - All server functions with `Fn` suffix (e.g., `prospectsFn.ts`, `regionsFn.ts`)
    - `apps/web/src/hooks/` - TanStack Query hooks and custom React hooks (e.g., `useProspects.ts`, `useRegions.ts`)
  - **FORBIDDEN**: Never place component files inside `routes/` directory - TanStack Router scans all files in `routes/` and expects route exports
- **Components**: Keep components focused and reusable. Components must reside in `apps/web/src/components/{feature}/`, never in `routes/`.
- **Confirmation Dialogs**: Use the universal `ConfirmationDialog` component (`@/components/ui/ConfirmationDialog`) with helper functions from `@/lib/constants/confirmationConst` for ALL confirmation prompts (delete, reject, archive, etc.). NEVER create custom `Dialog` components for confirmations. Store full objects in state, not just IDs.
- **UI Pattern Verification**: After creating or modifying any pages or components, they MUST be verified against `project-documentation/Production-UI-Patterns.md` for compliance. All violations MUST be corrected before commit. This includes badges, buttons, dropdowns, inputs, glass morphism, and all other documented patterns.
- **Naming Conventions**: Use consistent naming conventions across the codebase.

### V. Security & Data Protection
Security standards are non-negotiable and must be implemented throughout the application.
- **Environment Variables**: Use environment variables for all sensitive data. NEVER hardcode API keys, credentials, or sensitive configuration.
- **Error Handling**: Always implement proper error handling with secure error messages that don't expose internal system details.

### VI. Early Development Philosophy

**Breaking Changes Over Technical Debt**: This project is in early active development. We prioritize clean architecture and maintainable code over backward compatibility concerns.

**Clean Cutover Principle**: When evolving data models, API contracts, or core architecture:
- **Preferred**: Complete replacement with clean migration
- **Avoided**: Gradual migration with compatibility layers
- **Forbidden**: Maintaining deprecated patterns alongside new ones

**Legacy Support Policy**:
- No legacy support requirements during pre-1.0 development
- Breaking changes are acceptable and often preferred
- Focus on the best long-term architecture, not short-term compatibility
- Clean code and simple design trump migration complexity

**Implementation Guidelines**:
- Replace entire entities/patterns rather than extending them
- Drop deprecated tables/code completely after migration
- No filtering or compatibility layers for "legacy" functionality
- Single source of truth for all data and business logic

**Justification**: Early development stage allows us to make optimal architectural decisions without being constrained by legacy considerations. Clean, simple designs are easier to understand, maintain, and extend than compatibility-laden architectures.

### VII. Testing Standards

**Integration Testing Only**: This project uses integration testing exclusively as documented in `project-documentation/MFing-Bible-of-Testing.md`.

**Human Override**: If the human user requests to skip integration tests for a feature, skip them. Document the decision in tasks.md.

**Critical Testing Rules** (when tests are required):
- **NO TDD/Unit Tests**: Do NOT generate TDD or unit test tasks. No "red-green-refactor" workflow.
- **Integration Tests Only**: Generate integration test tasks following the complete CRUD workflow pattern (Section 5 of Testing Bible).
- **Test After Implementation**: Tests are written AFTER server functions are implemented and working.
- **Real Database & APIs**: Use real database and server functions, mock only external services (Stripe, Clerk).
- **Battle-Tested Patterns**: Copy patterns from existing test files (`contactFn.test.ts`, `invoiceFn.test.ts`).
- **Systematic debugging over test-fixing** - When integration tests fail, use systematic root cause analysis rather than patching tests

**Test Task Template**:
When generating test-related tasks, use this format:

```
**Task**: Write integration tests for [Entity] CRUD operations

**Acceptance Criteria**:
- Follow complete CRUD test sequence from `MFing-Bible-of-Testing.md` Section 5
- Use battle-tested error handling pattern from Section 3.6
- Use proper server function parameter passing with `{ data: params }` (Section 3.5)
- Copy mock setup from existing test files (Section 3.7)
- Run tests using: `cd apps/web/tests && node run-test.ts [entity]Fn.test.ts`

**Reference**: `@project-documentation/MFing-Bible-of-Testing.md`
```

**Test Execution**:
- **Command**: `cd apps/web/tests && node run-test.ts all` (or specific test files)
- **Reports**: Generated in `testresults/` with date-stamped JSON and Markdown
- **Binary Results**: Tests must return strict boolean `true`/`false`, never truthy/falsy values

## Forbidden Actions

The following actions are strictly forbidden:
- **Database**: No schema modifications (`DROP`, `ALTER`, `CREATE`) without explicit approval. Do not use `db:push` on a populated database. AI agents MUST NEVER execute drizzle commands (`npm run db:generate`, `npm run db:migrate`, `npm run db:push`).
- **Code Management**: No substituting technology stack components. No using underscores in variable, table, or field names.
- **Environment**: Never overwrite existing environment variables without explicit user consent.
- **Testing**: No TDD or unit test generation. Integration tests only per Section VII. Test tasks must come AFTER implementation tasks.

## VIII. Debugging Protocol
When issues arise during implementation:
1. **Reproduce** - Create minimal reproduction case
2. **Isolate** - Identify the exact component/layer failing
3. **Root cause** - Trace to actual source, not symptoms
4. **Fix** - Implement solution with verification
5. **Defense in depth** - Add integration test to prevent regression

**The Third-Party Library Rule:**
Before blaming a third-party library for a bug, you MUST:
1. **Use Ref MCP** to search for and read the official documentation
2. **Search for evidence** - Find GitHub issues, Stack Overflow posts, or bug reports from other developers confirming the bug
3. **Default assumption**: If you can't find documented evidence of the bug from multiple independent sources, **YOU ARE USING THE LIBRARY INCORRECTLY**

**Never blame the library without proof.** The fault is almost certainly in your code, not in a battle-tested open-source library used by thousands of developers. Read the documentation, check your usage patterns, and verify your assumptions before claiming a library bug exists.

## IX. Parallel Execution Principle

**Maximize Concurrency**: When facing 3+ independent tasks, parallel execution is REQUIRED to maximize speed and minimize context usage.

**Parallel-First Mindset**: Always ask "Can these tasks run in parallel?" before starting work. If yes, use the `dispatching-parallel-agents` skill to execute concurrently.

**Applicable to ALL Work Types**:
- **Research**: Multiple framework features, API patterns, or tech evaluations
- **Implementation**: Independent components, utilities, or features
- **Debugging**: Unrelated test failures or bugs in separate subsystems
- **Documentation**: Multiple files, sections, or analysis tasks
- **Testing**: Independent test suites or validation scenarios

**When Parallel Execution is REQUIRED**:
- 3+ research questions with no dependencies
- Multiple independent components to build
- Unrelated bugs or test failures
- Separate documentation sections
- Independent refactoring tasks

**When Sequential is Appropriate**:
- Tasks have dependencies (output of A needed for B)
- Need full system understanding first
- Agents would edit the same files
- Exploratory work where scope is unclear

**Application to Spec-Kit**: During any spec-kit workflow phase (`/speckit.plan`, `/speckit.implement`), ALWAYS identify opportunities for parallel execution. Research, implementation, and testing tasks should be parallelized whenever possible.

**Performance Impact**: Parallel execution typically provides 3-5x speedup while reducing context usage per agent. This is not optional - it's a core efficiency principle.

## X. TODO & Technical Debt Tracking

**IMMUTABLE RULE**: All incomplete code, placeholders, hacks, and technical debt MUST be tracked in `project-documentation/Todo.md`.

### Mandatory TODO Tracking Protocol

**When Writing TODO/FIXME/HACK/XXX Code:**
1. **IMMEDIATELY** add detailed entry to `project-documentation/Todo.md`
2. **ALERT USER** with message: "⚠️ New TODO recorded in Todo.md: [brief description]"
3. **CANNOT COMMIT** code with TODO comments without updating Todo.md
4. **NO EXCEPTIONS** - this is not optional

**When Completing TODO Items:**
1. **ALERT USER** with message: "✅ TODO completed: [description]"
2. **ASK USER** for permission: "Should I remove this item from Todo.md?"
3. **WAIT** for user confirmation before removing from tracking document
4. **UPDATE** Todo.md statistics and mark as complete

**Entry Format Requirements:**
Each TODO entry MUST include:
- **Priority Level:** 🔴 CRITICAL, 🟡 MEDIUM, or 🟢 LOW
- **Status:** ❌ BROKEN, ⏸️ DEFERRED, ⚠️ INCOMPLETE
- **Location:** Full file path and line number
- **Code Comment:** Exact TODO/FIXME/HACK comment text (if exists)
- **Current Behavior:** What the code does now (placeholder, incomplete, etc.)
- **Impact:** What breaks or is limited by this incomplete implementation
- **Action Required:** Specific steps needed to complete the implementation
- **Dependencies:** What must be fixed first (if applicable)

**Enforcement:**
- AI agents MUST verify Todo.md is updated before committing any code containing TODO comments
- AI agents CANNOT use "I'll document it later" as justification - document NOW
- Violations of this protocol are treated as CRITICAL ERRORS equivalent to data loss
- This rule supersedes convenience - better to have no TODO than an untracked TODO

**Rationale:**
Lazy coding with TODO comments creates technical debt bombs. The asset management system was shipped fundamentally broken (cannot delete files from GitHub) because the developer wrote `TODO: Delete file from GitHub` without realizing they also forgot to capture the SHA needed for deletion. Tracking TODOs immediately forces awareness of dependencies and blockers.

## Governance

- This Constitution and the referenced "Bibles" (`MFing-Bible-of-TanStack-Start.md`, `MFing-Bible-of-Clerk.md`, `MFing-Bible-of-Testing.md`) are the ultimate source of truth, superseding all other practices.
- Any deviation or amendment requires a documented proposal, review, and approval from the project lead.
- All code reviews must verify compliance with this constitution.

**Version**: 1.12.0 | **Last Amended**: 2025-11-25
