---
description: Create well-formatted git commits with conventional commit messages and emoji
category: version-control-git
allowed-tools: Bash, Read, Glob, Task
source: https://www.buildwithclaude.com/commands but changed by Pete Halsted
---

# Claude Command: Commit

This command helps you create well-formatted commits with conventional commit messages and emoji.

## Usage

To create a commit, just type:
```
/commit
```

Or with options:
```
/commit --verify
```

## What This Command Does

1. If specified with `--verify`, automatically runs pre-commit checks:
   - Detect package manager (npm, pnpm, yarn, bun) and run appropriate commands
   - Run lint/format checks if available
   - Run build verification if build script exists
   - Update documentation if generation script exists
2. Checks which files are staged with `git status`
3. **ALWAYS adds all modified, new, and deleted files** with `git add -A` (regardless of logical distinctions)
4. Performs a `git diff` to understand what changes are being committed
5. **Ask the Technical Documentation Specialist to update the changelog FIRST**
6. **Stage the updated changelog file** with `git add changelog.md`
7. Creates a comprehensive commit message using emoji conventional commit format
8. **Commits all changes including the updated changelog** in a single commit

## Key Behavior Changes

- **No Logical Distinction Splitting**: Commits ALL changes together regardless of how many different logical areas are modified
- **Changelog Integration**: Always updates and includes changelog in the same commit
- **Comprehensive Staging**: Uses `git add -A` to include all modifications, additions, and deletions
- **Single Commit Workflow**: One commit contains all changes plus updated changelog

## Best Practices for Commits

- **Conventional commit format**: Use the format `<type>: <description>` where type is one of:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation changes
  - `style`: Code style changes (formatting, etc)
  - `refactor`: Code changes that neither fix bugs nor add features
  - `perf`: Performance improvements
  - `test`: Adding or fixing tests
  - `chore`: Changes to the build process, tools, etc.
- **Present tense, imperative mood**: Write commit messages as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep the first line under 72 characters
- **Emoji**: Each commit type is paired with an appropriate emoji:
  - ✨ `feat`: New feature
  - 🐛 `fix`: Bug fix
  - 📚 `docs`: Documentation
  - 🎨 `style`: Formatting/style
  - ♻️ `refactor`: Refactoring
  - ⚡ `perf`: Performance
  - 🧪 `test`: Testing
  - 🔧 `chore`: Maintenance

## Workflow Steps in Detail

1. **Pre-commit checks** (if --verify specified)
2. **Stage everything**: `git add -A` to include all changes
3. **Update changelog**: Technical Documentation Specialist analyzes all staged changes and updates changelog.md
4. **Stage changelog**: `git add changelog.md` to include the updated changelog
5. **Create comprehensive commit message**: Analyze all changes (including diverse logical areas) and create a unified message
6. **Single commit**: Commit everything together with the updated changelog included

This approach ensures that:
- No changes are left uncommitted
- The changelog is always current and included
- Each commit is a complete snapshot including its documentation
- The commit history remains clean with comprehensive descriptions