# Beads Install and Setup

```markdown
# Beads + Claude Code Setup (No MCP)

This document describes how our team installs and uses **Beads (`bd`)** with **Claude Code** locally, without MCP. It assumes macOS or Linux with Homebrew.

---

## 1. Install `bd` via Homebrew

Run once per machine:

```


# Add the Beads tap (if needed)

brew tap steveyegge/beads

# Install the Beads CLI

brew install bd

```

Verify the install:

```

bd version

```

[Source: Beads README & Homebrew release notes][web:2][web:25]

---

## 2. Initialize Beads in a repository

Run in each project repo (once per clone):

```

cd /path/to/repo

# Choose one initialization mode:

bd init              \# default

# or:

# bd init --team         \# team/branch workflow

# bd init --contributor  \# OSS fork workflow

```

What this does:

- Creates `.beads/` with the SQLite cache and JSONL issue store.  
- Offers to install git hooks and configure the merge driver (say **yes**).  

You can run a health check at any time:

```

bd doctor

```

[Source: Beads README & INSTALLING docs][web:2][web:4]

Commit the metadata:

```

git add .beads
git commit -m "Initialize Beads issue tracker"

```

---

## 3. Add `CLAUDE.md` for Claude Code

In the repo root, add a `CLAUDE.md` file (or update it) with:

```


# Claude Setup for This Repo

BEFORE ANYTHING ELSE in this repo:

1. Open a terminal in this project directory.
2. Run: `bd onboard` and follow the instructions.
3. Then run: `bd quickstart` to learn the Beads workflow.

From now on, use the `bd` CLI for planning and task tracking
(creating, updating, and linking issues) instead of ad-hoc markdown TODO lists.

```

Claude Code reads `CLAUDE.md` at session start and will follow these instructions when working in this repo. [Source: CLAUDE.md guidance in Beads repo][web:18]

Commit it:

```

git add CLAUDE.md
git commit -m "Add Claude + Beads onboarding instructions"

```

---

## 4. Onboard Beads in the repo

Each developer (or at least the first dev on a new clone) should run:

```

cd /path/to/repo

# Get integration guidance and ensure DB is healthy

bd onboard

# Optional interactive workflow tutorial

bd quickstart

```

`bd onboard` prints Beads + Claude integration hints and verifies the local setup. [Source: Beads README][web:2]

---

## 5. Daily usage expectations

When working with Claude Code in this repo:

- Keep `.beads/` committed and synced with git. [web:2]  
- Use `bd` for all work planning and tracking:
  - `bd ready` – show ready-to-work issues.  
  - `bd create "Title" -t task -p 2` – create tasks/bugs/features.  
  - `bd dep add <child> <parent>` – manage dependencies.  
- Let Claude read `CLAUDE.md` and call `bd` commands instead of maintaining its own markdown TODO lists. [web:2][web:18]

This gives Claude long-term, dependency-aware memory for the codebase with no MCP server required.
```


