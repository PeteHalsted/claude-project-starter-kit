# Prompt: Create As-Built Feature Specification

Use this prompt when completing a feature to create a consolidated Product Requirements Document (PRD) that reflects the actual implemented system.

---

## Context

After completing a feature implementation, we need to encode the "as-built" reality back into a specification document. This document should be written as a Product Requirements Document (PRD) that focuses on WHAT users need and WHY, not HOW it was implemented. The goal is that if we fed this spec back through the plan and implement phases, we would end up with a very similar codebase.

**Template Location:** `.specify/templates/spec-template.md`

---

## Your Task

Create a consolidated specification document named `[feature-name]-spec.md` in the `/specs` folder by:

1. **Analyzing the implementation:**
   - Review git commits on the feature branch to identify all features added
   - Examine database schema changes for new entities and fields
   - Review implemented UI components and workflows
   - Identify the actual user-facing behaviors (not design documents)

2. **Identifying features for inclusion:**
   - Present a list of all features you've identified from the commits
   - For each feature, ask me whether it should be included in the spec
   - Some features may be:
     - **Core features** (from original spec, possibly modified during implementation)
     - **Additional features** (added during implementation, not in original spec)
     - **Implementation details** (architectural changes that support core features but aren't separate features)
     - **Out of scope** (features from other branches that should not be included)

3. **Creating the specification:**
   - Follow the spec-template.md structure strictly
   - Write for business stakeholders, not developers
   - Focus on user scenarios, acceptance criteria, and functional requirements
   - Document key entities from the actual database schema (no implementation details)
   - Capture success criteria and clear scope boundaries

---

## Important Guidelines

### What to Include:
- **User scenarios** - "As an [actor], I want to [action], so that [value]"
- **Acceptance scenarios** - Given/When/Then format
- **Functional requirements** - Testable "System MUST..." statements
- **Key entities** - What they represent (not database implementation)
- **Edge cases** - Error handling and boundary conditions
- **Success criteria** - Measurable outcomes
- **Out of scope** - What's explicitly NOT included
- **Dependencies & assumptions** - External APIs, business rules, data constraints

### What to Exclude:
- ❌ Technology stack (no "React", "TanStack", "Drizzle", etc.)
- ❌ Code structure (no file paths, function names, imports)
- ❌ Database implementation (no SQL, no schema details, no migration commands)
- ❌ API endpoints or HTTP methods
- ❌ Implementation patterns or architecture decisions
- ❌ Build/deployment procedures

### Document Scope:
- **Mandatory sections** - Must be completed for every feature
- **Optional sections** - Include only when relevant (remove entirely if not applicable)
- **Product Requirements** - This is NOT a technical design document

---

## Process Flow

### Step 1: Analyze Implementation
Ask me:
1. What is the feature branch name?
2. What was the original spec folder (if one exists)?
3. Are there any related spec documents I should reference?

Then analyze:
- Git commit history for feature commits (`git log --oneline --grep="feat:"`)
- Database schema files in `apps/web/src/db/schema/`
- Key server functions and components
- Implemented workflows and status transitions

### Step 2: Present Feature List
Show me a categorized list:

**Core Features (From Original Spec):**
- [Feature name] - [Brief description]
- ...

**Additional Features (Added During Implementation):**
- **Feature A**: [Name and description]
  - **Should this be included?**
- **Feature B**: [Name and description]
  - **Should this be included?**
- ...

**Questions:**
1. Which of the additional features should be included?
2. Are there any other features I missed?
3. Should any features be noted differently (e.g., as implementation details)?

### Step 3: Clarify Implementation Details
For features I confirm should be included, ask clarifying questions:
- "Was [feature] implemented as designed or did it change?"
- "What was the actual user workflow for [feature]?"
- "Were there edge cases or error handling added during implementation?"
- "Are there constraints or business rules I should capture?"

### Step 4: Create Specification
Write the spec document following spec-template.md:
1. Use clear, business-focused language
2. Write testable requirements
3. Document actual implemented behavior (not original design)
4. Include version history noting this is "As-Built Production Specification"

---

## Example Interaction

**User:** "Now that we have completed this feature, we will be cleaning up the [feature-folder]. Create a [feature-name]-spec.md document based on the original spec files and the existing codebase."

**Assistant:** 
1. Analyzes git commits and identifies features
2. Presents feature list with questions about inclusion
3. User responds with which features to include and clarifications
4. Assistant asks follow-up questions about implementation details
5. Assistant creates the consolidated spec document
6. User reviews and requests any adjustments

---

## Quality Checklist

Before finishing, verify:
- [ ] No implementation details (no tech stack, code, APIs)
- [ ] All requirements are testable and unambiguous
- [ ] User scenarios follow "As a... I want... so that..." format
- [ ] Acceptance scenarios use Given/When/Then format
- [ ] Key entities describe WHAT they represent (not database schema)
- [ ] Success criteria are measurable
- [ ] Out of scope is clearly defined
- [ ] Dependencies and assumptions are documented
- [ ] Written for business stakeholders (not developers)
- [ ] Document would enable re-implementation if fed through plan/implement phases

---

## Remember

**The spec is a Product Requirements Document (PRD), not a technical implementation guide.**

Think like a product manager explaining to stakeholders what the system does and why, not an architect explaining how it works.

---

## Common Mistakes to Avoid

❌ Including file paths or code structure  
❌ Mentioning specific technologies or frameworks  
❌ Documenting database schemas or migrations  
❌ Explaining implementation patterns  
❌ Adding technical architecture diagrams  
❌ Referencing specific functions or components  

✅ Describing user workflows and scenarios  
✅ Defining business rules and validation  
✅ Specifying what data entities represent  
✅ Documenting success criteria and outcomes  
✅ Clarifying scope and boundaries  
✅ Capturing edge cases and error handling  

---

**End of Prompt Template**
