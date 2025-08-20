# Development Guidelines

## Core Principles

### Database Architecture

- **Table Naming**: Always use singular names (user not users, order not orders). Do not user phrase that may be SQL reserved words
- **Primary Keys**: Always named the same as the table name with the suffix id (userid, orderid)
- **Field Naming**: Use lowercase for PostgreSQL schema, camelCase for TypeScript variables, never use _ or any other special character for word separation in variablesnames (firstname NEVER first_name)
- **Foreign Keys**: Foreign keys in child tables, should be the same name as the primary key they are linked to in the parent table whenever possible (customer.customerid -> invoice.customerid). If there are 2 foreign keys in one childtable refering to the same parent table they should include a functional prefix. (employee.employeeid -> invoice.salesmanemployeeid and invoice.manageremployeeid)
- **Schema Changes**: Always ask for explicit permission before DROP, ALTER, or CREATE operations

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
- Use camelCase for all variables,properties,classes,functions (except PostgreSQL schema which is lowercase)
- Never use _ or any other special character for word separation in variables names (firstname or FirstName NEVER first_name)

### Styling & UI

- Use Tailwind CSS for styling, avoid inline styles
- Use Semantic naming for all CSS or Tailwind classes (ButtonActive not ButtonRed)
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

## Required Practices

### Code Quality

- Maintain type safety throughout the application
- Test integrations with real APIs, not mocks
- Follow established file organization patterns
- Keep components focused and reusable

### Documentation

- You MUST use the technical-documentation-specialist for all documenation task!
- ALL existing documentation files MUST be reviewed and updated for consistency when new features are added
- Follow the structure and style of existing documentation files with technical accuracy and user-focused content
- Documentation should help both human and AI developers quickly understand features and efficiently locate relevant code for deeper review.
- For files in the `/project-documentation` folder, only include up-to-date documentation for each feature—do not include historical or overly technical details. 
- You may reference code files, method names, parameters, and calling formats, but avoid excessive code snippets or SQL statements.
- Include clear explanations of complex or tricky portions, with examples as needed
- NEVER change or update files in project-documentation\design-documentation unless explicitly asked to or working on feature planing 

All permanent documenation belongs in the `/project-documentation` folder
 - **What goes in `/project-documentation`:**
    - **Comprehensive Feature Documentation**: All major features implemented through design or requirements document MUST include a detailed documentation file in the project-documentation/ folder following the established format or incorporated into an existing document if it is a enhancement of an existing feature
    - Permanent system documentation
    - Architecture guides
    - Feature documentation
    - API specifications
    - User guides and operational documentation
    - Document public interfaces: purpose, inputs, outputs, side-effects.
    - Include quickstart steps where relevant.
    - **If you think a new document should be created ask the user first**

  ### Change Log `\changelog.md`
  - Create and maintain a changelog.md file in the root folder to track all change log information 

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
  - Keep README and folder-level claude.md files up to date with changes.

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


