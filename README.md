# NextAge Designs Client Portal *** This is an example and should be updated for your project ***

## Quick Overview

**mysite.nextagedesigns.com** is a hosting client portal and admin management system for NextAge Designs.

**Target Users:**
- NextAge Designs hosting clients (billing/account management, hosting dashboard)  
- NextAge Designs staff (admin functions, prospect management, hosting services)

## Essential Tech Stack

- **Frontend**: TanStack Start + React + TypeScript (port 3001)
- **Backend**: Hono + Node.js + PostgreSQL (port 3000)
- **Auth**: Clerk with RBAC (admin/client roles)
- **API**: oRPC for type-safe communication
- **UI**: shadcn/ui + TailwindCSS
- **Database**: PostgreSQL with Drizzle ORM

## Quick Start

```bash
npm install              # Install dependencies
npm run dev             # Start both frontend (3001) + backend (3000)
npm run db:push         # Apply database schema
npm run check           # Format/lint code
```

This runs both services concurrently with labeled, color-coded output:
- **Frontend**: Vite dev server with Hot Module Replacement
- **Backend**: tsx watch for automatic restart on file changes

Open [http://localhost:3001](http://localhost:3001) to view the application.

## Environment Setup

**Frontend (`apps/web/.env`):**
- `VITE_SERVER_URL` - Backend API URL (http://localhost:3000)
- `VITE_CLERK_PUBLISHABLE_KEY` - Clerk publishable key

**Backend (`apps/server/.env`):**  
- `DATABASE_URL` - PostgreSQL connection string
- `CLERK_SECRET_KEY` - Clerk secret key for server-side auth
- `CLERK_PUBLISHABLE_KEY` - Clerk publishable key
- `CORS_ORIGIN` - Frontend URL for CORS (http://localhost:3001)

## Core Commands

```bash
# Development
npm run dev             # Start both frontend + backend
npm run dev:web        # Start only frontend (port 3001)
npm run dev:server     # Start only backend (port 3000)

# Database
npm run db:push        # Push schema changes to PostgreSQL
npm run db:studio      # Open Drizzle Studio for database management

# Code Quality
npm run check          # Run Biome formatting and linting
npm run check-types    # TypeScript compilation check

# Testing
npm test               # Run all tests
npm run test:services  # Test external service connections
```

## Project Structure

This is a **monorepo** using npm workspaces:

```
mysite.nextagedesigns/
├── apps/
│   ├── web/                    # Frontend (TanStack Start + React)
│   └── server/                 # Backend (Hono API server)
├── project-documentation/       # Complete project documentation
├── package.json                # Root workspace configuration
├── CLAUDE.md                   # Claude Code instructions
└── README.md                   # This file - project overview
```

## Authentication & Security

- **Clerk Authentication** with role-based access control
- **Protected Routes** with server-side route guards
- **JWT Token Flow** with secure session management
- **Admin/Client Separation** with feature-level permissions

## Documentation

For detailed information, see `project-documentation/`:

- **`technical-architecture.md`** - Complete tech stack and system design
- **`external-services-setup.md`** - Service configuration and environment setup
- **`developer-handbook.md`** - Development commands and workflow
- **`coding-standards.md`** - Development standards and practices
- **`clerk-authentication/`** - Authentication architecture and guides

## Getting Started

1. **Install dependencies**: `npm install`
2. **Setup PostgreSQL database** and update `apps/server/.env`
3. **Add Clerk keys** to both `.env` files
4. **Push database schema**: `npm run db:push`
5. **Start development**: `npm run dev`

The application will be available at http://localhost:3001 with the API at http://localhost:3000.