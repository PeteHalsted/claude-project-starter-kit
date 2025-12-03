# Development Guidelines

**Note**: Core architectural, database, security, and technology stack decisions are governed by the project Constitution. This document covers implementation-specific guidelines not addressed in the Constitution.

## Core Principles

### Code Quality & TypeScript Implementation
- **Type Safety**: Always include TypeScript types for function parameters and return values
- Maintain type safety throughout the application
- **Boolean Assignment**: When assigning to boolean variables using chained `&&` operators, use strict boolean conversion with `!!()`:
  ```typescript
  // ❌ WRONG - assigns truthy/falsy values (undefined, null, objects, etc.)
  const isValid = user && user.email && user.verified;
  
  // ✅ CORRECT - always assigns true or false
  const isValid = !!(user && user.email && user.verified);
  ```
  This is critical for: test result tracking, conditional logic, state management, and any code expecting strict boolean values.

## Debugging & Troubleshooting

### Debugging Philosophy: New Code is Guilty Until Proven Innocent
When investigating bugs or test failures, **always assume new code is the problem first**:

1. **Start with Recent Changes**: Examine code added/modified in the last session or PR first
2. **Trust Stable Infrastructure**: Assume well-tested, production code (weeks/months old) is correct
3. **Prove Innocence**: Only investigate stable code after definitively ruling out new code
4. **Question Your Assumptions**: When a user says "this has been stable for weeks", they're probably right

**Example**: If tests are failing after adding new features, check the new test code before blaming the test framework that's been running hundreds of tests successfully.

### Debugging Workflow
1. Identify when the issue first appeared (new code vs. existing code)
2. Review recent changes in affected areas
3. Check for common pitfalls (boolean assignment, type coercion, async issues)
4. Use logging to verify assumptions
5. Only after exhausting new code investigation, examine stable infrastructure

## Structured Logging & Debugging (Adze)
All logging MUST be done using the Adze logger as specified in `project-documentation/logging-with-adze.md`.
- **No `console.log`**: Use the namespaced Adze logger (`logger.ns(...)`).
- **Collaborative Debugging**: The human developer runs the dev server. The AI agent monitors logs via `tail -f logs/server.log`. The dev server must not be run by the AI agent without explicit permission.

## Web Development Standards

### Frontend Policy
- All icon-only buttons must include tooltips on hover

### Responsive Design Considerations

**Responsive Design**: All UI changes MUST be analyzed for responsive impact across mobile, tablet, and desktop breakpoints.

**ALWAYS consider and analyze responsive design impact before making ANY UI changes.**

When making UI changes, you MUST:

1. **Analyze responsive impact** across mobile, tablet, and desktop breakpoints
2. **Explicitly mention responsive considerations** in explanations
3. **Warn the user immediately** if a change could cause responsive issues
4. **Consider**: horizontal/vertical space usage, text wrapping, touch targets, grid/flex behaviors
5. **Test mentally** across breakpoints: `sm:`, `md:`, `lg:`, `xl:` classes
6. **Use ShadCN MCP** - for any work with shadcn components you MUST ALWAYS consult the ShadCN MCP for guidance.

**Evaluate every UI change for:**

- Mobile horizontal space constraints
- Text overflow/wrapping potential
- Touch target accessibility (minimum 44px)
- Grid/flex layout behavior changes
- Visual hierarchy on different screen sizes

**Never treat responsive design as an afterthought - it must be a primary consideration.**

### Web Styling & UI Implementation Details
- **Styling**: Use Tailwind CSS for styling. All UI components must be built from `shadcn/ui` primitives
- **Semantic Naming**: Use semantic naming for all CSS or Tailwind classes (ButtonActive not ButtonRed)
- **Authentication Theming**: Use @clerk/themes with baseTheme pattern for Clerk components
- **Semantic Classes**: Prefer semantic classes (`text-foreground`, `text-muted-foreground`) over manual dark mode classes
- **Theme Integration**: Follow established baseTheme pattern: `baseTheme: theme === "dark" ? dark : undefined`
- **Imports**: Auto-organized, external dependencies first
- **Components**: Use `cn()` utility for conditional CSS classes

