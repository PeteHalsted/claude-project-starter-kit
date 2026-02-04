# Changelog Rules

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
