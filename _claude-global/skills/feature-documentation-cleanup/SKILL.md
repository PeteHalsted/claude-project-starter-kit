---
name: feature-documentation-cleanup
description: This skill should be used after completing a major feature implementation to update all project documentation. It creates an as-built specification from the implemented code, updates technical architecture documentation, and updates the developer handbook to reflect the current state of the codebase. Use this skill when asked to "clean up documentation" or "update docs after feature completion."
---

# Feature Documentation Cleanup

## Overview

After completing a major feature, the project documentation must be updated to reflect the as-built reality. This skill orchestrates three critical documentation tasks: (1) creating a consolidated Product Requirements Document (PRD) from the implemented feature, (2) updating the technical architecture to document new system components, and (3) updating the developer handbook with new workflows and patterns.

## When to Use This Skill

Trigger this skill when:
- User says "clean up documentation after completing [feature]"
- User says "update all docs for the [feature-name] feature"
- User says "create the as-built spec for [feature]"
- After completing a major feature and before merging to main branch

## Core Workflow

### Step 1: Gather Context

Ask the user:
1. **What is the feature branch name?** (e.g., `client-onboarding-and-billing`)
2. **What was the original spec folder?** (e.g., `specs/001-users-petehalsted-projects/`)
3. **Are there related spec documents to reference?** (e.g., other feature specs that overlap)

### Step 2: Create As-Built Specification

Follow the complete process outlined in `references/create-as-built-spec-prompt.md`:

1. **Analyze Implementation:**
   - Review git commits on feature branch: `git log --oneline --grep="feat:"`
   - Examine database schema files in `apps/web/src/db/schema/`
   - Review implemented UI components and server functions
   - Identify actual user-facing behaviors

2. **Present Feature List:**
   - Categorize features as:
     - **Core features** (from original spec, possibly modified)
     - **Additional features** (added during implementation)
     - **Implementation details** (architectural support, not separate features)
   - Ask user which features should be included in spec

3. **Clarify Implementation Details:**
   - Ask about changes from original design
   - Confirm actual user workflows
   - Identify edge cases and error handling added
   - Capture business rules and constraints

4. **Create Specification Document:**
   - Name: `specs/[feature-name]-spec.md`
   - Follow `spec-template.md` structure strictly
   - Write for business stakeholders (WHAT/WHY, not HOW)
   - Include:
     - User scenarios ("As a... I want... so that...")
     - Acceptance scenarios (Given/When/Then)
     - Functional requirements (testable "System MUST...")
     - Key entities (what they represent, not database schema)
     - Success criteria (measurable outcomes)
     - Out of scope (explicit boundaries)
     - Dependencies & assumptions

5. **Quality Check:**
   - ❌ No technology stack (React, TanStack, Drizzle, etc.)
   - ❌ No code structure (file paths, function names)
   - ❌ No database implementation (SQL, schema details)
   - ❌ No API endpoints or implementation patterns
   - ✅ User workflows and scenarios
   - ✅ Business rules and validation
   - ✅ What data entities represent
   - ✅ Success criteria and outcomes

### Step 3: Update Technical Architecture

Review `project-documentation/technical-architecture.md` against current codebase using `references/tech-arch-checklist.md`:

1. **Database Architecture Section:**
   - Add any new schema files to the schema organization list
   - Verify all tables are documented

2. **External Service Integrations:**
   - Add new integrations to "Current Integrations"
   - Move implemented integrations from "Planned" to "Current"
   - Document: purpose, integration method, features, configuration

3. **System Component Design:**
   - Add new server function categories
   - Update component architecture with new component directories
   - Document new data flow patterns

4. **New Architecture Sections** (if major feature area):
   - Add dedicated section for major new subsystems
   - Include: system design overview, workflow, technical decisions
   - Example: "Billing & Subscription System Architecture"

5. **Implementation Status:**
   - Move features from "Partially Implemented" to "Fully Implemented"
   - Add newly implemented features
   - Remove features that are no longer relevant

**Document Purpose Reminder:**
- **INCLUDE**: High-level system design, architectural decisions, WHY technical choices were made, HOW components interact, WHAT patterns are used
- **EXCLUDE**: Historical information, backward compatibility notes, step-by-step development instructions, code pattern examples (those belong in MFing Bible documents)

### Step 4: Update Developer Handbook

Review `project-documentation/developer-handbook.md` against current codebase using `references/dev-handbook-checklist.md`:

1. **Environment Variables:**
   - Add any new required environment variables
   - Group by category (Auth, Payment, Email, etc.)
   - Include brief description of each

2. **Project Structure:**
   - Update `routes/` directory tree with new routes
   - Update `lib/serverFunctions/` with new server function files
   - Update `hooks/` with new hook files
   - Update `components/` with new component directories
   - Update `db/schema/` with new schema files

3. **Common Workflows Section:**
   - Add workflow sections for major new features
   - Include: purpose, location, step-by-step workflow, server functions used, testing commands, common issues
   - Example: "Converting Prospect to Client (Billing Setup)"

4. **Update Outdated References:**
   - Fix file path references that have changed
   - Update function names that have been renamed
   - Correct route paths

**Document Purpose Reminder:**
- **INCLUDE**: Workflows, commands, patterns, troubleshooting, "how to work here" knowledge
- **EXCLUDE**: "How the system works" (that's technical-architecture.md), historical information, deprecated patterns

### Step 5: Commit All Documentation Updates

Create git commits for each documentation update:

1. **As-Built Spec:**
   ```
   📚 docs: add [feature-name] as-built specification
   ```

2. **Technical Architecture:**
   ```
   📚 docs: update technical architecture with [major feature areas]
   ```

3. **Developer Handbook:**
   ```
   📚 docs: update developer handbook with [new workflows]
   ```

## Resources

### references/

This skill references the following documentation files to guide the cleanup process:

- **create-as-built-spec-prompt.md** - Complete template and process for creating as-built specifications
- **tech-arch-checklist.md** - Checklist of what to review when updating technical-architecture.md
- **dev-handbook-checklist.md** - Checklist of what to review when updating developer-handbook.md

These files should be read as needed during the workflow to ensure complete and accurate documentation updates.

## Common Patterns

**Feature with Multiple Sub-Features:**
- Present all features to user for inclusion decision
- User may exclude some features that belong in separate specs
- Create one consolidated spec covering included features

**Feature Touching Existing Systems:**
- Focus spec on new capabilities, not entire system
- Update architecture/handbook sections for modified areas
- Reference existing documentation for unchanged parts

**Small Feature vs Major Feature:**
- Small features: May only need handbook workflow update
- Major features: Always need all three documentation updates
- When in doubt, ask user which docs need updating

## Success Criteria

**Spec Document:**
- ✅ Focuses on WHAT/WHY, not HOW
- ✅ Testable requirements
- ✅ Written for business stakeholders
- ✅ Could recreate similar codebase if re-implemented

**Technical Architecture:**
- ✅ Reflects current production state only
- ✅ No historical/backward compatibility notes
- ✅ All new integrations documented
- ✅ Implementation status accurate

**Developer Handbook:**
- ✅ All new workflows documented
- ✅ Environment variables complete
- ✅ Project structure current
- ✅ No outdated file references

## Notes

- Always commit each documentation file separately for clean git history
- Use gitpro agent for commits with conventional commit format
- Ask user for clarification when features are ambiguous
- Prioritize accuracy over completeness - better to ask than guess
