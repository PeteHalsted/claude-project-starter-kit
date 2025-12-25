# Technical Architecture Update Checklist

Use this checklist when updating `project-documentation/technical-architecture.md` to ensure all aspects of new features are documented.

## Document Purpose

**WHAT BELONGS:**
- High-level system design and architectural decisions
- WHY technical choices were made
- HOW components interact
- WHAT patterns are used
- Current production state only

**WHAT DOESN'T BELONG:**
- Historical information or backward compatibility notes
- Step-by-step development instructions (that's developer-handbook.md)
- Code pattern examples (that's MFing Bible documents)
- Implementation tutorials

---

## Section-by-Section Review

### 1. Database Architecture

**Check:**
- [ ] All new schema files listed in "Schema Files" section
- [ ] Schema organization follows current naming conventions
- [ ] Migration workflow reflects current process

**What to Add:**
- New schema files with brief description
- Example: `subscription.ts - Client subscription metadata and status`

---

### 2. External Service Integrations

**Check "Current Integrations":**
- [ ] New integrations added (Stripe, Resend, new APIs)
- [ ] Each integration documents: purpose, integration method, features, configuration
- [ ] Webhook handling documented if applicable

**Check "Planned Integrations":**
- [ ] Move implemented integrations from "Planned" to "Current"
- [ ] Remove integrations that are no longer planned

**What to Add:**
- Integration name (e.g., "Stripe Payment Processing")
- Purpose statement
- Integration approach (SDK, REST API, webhook)
- Key features list
- Security considerations (signature verification, etc.)

---

### 3. Server Functions Architecture

**Check:**
- [ ] All new server function categories listed
- [ ] File names match actual codebase
- [ ] Brief description of each category's purpose

**What to Add:**
- New server function files (e.g., `billingFn.ts`, `stripeFn.ts`)
- One-line description of each
- Example: `stripeFn.ts - Stripe payment processing`

---

### 4. Component Architecture

**Check:**
- [ ] New component directories documented
- [ ] Component organization by feature area clear
- [ ] Admin portal vs Client portal separation maintained

**What to Add:**
- New component directories
- Example structure showing organization
- Brief description of component categories

---

### 5. New Architecture Sections

**Add New Section When:**
- Feature is a major new subsystem (billing, authentication, etc.)
- Feature has complex workflows requiring architectural explanation
- Feature involves multiple integrations or components

**Section Template:**
```markdown
## [Feature Name] Architecture

### System Design Overview
**Purpose**: [What problem does this solve?]
**Architecture Pattern**: [How is it designed?]

### [Key Workflow Name]
[Step-by-step flow]

### [Technical Decisions]
**Why [Decision]?**
- **Problem**: [What issue did we face?]
- **Solution**: [How did we solve it?]
- **Benefit**: [What did we gain?]

### Data Synchronization Pattern
[How data flows between systems]
```

**Examples from Codebase:**
- "Billing & Subscription System Architecture"
- "Website Project Management Architecture"
- "Form Management & Extraction Architecture"
- "Regional Market Research Architecture"

---

### 6. Implementation Status

**Check "Fully Implemented Features":**
- [ ] Move features from "Partially Implemented" to "Fully Implemented"
- [ ] Add newly completed feature areas
- [ ] Include comprehensive feature list with key capabilities

**Check "Partially Implemented Features":**
- [ ] Remove features that are now fully implemented
- [ ] Update status of features still in progress

**Check "Planned Features":**
- [ ] Add new planned features discovered during implementation
- [ ] Remove features that were completed or descoped

**What to Add:**
- Feature category name in bold
- Bullet list of implemented capabilities
- Specific mentions of key features (not generic statements)

---

## Common Updates by Feature Type

### New Billing/Payment Feature
- [ ] External Service Integrations → Add payment processor
- [ ] New Architecture Section → Billing workflow
- [ ] Server Functions → Billing/payment server functions
- [ ] Component Architecture → Billing components
- [ ] Database Architecture → Payment-related schemas
- [ ] Implementation Status → Move to fully implemented

### New Data Integration Feature
- [ ] External Service Integrations → API integration details
- [ ] Server Functions → Integration server functions
- [ ] Database Architecture → New data schemas
- [ ] Implementation Status → Add feature

### New User-Facing Feature
- [ ] Component Architecture → New UI components
- [ ] New Architecture Section (if complex workflow)
- [ ] Server Functions → Feature server functions
- [ ] Implementation Status → Add feature

---

## Quality Checks

Before committing updates:

- [ ] **No Historical Information**: Remove "we used to...", "previously...", "migrated from..."
- [ ] **No Implementation Details**: No code snippets, file paths, or function names (unless demonstrating pattern)
- [ ] **Current State Only**: Reflects production codebase as-is
- [ ] **Consistent Terminology**: Use same terms as rest of document
- [ ] **Proper Formatting**: Follow existing section structure and markdown conventions

---

## Example Updates

**Bad (too much implementation detail):**
```markdown
We use the `stripeFn.ts` file with functions like `createCustomer()` 
and `createSubscription()` which call the Stripe SDK at 
`node_modules/@stripe/stripe-js`.
```

**Good (architectural focus):**
```markdown
**Stripe Payment Processing**
- **Purpose**: Subscription billing, invoice generation, and payment collection
- **Integration**: Stripe SDK with comprehensive server function wrapper
- **Webhook Handling**: Secure signature verification for invoice lifecycle events
- **Features**: Customer and subscription management, invoice tracking, payment method updates
```

**Bad (historical):**
```markdown
Previously we used Clerk for billing, but we migrated to Stripe because...
```

**Good (current state):**
```markdown
**Stripe Payment Processing**
- **Purpose**: Subscription billing and payment collection
```

---

## After Updates

Create commit with gitpro:
```
📚 docs: update technical architecture with [major areas updated]

- Added [new integration] to current integrations
- Documented [new feature] architecture
- Updated implementation status for [features]
```
