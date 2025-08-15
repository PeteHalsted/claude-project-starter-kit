# Project Structure

## Root Directory Organization

## Project Structure

```
apps/
├── web/           # Frontend (TanStack Start + React)
│   ├── src/
│   │   ├── components/ui/    # shadcn/ui components
│   │   ├── routes/          # TanStack Router pages
│   │   ├── lib/             # Utilities (utils.ts)
│   │   └── utils/           # ORPC client setup
└── server/        # Backend (Hono + ORPC)
    ├── src/
    │   ├── routers/         # API route definitions
    │   ├── db/              # Database schema and connection
    │   └── lib/             # Server utilities and context
```

## Key Architecture Patterns

### Configuration Management

- Environment variables in `.env` files
- Type-safe configuration validation on startup
- Separate development and production configurations

