# Debugging Reference

## Contents

- [React Hydration Issues](#react-hydration-issues)
- [CJS/ESM Module Problems](#cjsesm-module-problems)
- [Vite Configuration](#vite-configuration)
- [Testing Server Functions](#testing-server-functions)
- [Debug Utilities](#debug-utilities)

---

## React Hydration Issues

### Symptom

Page renders server HTML but React never hydrates:
- No visible errors in console
- Form inputs don't work
- Clerk `<SignIn>` shows wrapper but no form fields
- Interactive elements are unresponsive

### Root Cause

CommonJS packages being served raw via `/@fs/...` instead of through Vite's optimizer. This causes "does not provide an export named" errors that silently block hydration.

### How to Debug

```javascript
// In browser console, manually trigger the client entry
import('/@id/virtual:tanstack-start-client-entry').then(m => {
  console.log('Success!');
}).catch(e => {
  console.error('Hydration blocked:', e.message);
});
```

If you see errors like:
```
The requested module '/@fs/.../use-sync-external-store/shim/index.js'
does not provide an export named 'useSyncExternalStore'
```

### Fix

Add the problematic CJS packages to `vite.config.ts`:

```typescript
// vite.config.ts
export default defineConfig({
  optimizeDeps: {
    include: [
      // CJS packages that need ESM conversion
      "use-sync-external-store",
      "use-sync-external-store/shim",
      "use-sync-external-store/shim/index.js",
      "use-sync-external-store/shim/with-selector",
      "use-sync-external-store/shim/with-selector.js",
      "@tanstack/react-router > @tanstack/react-store",
      "cookie",  // Used by Clerk
    ],
  },
  ssr: {
    noExternal: [/use-sync-external-store/, /cookie/],
  },
})
```

**Always clear Vite cache after config changes:**

```bash
rm -rf apps/web/node_modules/.vite
```

---

## CJS/ESM Module Problems

### Common Error Patterns

```
SyntaxError: The requested module '...' does not provide an export named '...'
```

```
ReferenceError: exports is not defined
```

```
TypeError: Cannot read properties of undefined (reading '...')
```

### Solutions

**1. Add to optimizeDeps.include**

```typescript
optimizeDeps: {
  include: ["problematic-package"],
}
```

**2. Add to ssr.noExternal**

```typescript
ssr: {
  noExternal: [/problematic-package/],
}
```

**3. Check for nested dependencies**

Sometimes the issue is a dependency of a dependency:

```typescript
optimizeDeps: {
  include: [
    "@tanstack/react-router > @tanstack/react-store",
  ],
}
```

---

## Vite Configuration

### Complete Example for TanStack Start

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [
    tsconfigPaths(),
    tanstackStart(),
    react(),
  ],
  optimizeDeps: {
    include: [
      // CJS packages that need ESM conversion
      "use-sync-external-store",
      "use-sync-external-store/shim",
      "use-sync-external-store/shim/index.js",
      "use-sync-external-store/shim/with-selector",
      "use-sync-external-store/shim/with-selector.js",
      "@tanstack/react-router > @tanstack/react-store",
      "cookie",
    ],
  },
  ssr: {
    noExternal: [/use-sync-external-store/, /cookie/],
  },
})
```

### Cache Clearing

```bash
# Clear Vite cache (required after config changes)
rm -rf apps/web/node_modules/.vite

# Full clean rebuild
rm -rf node_modules/.vite
rm -rf apps/web/node_modules/.vite
npm run build
```

---

## Testing Server Functions

### Required Vitest Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import { tanstackStart } from '@tanstack/react-start/config'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [
    tsconfigPaths(),
    tanstackStart({
      customViteReactPlugin: true,
    }),
    react(),
  ],
  test: {
    environment: 'node',
    setupFiles: ['./src/test/server-fn-setup.ts'],
    reporters: ['basic'],
  },
})
```

### SSR Environment Setup

```typescript
// src/test/server-fn-setup.ts
// Configure SSR environment for server function execution
process.env.TSS_SSR = 'true'
process.env.NODE_ENV = 'test'

// Build nested structure safely to avoid TypeError
if (!globalThis.import) {
  globalThis.import = {}
}
if (!globalThis.import.meta) {
  globalThis.import.meta = {}
}
if (!globalThis.import.meta.env) {
  globalThis.import.meta.env = {}
}

// Set SSR flag for server function detection
globalThis.import.meta.env.SSR = true
```

### Parameter Passing Format

**CRITICAL**: Server functions require the `{ data: params }` destructuring pattern:

```typescript
// ❌ WRONG - Direct parameter passing
const result = await getContacts({ search: "test" });

// ✅ CORRECT - TanStack Start required format
const result = await getContacts({ data: { search: "test" } });
```

---

## Debug Utilities

### Test Connection Function

```typescript
export const testConnection = createServerFn({ method: 'GET' })
  .handler(async () => {
    const authContext = await getServerAuth(['admin'])

    return {
      authenticated: true,
      userId: authContext.userId,
      role: authContext.role,
      canConnectDB: !!process.env.DATABASE_URL,
      canConnectClerk: !!process.env.CLERK_SECRET_KEY,
    }
  })
```

### Debug Parameter Issues

```typescript
// Add temporary logging for critical debugging
.handler(async ({ data: params, context }) => {
  // Only log for critical debugging - remove when working
  if (!params) {
    logger.label('PARAM_ERROR').error('No parameters received', { params })
  }

  const safeParams = params || {}

  // Continue with logic...
})
```

### Route Loader Debugging

```typescript
loader: async ({ deps }) => {
  logger.label('ROUTE_LOADER').info('Route loader executing', { deps })

  try {
    const result = await serverFunction({ data: deps })
    logger.label('ROUTE_LOADER').info('Loader success', { resultCount: result.length })
    return { data: result }
  } catch (error) {
    logger.label('ROUTE_LOADER').error('Route loader failed', { error })
    throw error
  }
}
```

### Cache Debugging

```typescript
// Check cache status in route loader
loader: async ({ params, context: { queryClient } }) => {
  const cacheKey = ['prospect', 'detail', params.prospectId]
  const cachedData = queryClient.getQueryData(cacheKey)

  if (cachedData) {
    console.log(`Cache HIT - instant load!`)
  } else {
    console.log(`Cache MISS - fetching data`)
  }

  const data = await queryClient.ensureQueryData(
    prospectQueryOptions.detail(params.prospectId)
  )

  return data
}
```