## Mobile Development Standards

### Mobile Design Principles
- **Touch Targets**: Minimum 44px for accessibility compliance on all interactive elements
- **Mobile Performance**: Optimize for mobile performance and battery life
- **Cross-Platform Compatibility**: Ensure components work consistently across iOS and Android platforms

### Mobile Styling & UI
- Follow React Native styling patterns with StyleSheet
- Use platform-specific design guidelines (iOS HIG, Android Material Design)
- Ensure proper contrast ratios and accessibility compliance

### Mobile Component Architecture
- **Mobile Optimization**: Components must be optimized for touch interaction and mobile screen sizes
- **Performance-First Design**: All complex components MUST use React.memo and memoized callbacks
- **Accessibility Compliance**: All interactive components MUST include proper ARIA labels and keyboard navigation
- **Error Boundaries**: Components handling external APIs MUST include comprehensive error handling and retry logic
- **Reusability**: Design components for reuse across different contexts with proper prop interfaces
- **State Management**: Use appropriate state management (local state, context, or global store) based on scope

## Implementation-Specific Requirements

### Documentation Implementation Details
- The `technical-documentation-specialist` MUST be used for all documentation tasks.
- Follow the structure and style of existing documentation files with technical accuracy and user-focused content
- Documentation for permanent systems belongs in `/project-documentation`.
- For files in the `/project-documentation` folder, only include up-to-date documentation for each feature. Not historical information. We don't care why we made certain decisions or how they were implemented.
- Include clear explanations of complex or tricky portions, with examples as needed

### Additional Forbidden Actions

#### Testing
- No bypassing authentication for testing
- No creating test users or modifying user IDs in existing records
- **Data Integrity**: Treat all existing data as production data. Never modify production data for testing purposes. Never transfer data between users without explicit permission.

#### Environment Configuration
- When adding new environment variables, preserve all existing configuration
- Always check for existing `.env` files before creating new ones
- Ask the user about their current environment setup before making changes
- If unsure about existing configuration, read the current values first and add only new variables

## Development Workflow

**Core Commands**:
- `npm run dev`: Start the development server.
- `npm run db:generate`: Generate a new database migration.
- `npm run db:migrate`: Apply pending migrations.
- `npm run check-types`: Run TypeScript type checking.

### Database Query Access (psql)

**Direct Database Queries**: Use `psql` for quick database queries and data exports instead of writing Node.js scripts.

**Environment Setup**: The `.env` file contains both production and development DATABASE_URL entries. One is always commented out for easy switching between environments.

**Query Pattern**:
```bash
# Extract active DATABASE_URL (strips inline comments after ##)
DATABASE_URL=$(grep "^DATABASE_URL=" .env | cut -d'=' -f2- | cut -d'#' -f1 | xargs)

# Run query
psql "$DATABASE_URL" -c "SELECT * FROM tablename;"

# Export to CSV
psql "$DATABASE_URL" -c "\copy tablename TO 'export.csv' CSV HEADER;"
```

**AI Agent Restrictions**: AI agents MUST NEVER run drizzle commands (`npm run db:generate`, `npm run db:migrate`, `npm run db:push`). These require human interaction due to interactive prompts and data risks. For read-only queries and exports, use `psql` as shown above.

## Code Health & Refactoring
- **Automated Formatting**: All code must be formatted using Biome (`npm run format`) to ensure consistent style.
- **Identifying Unused Code**: Rely on Biome's linting capabilities to automatically detect orphaned or unused components, variables, and imports.
- **Manual Verification**: Before deleting code flagged by the linter, perform a quick manual check for any indirect usage (like dynamic imports) that the static analysis might have missed.
