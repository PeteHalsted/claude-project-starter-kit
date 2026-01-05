# Anti-Patterns Reference

## Contents

- [Generic Names](#generic-names)
- [Parameter Safety](#parameter-safety)
- [loaderDeps Mistakes](#loaderdeps-mistakes)
- [Auth Logic Mistakes](#auth-logic-mistakes)
- [Database Connection Mistakes](#database-connection-mistakes)
- [Quick Reference Table](#quick-reference-table)

---

## Generic Names

### Don't Use Generic Route Names

```typescript
// ❌ WRONG: Multiple index.tsx files are confusing
src/routes/admin/prospects/index.tsx  // Which view is this?
src/routes/admin/campaigns/index.tsx  // Hard to distinguish in tabs

// ✅ CORRECT: Descriptive names
src/routes/admin/prospects/prospects-pipeline.tsx
src/routes/admin/campaigns/campaigns-dashboard.tsx
```

### Don't Use Inconsistent Naming

```typescript
// ❌ WRONG: Inconsistent naming
src/lib/serverFunctions/prospects.ts     // Missing Fn suffix
src/lib/serverFunctions/campaignsFn.ts   // Has Fn suffix

// ✅ CORRECT: Consistent naming
src/lib/serverFunctions/prospectsFn.ts
src/lib/serverFunctions/campaignsFn.ts
```

---

## Parameter Safety

### Don't Skip Parameter Safety

```typescript
// ❌ WRONG: Can crash if params is undefined
.handler(async ({ data: params }) => {
  if (params.search) { /* Will throw if params is undefined */ }
})

// ✅ CORRECT: Always handle undefined
.handler(async ({ data: params }) => {
  const safeParams = params || {}
  if (safeParams.search) { /* Safe */ }
})
```

### Don't Assume Optional Properties Exist

```typescript
// ❌ WRONG: Assumes all properties exist
const results = await db.select()
  .where(eq(table.field, params.filter))  // params.filter might be undefined

// ✅ CORRECT: Check before using
const safeParams = params || {}
let query = db.select().from(table)

if (safeParams.filter) {
  query = query.where(eq(table.field, safeParams.filter))
}
```

---

## loaderDeps Mistakes

### Don't Skip loaderDeps for Search Parameters

```typescript
// ❌ WRONG: Loader won't have access to search parameters
export const Route = createFileRoute('/route/')({
  loader: async ({ deps }) => {
    // deps will be undefined - no search parameters available
    return serverFunction({ data: deps })
  }
})

// ✅ CORRECT: Use loaderDeps to expose search parameters
export const Route = createFileRoute('/route/')({
  loaderDeps: ({ search }) => ({ param: search?.param }),
  loader: async ({ deps }) => {
    return serverFunction({ data: deps }) // deps now has parameters
  }
})
```

### Don't Use loaderDeps for Path Parameters

```typescript
// ❌ WRONG: loaderDeps is not needed for path parameters
export const Route = createFileRoute('/users/$userId/')({
  loaderDeps: ({ params }) => ({ userId: params.userId }), // WRONG!
  loader: async ({ deps }) => {
    return getUserById({ data: { userId: deps.userId } })
  }
})

// ✅ CORRECT: Path parameters are automatically available
export const Route = createFileRoute('/users/$userId/')({
  // No loaderDeps needed for path parameters
  loader: async ({ params }) => {
    return getUserById({ data: { userId: params.userId } }) // Direct access
  }
})
```

---

## Auth Logic Mistakes

### Don't Put Auth Logic in Handlers

```typescript
// ❌ WRONG: Auth logic in every handler
.handler(async ({ data: params }) => {
  const authResult = await auth()  // New API: auth() not getAuth(getRequest())
  if (!authResult.userId) throw new Error('Not authenticated')
  // Business logic...
})

// ✅ CORRECT: Use getServerAuth wrapper
.handler(async ({ data: params }) => {
  const authContext = await getServerAuth(['admin'])  // Handles auth + role check
  // Auth guaranteed, focus on business logic
})
```

### Don't Use Middleware for Auth

```typescript
// ❌ WRONG: Middleware pattern (tree-shaking issues)
.middleware([authMiddleware, requireRoles(['admin'])])
.handler(async ({ context }) => {
  const { authContext } = context as { authContext: AuthContext }
  // ...
})

// ✅ CORRECT: Use serverOnly auth
.handler(async ({ data: params }) => {
  const authContext = await getServerAuth(['admin'])
  // ...
})
```

---

## Database Connection Mistakes

### Don't Create New Database Connections

```typescript
// ❌ WRONG: New connection per request
.handler(async () => {
  const sql = neon(process.env.DATABASE_URL)
  const db = drizzle(sql)
  // ...
})

// ✅ CORRECT: Use shared connection
import { db } from '@/lib/db'
.handler(async () => {
  const results = await db.select()
  // ...
})
```

### Don't Import Database Directly in Routes

```typescript
// ❌ WRONG: Database in route file
// src/routes/admin/prospects.tsx
import { db } from '@/lib/db'
// This can cause tree-shaking issues

// ✅ CORRECT: Database only in server functions
// src/lib/serverFunctions/prospectsFn.ts
import { db } from '@/lib/db'
```

---

## Quick Reference Table

| Pattern | Wrong | Correct |
|---------|-------|---------|
| Route files | `index.tsx` | `prospects-pipeline.tsx` |
| Server function files | `prospects.ts` | `prospectsFn.ts` |
| Parameter safety | `params.field` | `safeParams?.field` |
| Search params | Skip loaderDeps | Use loaderDeps |
| Path params | Use loaderDeps | Use params directly |
| Auth in handlers | Inline auth logic | getServerAuth() |
| Auth middleware | .middleware([auth]) | getServerAuth() |
| DB connections | Create per request | Shared connection |
| Cache keys | `['prospects']` | `['prospect']` (singular) |
| Server fn params | `fn({ search })` | `fn({ data: { search } })` |

---

## Common Error Messages

### "Cannot read properties of undefined"

Usually means `params` is undefined:

```typescript
// Fix: Add safe parameter handling
const safeParams = params || {}
```

### "User not authenticated"

Usually means auth wasn't called or failed:

```typescript
// Fix: Check auth context
const authContext = await getServerAuth(['admin'])
// If this throws, user isn't authenticated or lacks role
```

### "loaderDeps is undefined"

Usually means you're accessing `deps` but didn't define `loaderDeps`:

```typescript
// Fix: Add loaderDeps for search parameters
loaderDeps: ({ search }) => ({
  param: search?.param,
}),
```

### Hydration Mismatch

Usually means CJS/ESM issues:

```typescript
// Fix: Add to vite.config.ts optimizeDeps.include
// See debugging.md for details
```
