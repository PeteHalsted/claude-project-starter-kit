---
description: Create well-formatted git commits with conventional commit messages and emoji
category: version-control-git
allowed-tools: Bash, Read, Glob
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
3. If 0 files are staged, automatically adds all modified and new files with `git add`
4. Performs a `git diff` to understand what changes are being committed
5. Analyzes the diff to determine if multiple distinct logical changes are present
6. Creates a commit message using emoji conventional commit format

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