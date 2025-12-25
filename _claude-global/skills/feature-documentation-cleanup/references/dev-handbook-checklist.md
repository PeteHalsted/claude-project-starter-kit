# Developer Handbook Update Checklist

Use this checklist when updating `project-documentation/developer-handbook.md` to ensure all practical development information is current.

## Document Purpose

**WHAT BELONGS:**
- Workflows, commands, patterns, troubleshooting
- "How to work here" knowledge
- Practical development guidance
- Current state only

**WHAT DOESN'T BELONG:**
- "How the system works" (that's technical-architecture.md)
- Historical information or deprecated patterns
- Architectural decisions (that's technical-architecture.md)

---

## Section-by-Section Review

### 1. Environment Variables

**Check:**
- [ ] All required environment variables documented
- [ ] Variables grouped by category (Auth, Payment, Email, etc.)
- [ ] Brief description for each variable

**What to Add:**
```bash
# [Category Name]
VARIABLE_NAME=          # Brief description
ANOTHER_VAR=            # Brief description
```

**Common Missing Variables:**
- Payment processing keys (Stripe, PayPal)
- Email service keys (Resend, SendGrid)
- API keys for external services
- Feature flags

---

### 2. Project Structure

**Check `routes/` directory:**
- [ ] All major route directories listed
- [ ] Admin routes documented
- [ ] Client routes documented
- [ ] API routes documented

**Check `lib/serverFunctions/`:**
- [ ] All server function files listed
- [ ] One-line description for each
- [ ] No outdated file names

**Check `hooks/`:**
- [ ] All major hooks listed
- [ ] Brief description of purpose

**Check `components/`:**
- [ ] Component directories organized by feature
- [ ] All major categories listed (ui, billing, forms, etc.)

**Check `db/schema/`:**
- [ ] All schema files listed
- [ ] Brief description for each

**Update Format:**
```
├── [directory]/
│   ├── [file].ts      # Brief description
│   ├── [file].ts      # Brief description
│   └── [subdirectory]/
│       └── [file].ts  # Brief description
```

---

### 3. Common Workflows Section

**Add New Workflow When:**
- Feature has complex user-facing workflow
- Workflow requires multiple steps
- Common developer task for this feature

**Workflow Template:**
```markdown
### [Workflow Name]

**Purpose**: [What this accomplishes in 1 sentence]

**Location**: [Route or component path]

**Workflow**:
1. [Step 1]
2. [Step 2]
3. [Step 3]
   - [Sub-step if needed]
4. [Step 4]

**Server Functions Used**:
- `[filename]::[function]` - [What it does]
- `[filename]::[function]` - [What it does]

**Testing**:
```bash
npm test -- [test-file].test.ts --run
```

**Common Issues**:
- [Issue description]
- [Solution or check]
```

**Examples from Codebase:**
- "Converting Prospect to Client (Billing Setup)"
- "Managing Website Projects & S3 Slugs"
- "Form Extraction & Management"
- "Stripe Webhook Processing"

---

### 4. Update Outdated References

**Common Outdated References:**
- [ ] Old file names (e.g., `prospectsFn.ts` → `contactFn.ts`)
- [ ] Old route paths
- [ ] Deprecated function names
- [ ] Changed component locations

**Find and Replace:**
```bash
# Search for outdated references
grep -r "prospectsFn" developer-handbook.md
grep -r "/admin/prospects/index.tsx" developer-handbook.md
```

---

### 5. Testing Section

**Add Testing Guidance For:**
- [ ] New feature test files
- [ ] Testing external integrations (mocking)
- [ ] Testing webhooks
- [ ] Testing billing/payment flows

**What to Add:**
```bash
# Test specific feature area
npm test -- [feature]Fn.test.ts --run

# Test integration
npm test -- [integration].test.ts --run
```

---

## Common Updates by Feature Type

### New Billing/Payment Feature
- [ ] Environment Variables → Payment API keys
- [ ] Project Structure → Billing server functions, components, schemas
- [ ] Common Workflows → Payment setup workflow
- [ ] Common Workflows → Subscription management workflow
- [ ] Common Workflows → Webhook processing workflow

### New External Integration Feature
- [ ] Environment Variables → Integration API keys
- [ ] Project Structure → Integration server functions
- [ ] Common Workflows → Integration setup/usage
- [ ] Troubleshooting → Integration-specific issues

### New UI/Component Feature
- [ ] Project Structure → Component directories
- [ ] Component Development → Examples using new components
- [ ] Common Workflows → User workflow with new UI

---

## Workflow Quality Checks

For each workflow added, verify:

- [ ] **Purpose is clear**: Single sentence explaining what it accomplishes
- [ ] **Location is specific**: Exact route or component path
- [ ] **Steps are actionable**: Developer can follow without guessing
- [ ] **Server functions listed**: Shows which backend code is involved
- [ ] **Testing included**: How to test this workflow
- [ ] **Common issues documented**: Known pitfalls and solutions
- [ ] **No implementation details**: Focuses on "how to use" not "how it works internally"

---

## Example Updates

**Bad (too much internal detail):**
```markdown
The convertToClient function uses Stripe SDK to create a customer object
by calling stripe.customers.create() with the contact's business info,
then stores the returned ID in the contact.stripecustomerid field.
```

**Good (practical workflow):**
```markdown
### Converting Prospect to Client (Billing Setup)

**Purpose**: Convert a prospect into a paying client with automated subscription billing.

**Location**: `/admin/prospects/$prospectId/prospect-details.tsx` → "Convert to Client" button

**Workflow**:
1. Admin selects prospect with an associated website project
2. Modal opens with billing plan selection
3. System creates Stripe customer, subscription, and invoice
4. Client receives welcome email with portal access link

**Server Functions Used**:
- `contactFn.ts::convertToClient()` - Main conversion orchestration
- `stripeFn.ts::createStripeCustomer()` - Create Stripe customer

**Testing**:
```bash
npm test -- contactFn.test.ts --run
```

**Common Issues**:
- Ensure at least one recurring product is selected
- Verify Stripe API keys in .env
```

---

## Quality Checks

Before committing updates:

- [ ] **No Outdated References**: All file paths, function names current
- [ ] **No Historical Information**: Remove "we used to...", "previously..."
- [ ] **Current State Only**: Reflects production codebase as-is
- [ ] **Practical Focus**: Emphasizes "how to work" not "how it works"
- [ ] **Consistent Formatting**: Follow existing structure
- [ ] **Examples Are Concrete**: Use actual file paths and function names from codebase

---

## After Updates

Create commit with gitpro:
```
📚 docs: update developer handbook with [new workflows/updates]

- Added [workflow names]
- Updated project structure with [new files]
- Added environment variables for [feature]
```
