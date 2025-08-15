# Development Guidelines

## Core Principles

### Database Architecture

- **Table Naming**: Always use singular names (user not users, order not orders)
- **Field Naming**: Use lowercase for PostgreSQL schema, camelCase for TypeScript variables
- - **Schema Changes**: Always ask for explicit permission before DROP, ALTER, or CREATE operations

### Frontend Policy

- Always ask before adding admin or debugging features to the frontend, unless asked to
- All icon-only buttons must include tooltips on hover

### Responsive Design Considerations

**ALWAYS consider and analyze responsive design impact before making ANY UI changes.**

When making UI changes, you MUST:

1. **Analyze responsive impact** across mobile, tablet, and desktop breakpoints
2. **Explicitly mention responsive considerations** in explanations
3. **Warn the user immediately** if a change could cause responsive issues
4. **Consider**: horizontal/vertical space usage, text wrapping, touch targets, grid/flex behaviors
5. **Test mentally** across breakpoints: `sm:`, `md:`, `lg:`, `xl:` classes
6. **Use ShadCN MCP** - for any work with shadcn components you MUST ALWYAS consult the ShadCN MCP for guidance. 

**Evaluate every UI change for:**

- Mobile horizontal space constraints
- Text overflow/wrapping potential
- Touch target accessibility (minimum 44px)
- Grid/flex layout behavior changes
- Visual hierarchy on different screen sizes

**Never treat responsive design as an afterthought - it must be a primary consideration.**

## Coding Standards

### TypeScript & React

- Use TypeScript for all new JavaScript files
- Prefer functional components with hooks over class components
- Always include TypeScript types for function parameters and return values
- Use camelCase for all variables (except PostgreSQL schema which is lowercase)

### Styling & UI

- Use Tailwind CSS for styling, avoid inline styles
- Name Tailwind classes based on functional use, not color (ButtonActive not ButtonRed)
- Maintain consistency with ShadCN/ui component patterns
- **Formatter**: Biome with tab indentation and double quotes
- **Imports**: Auto-organized, external dependencies first
- **Components**: Use `cn()` utility for conditional CSS classes
- **Type Safety**: ORPC provides end-to-end type safety between frontend/backend

### Error Handling & Security

- Always implement proper error handling
- NEVER expose primary key IDs to end users or in URLs
- Use environment variables for sensitive data
- NEVER hardcode API keys or credentials

### AI Integration & Security Standards

- **Input Validation**: All user inputs MUST be sanitized using DOMPurify or equivalent before processing
- **Rate Limiting**: Implement appropriate rate limiting for all AI API endpoints (AI: 15/min, Images: 20/min, General: 100/min)
- **File Security**: Image uploads MUST include MIME type validation, file size limits, and header verification
- **User Authorization**: Strict ownership verification required for all AI-enhanced content operations
- **Audit Logging**: Comprehensive logging for AI usage, security events, and suspicious activities
- **Timeout Protection**: All external API calls MUST include configurable timeout protection
- **Performance Optimization**: Use React.memo, memoized callbacks, and lazy loading for AI-enhanced components

## Required Practices

### Code Quality

- Maintain type safety throughout the application
- Test integrations with real APIs, not mocks
- Follow established file organization patterns
- Keep components focused and reusable

### Documentation

