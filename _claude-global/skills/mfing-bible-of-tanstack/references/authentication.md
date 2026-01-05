# Authentication Reference

## Contents

- [Server-Only Auth Architecture](#server-only-auth-architecture)
- [The getServerAuth Utility](#the-getserverauth-utility)
- [Using Auth in Server Functions](#using-auth-in-server-functions)
- [Authentication Patterns by Role](#authentication-patterns-by-role)
- [Why ServerOnly Pattern is Superior](#why-serveronly-pattern-is-superior)

---

## Server-Only Auth Architecture

**CRITICAL**: Use TanStack Start's `createServerOnlyFn` utility to prevent client-side auth code leakage and dependency issues.

### The Problem with Middleware Pattern

The middleware pattern for authentication has critical issues:
- TanStack Start can't detect external middleware functions should be server-only
- Client bundle contamination causes cookie access errors in browser
- Complex middleware chaining reduces code clarity
- Context casting required in every handler

### The Solution: ServerOnly Pattern

Use `createServerOnlyFn()` wrapper to guarantee auth code never reaches the browser.

---

## The getServerAuth Utility

```typescript
// apps/web/src/lib/auth/serverAuth.ts
import { createServerOnlyFn } from '@tanstack/react-start'
import { auth } from '@clerk/tanstack-react-start/server'
import { createLogger, LogNamespace } from '@mysite/shared/logger'

const logger = createLogger(LogNamespace.AUTH)

// Clean authentication context
interface AuthContext {
  userId: string        // Always present when authenticated
  sessionId: string     // Session identifier
  role: string          // User role for RBAC
  firstName?: string    // User's first name
  lastName?: string     // User's last name
  emailAddress?: string // Primary email
}

/**
 * Server-only authentication function using TanStack Start's createServerOnlyFn utility.
 * This function is guaranteed to never execute in the browser, preventing
 * client-side cookie access errors and dependency issues.
 *
 * NOTE: The new Clerk API uses `auth()` which doesn't require a request parameter.
 * The clerkMiddleware() in start.ts sets up the context automatically.
 *
 * @param allowedRoles - Optional array of roles that are allowed to access the resource
 * @returns AuthContext with user information and role
 * @throws Error if user is not authenticated or lacks required permissions
 */
export const getServerAuth = createServerOnlyFn(async (allowedRoles?: string[]): Promise<AuthContext> => {
  const authResult = await auth()

  if (!authResult.userId) {
    throw new Error('User not authenticated')
  }

  const role = authResult.sessionClaims?.role as string | undefined

  if (!role || !['admin', 'manager', 'client'].includes(role)) {
    logger.label('AUTH_ERROR').error('Invalid or missing role from Clerk', {
      userId: authResult.userId,
      role: role || 'undefined',
      sessionClaims: authResult.sessionClaims,
    })
    throw new Error(
      `Invalid role from Clerk: ${role || 'undefined'}. User must have a valid role (admin, manager, or client) configured in Clerk.`
    )
  }

  if (allowedRoles && !allowedRoles.includes(role)) {
    logger.label('AUTH_DENIED').warn('Access denied - insufficient role', {
      userId: authResult.userId,
      userRole: role,
      requiredRoles: allowedRoles,
    })
    throw new Error(
      `Insufficient permissions - requires one of: ${allowedRoles.join(', ')}`
    )
  }

  const authContext: AuthContext = {
    userId: authResult.userId,
    sessionId: authResult.sessionId || '',
    role,
    firstName: authResult.sessionClaims?.firstname as string | undefined,
    lastName: authResult.sessionClaims?.lastname as string | undefined,
    emailAddress: authResult.sessionClaims?.emailaddress as string | undefined,
  }

  return authContext
})

/**
 * Server-only authentication function with no role restrictions.
 * Useful for endpoints that need auth context but don't restrict by role.
 */
export const getServerAuthAnyRole = createServerOnlyFn(async (): Promise<AuthContext> => {
  return await getServerAuth() // No role restrictions
})
```

---

## Using Auth in Server Functions

### Basic Pattern

```typescript
import { createServerFn } from '@tanstack/react-start'
import { getServerAuth } from '@/lib/auth/serverAuth'
import { db, prospect } from '@/lib/db'

export const getProspects = createServerFn({
  method: 'GET',
})
  .inputValidator((params: {
    search?: string
    limit?: number
    offset?: number
  }) => params)
  .handler(async ({ data: params }) => {
    // ✅ CRITICAL: Use createServerOnlyFn auth - guaranteed to never run in browser
    const authContext = await getServerAuth(['admin', 'manager'])

    // ✅ CRITICAL: Always handle undefined params
    const safeParams = params || {}

    // Auth context is now available with guaranteed role access
    logger.label('GET_PROSPECTS').info('Fetching prospects', {
      userId: authContext.userId,
      role: authContext.role,
      params: safeParams
    })

    // Use shared database connection
    const results = await db.select().from(prospect)
      .where(/* your conditions */)
      .limit(safeParams.limit || 50)
      .offset(safeParams.offset || 0)

    return results
  })
```

### Different Roles for Different Functions

```typescript
// Admin and manager can create prospects
export const createProspect = createServerFn({
  method: 'POST',
})
  .inputValidator((input: {
    businessname: string
    email: string
    phone?: string
    prospectstatus?: string
    managerclerkuserid?: string
  }) => input)
  .handler(async ({ data: input }) => {
    const authContext = await getServerAuth(['admin', 'manager'])

    const [newProspect] = await db.insert(prospect)
      .values({
        ...input,
        managerclerkuserid: input.managerclerkuserid || authContext.userId,
      })
      .returning()

    return newProspect
  })

// Only admins can delete
export const deleteProspect = createServerFn({
  method: 'POST',
})
  .inputValidator((input: { prospectid: string }) => input)
  .handler(async ({ data: input }) => {
    const authContext = await getServerAuth(['admin'])

    await db.delete(prospect)
      .where(eq(prospect.prospectid, input.prospectid))

    return { success: true }
  })

// Any authenticated user can access their profile
export const getUserProfile = createServerFn({
  method: 'GET',
})
  .handler(async () => {
    const authContext = await getServerAuthAnyRole()

    const profile = await db.query.userprofile.findFirst({
      where: eq(userprofile.clerkuserid, authContext.userId),
    })

    return {
      id: authContext.userId,
      role: authContext.role,
      profile,
    }
  })
```

---

## Authentication Patterns by Role

### No Authentication Required (Public Endpoints)

```typescript
export const publicFunction = createServerFn({
  method: 'GET',
})
  .handler(async ({ data: params }) => {
    // No auth required
    return publicData
  })
```

### Any Authenticated User

```typescript
export const userFunction = createServerFn({
  method: 'GET',
})
  .handler(async ({ data: params }) => {
    const authContext = await getServerAuthAnyRole()
    return userData
  })
```

### Specific Roles Required

```typescript
// Admin only
export const adminFunction = createServerFn({
  method: 'POST',
})
  .handler(async ({ data: params }) => {
    const authContext = await getServerAuth(['admin'])
    return adminData
  })

// Admin or manager
export const managerFunction = createServerFn({
  method: 'GET',
})
  .handler(async ({ data: params }) => {
    const authContext = await getServerAuth(['admin', 'manager'])
    return managerData
  })

// All staff (admin, manager, client)
export const staffFunction = createServerFn({
  method: 'GET',
})
  .handler(async ({ data: params }) => {
    const authContext = await getServerAuth(['admin', 'manager', 'client'])
    return staffData
  })
```

### Pattern Summary

| Access Level | Pattern |
|--------------|---------|
| Public | No auth call |
| Any authenticated | `getServerAuthAnyRole()` |
| Admin only | `getServerAuth(['admin'])` |
| Admin or manager | `getServerAuth(['admin', 'manager'])` |
| All staff | `getServerAuth(['admin', 'manager', 'client'])` |

---

## Why ServerOnly Pattern is Superior

### Benefits

- **Guaranteed Server Execution**: `createServerOnlyFn()` wrapper ensures auth code never reaches browser
- **Proper Tree-Shaking**: TanStack Start automatically excludes server-only code from client bundle
- **Cleaner Code**: Direct function calls instead of complex middleware chains
- **Better Performance**: No middleware overhead
- **Type Safety**: Direct auth context access without context casting

### Problems with Middleware Pattern

```typescript
// ❌ WRONG: Middleware pattern causes issues
export const functionWithMiddleware = createServerFn({
  method: 'GET',
})
  .middleware([authMiddleware, requireRoles(['admin'])])  // Can leak to client
  .handler(async ({ context }) => {
    const { authContext } = context as { authContext: AuthContext }  // Requires casting
    // ...
  })
```

### Correct ServerOnly Pattern

```typescript
// ✅ CORRECT: ServerOnly pattern
export const functionWithServerOnlyAuth = createServerFn({
  method: 'GET',
})
  .handler(async ({ data: params }) => {
    const authContext = await getServerAuth(['admin'])  // Guaranteed server-only
    // Direct access, no casting needed
  })
```

---

## Common Mistakes

### Don't Put Auth Logic in Handlers

```typescript
// ❌ WRONG: Auth logic in every handler
.handler(async ({ data: params }) => {
  const authResult = await auth()  // Duplicated everywhere
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
.middleware([authMiddleware])
.handler(async ({ context }) => {
  const { authContext } = context as { authContext: AuthContext }
})

// ✅ CORRECT: Direct serverOnly auth call
.handler(async ({ data: params }) => {
  const authContext = await getServerAuth()
})
```
