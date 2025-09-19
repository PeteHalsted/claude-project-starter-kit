## 📄 Agent Documentation Standards

When creating any document, agents must decide the location based on the following priority:

1. **Follow specific instructions** in the agent’s own file, prompt, or user request.
2. **Special files** — `Changelog.md`, `README.md`, `README.*.md`, and `claude.md` — must follow their predefined location rules.
3. **Temporary documents** (disposable when work is complete) go in `project-documentation\temporary`.
4. **Permanent documentation** goes in `project-documentation`.
    - Check existing subfolders for a suitable location.
    - If none fits, create a new subfolder or place it in the root of `project-documentation`.