- Update ALL documentation files as need when creating a PR or committing changes changes
- Ensure consistency across all documentation
- Document architectural decisions and patterns

  ### Major Feature Documentation Requirements belong in the `/docs` folder
  - **What goes in `/docs`:**
    - **Comprehensive Feature Documentation**: All major features implemented through design or requirements document MUST include a detailed documentation file in the docs/ folder following the established format or incorporated into an existing document if it is a enhancement of an existing feature
    - **Cross-Documentation Review**: ALL existing documentation files MUST be reviewed and updated for consistency when new features are added
    - **Documentation Standards**: Follow the structure and style of existing documentation files with technical accuracy and user-focused content
    - Permanent system documentation
    - Architecture guides
    - Feature documentation
    - API specifications
    - User guides and operational documentation
    - Document public interfaces: purpose, inputs, outputs, side-effects.
    - Include quickstart steps where relevant.
    - **If you think a new document should be created ask the user first**
    ```
    For files in the `/docs` folder, only include up-to-date documentation for each feature—do not include historical or overly technical details. Documentation should provide:
    * Overviews of feature sets
    * Basics of the tech stack
    * Clear explanations of complex or tricky portions, with examples as needed
    * You may reference code files, method names, parameters, and calling formats, but avoid excessive code snippets or SQL statements.
    * Documentation should help both human and AI developers quickly understand features and efficiently locate relevant code for deeper review.
    ```

  ### Change Log `\changelog.md`
  - Create and maintain a changelog.md file in the root folder to track all change log information this should be update whenever a PR or Commit is performed. But not until then.

  ### Read Me files `\README.md` , `**/README.md` , `**/README.*.md`
  - `\README.md` is the main README.md and MUST be updated to include new feature descriptions, API endpoints, and configuration details but should be kept concise (Bullet points not paragraphs)
    - **Utility Function Documentation**: When creating reusable utility functions, MUST update steering documents and README.md to ensure future development uses these utilities instead of duplicating code
  - if there is a `README.md` in a folder, it is specific to that folder and should be update with any information concerning the code in that folder, this can be more detailed that the main README.md but still not verbose.
  - if there is a `README.*.md` where the \* is a word or phrase such as backend, architure, frontend it is specific to that subject and should be update with any information concerning the code related to that subject, this can be more detailed that the main README.md but still not verbose.
    ```
    For example, README.architecture.md might explain:
        How the app is structured
        Key architectural decisions
        How data flows between client and server
        Which patterns to follow when adding new features
    ```
  - Keep README and folder-level readme.md files up to date with changes.

### AI Feature Development Workflow

- **Security First**: Implement all security measures (validation, sanitization, rate limiting) before functionality
- **Performance Optimization**: Apply memoization, lazy loading, and component optimization from the start
- **Test Coverage**: Create comprehensive test documentation following the established manual testing pattern
- **External Service Integration**: Always include timeout protection, retry logic, and graceful degradation
- **Usage Tracking**: Implement comprehensive audit logging for AI usage, costs, and performance metrics
- **User Experience**: Provide real-time feedback, progress indicators, and meaningful error messages

### Data Integrity

- Treat all existing data as production data
- Never modify production data for testing purposes
- Never transfer data between users without explicit permission
- Implement proper user data isolation

## Forbidden Actions

### Database Operations

- No database schema modifications without explicit approval
- No SQL commands that modify database structure without permission
- No bypassing authentication for testing
- No creating test users or modifying user IDs in existing records

### Code Management

- No removing test endpoints or debug features without user approval
- No cleaning up testing code without explicit permission
- No substituting technology stack components
- No using underscores in variable, table, or field naming

### Environment Configuration

- **Never overwrite existing environment variables** without explicit user consent
- When adding new environment variables, preserve all existing configuration
- Always check for existing `.env` files before creating new ones
- Ask the user about their current environment setup before making changes
- If unsure about existing configuration, read the current values first and add only new variables

## Component Management

### Orphaned Components

- Alert user immediately when changes may create orphaned components
- Scan for orphaned components during refactoring
- Verify components are truly orphaned before removal (check imports, dynamic imports, indirect usage)
- Provide list of orphaned components for user examination

### File Organization

- Follow established directory structure patterns
- Maintain clear separation between features
- Use consistent naming conventions across the codebase

### Component Architecture Standards

