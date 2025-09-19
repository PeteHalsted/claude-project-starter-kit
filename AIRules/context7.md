### Context7 Workflow Policy

**For library documentation and integration questions:**

- For ALL questions about library APIs, usage, upgrades, or integration, you MUST fetch and reference official documentation using Context7
- Whenever asked about a library, ALWAYS include "use context7" at the end of your prompt to request the most up-to-date docs and code examples
- If using a Model Context Protocol (MCP) server with Context7, you MUST call `resolve-library-id` for the library name first, then use `get-library-docs` to pull in current documentation
- Never rely only on prior model training or guesses—defer to the retrieved Context7 documentation for accuracy

**Examples:**

- ✅ Good: `How do I add schema validation with Zod in Express? use context7`
- ❌ Not allowed: Answers about a library without referencing up-to-date docs from Context7
- If multiple libraries are involved, repeat the above steps for each before answering
