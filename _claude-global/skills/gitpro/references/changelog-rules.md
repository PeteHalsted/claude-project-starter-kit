# Changelog Rules

## Public-Facing Document

**Changelogs are always public-facing.** Write every entry as if a customer, end user, or non-technical stakeholder will read it.

| Forbidden | Why | Write Instead |
|-----------|-----|---------------|
| Technical jargon (API routes, function names, internal modules) | Meaningless to users | Describe the user-visible outcome |
| Infrastructure details (server config, deployment pipeline, CI changes) | Exposes internals | Omit entirely or describe the user benefit |
| Security-sensitive info (auth mechanisms, vulnerability details, secret names) | Security risk | Generic description ("improved security") |
| Internal file paths, database table names, schema changes | Implementation detail | Describe what changed for the user |

**Rule of thumb**: If a entry only makes sense to someone reading the source code, it doesn't belong in the changelog.

## What Goes in Changelog

**INCLUDE** (user-facing impact):
- ✨ feat: New features, capabilities, UI additions
- 🐛 fix: Bug fixes that affected users
- ⚡ perf: Performance improvements users would notice
- 💥 BREAKING: Any breaking changes

**EXCLUDE** (internal/dev only):
- ♻️ refactor: Code restructuring without behavior change
- 🎨 style: Formatting, whitespace, naming
- 🧪 test: Test additions/changes
- 📚 docs: Documentation changes
- 🔧 chore: Build, deps, tooling (unless user-facing)

## Changelog Entry Format

```
- **✨ Feature Name** - Brief description of what it does
- **🐛 Fix Issue** - What was broken and now works
```

## Multiple Features in One Commit

When commit includes multiple distinct features, list ALL in changelog:

```
- **✨ Feature A** - Description
- **✨ Feature B** - Description
- **🐛 Fix C** - Description
```

## Commit Message for Multiple Features

Use multi-line commit message:

```
✨ feat: add feature A and feature B

- Feature A: description
- Feature B: description
- Fix: description (if applicable)
```

Primary emoji/type should reflect the most significant change.