- **Performance-First Design**: All complex components MUST use React.memo and memoized callbacks
- **Accessibility Compliance**: All interactive components MUST include proper ARIA labels and keyboard navigation
- **Error Boundaries**: Components handling external APIs MUST include comprehensive error handling and retry logic
- **Progressive Enhancement**: Components should work without AI features enabled and gracefully degrade
- **Reusability**: Design components for reuse across different contexts with proper prop interfaces
- **State Management**: Use appropriate state management (local state, context, or global store) based on scope

### AI-Enhanced Component Patterns

- **Split View Design**: AI enhancement dialogs MUST show original vs enhanced content side-by-side
- **Progress Feedback**: All AI operations MUST provide visual progress indicators and loading states
- **Rate Limit Handling**: Components MUST gracefully handle rate limiting with meaningful user feedback
- **Tone Integration**: AI components MUST integrate with user tone preferences and settings
- **Usage Analytics**: All AI components MUST track usage for cost optimization and user insights

## Communication Guidelines

### Before Implementation

- Explain what you're going to do and why
- Break down complex tasks into clear steps
- If a task is estimated to take longer than 10 minutes, break it into smaller task
- Ask for clarification if requirements are unclear
- Provide brief explanations for technical decisions

### Language Style

- Use simple, everyday language
- Be clear and concise
- Focus on practical implementation details

### Priorities
- zero avoidable mistakes
- clarity of intent
- rapid iteration
- high-quality, maintainable code aligned to the project’s goals

### Mindset
- Deliver excellence. Strive for zero-escape defects. If unsure, ask targeted clarifying questions.
- Work methodically: plan → execute → verify → improve.
- Be explicit about assumptions and surface risks early.

### Core Workflow
1) Understand the task
   - Restate the goal in your own words.
   - Identify constraints, success criteria, dependencies, and edge cases.

2) Plan
   - Outline the approach.
   - Decompose into steps or parallelizable sub-tasks.
   - Note any files to read or generate.

3) Execute
   - Implement the smallest end-to-end slice first when possible.
   - Keep commits/changes cohesive and well-scoped.
   - Prefer clear, conventional solutions over cleverness.

4) Verify (self-assessment loop)
   - Validate against success criteria:
     - Functional correctness: does it satisfy the stated intent and inputs/outputs?
     - Quality: readability, naming, structure, tests, comments where needed.
     - Performance: consider complexity, hot paths, large inputs.
     - Reliability: error handling, edge cases, idempotency.
     - Security: inputs validated, secrets protected, least privilege.
     - Maintainability: separation of concerns, no unnecessary coupling.
   - Identify gaps, bugs, missing tests, or unclear areas.
   - Iterate until the solution reasonably scores 100/100 on the stated criteria.

5) Communicate
   - Provide a brief summary of changes, assumptions made, and how to verify.
   - If follow-ups are needed, list them explicitly.

### Parallel Sub-Agents (when helpful)
- You may conceptually split work into parallel sub-agents (e.g., “API spec,” “implementation,” “tests,” “docs”).
- Maintain clear boundaries and ownership to avoid stepping on each other.
- Integrate results through a final verification/consistency pass.

### Coding Standards
- Follow the language/framework community best practices.
- Consistent formatting and linting.
- Small, focused functions and modules.
- Strong typing where available; validate inputs and fail fast with clear errors.
- Write tests that reflect behavior and edge cases; prefer fast, deterministic tests.

### When Uncertain
- Ask concise, highly targeted clarifying questions.
- Propose a reasonable default and explain the trade-offs.

### Completion Criteria
- The solution meets the user’s intent and success criteria.
- Verification passes, including tests.
- Code is readable, maintainable, and documented.
- Risks and TODOs (if any) are explicitly listed with next steps.

### Scoring Rubric (self-check before finishing)
- Intent alignment (0–20)
- Functional correctness (0–20)
- Quality/readability (0–15)
- Tests and coverage of edge cases (0–15)
- Performance and reliability (0–10)
- Security and safety (0–10)
- Maintainability and docs (0–10)

Target: 100/100. Iterate until achieved or explicitly call out remaining gaps and why.


