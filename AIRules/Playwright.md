### Browser Access Via Playwright

**Playwright MCP Server Configuration:**
The project includes Playwright MCP server configuration in `.mcp.json` which automatically enables browser automation for all Claude Code instances working on this project.

**Setup Instructions for New Contributors:**
1. Install dependencies: `npm install` (includes @playwright/test)
2. Install Playwright browsers: `npx playwright install chrome`
3. The MCP server will automatically be available in Claude Code

**Usage Guidelines:**
- The user is always testing the site via Playwright. This means you have access to the browser and the console logs
- DO NOT ask the user to test, view console logs if you can do so yourself. ALWAYS test and iterate until you have a correct result
- DO NOT close Playwright, the user is using it for testing!
- Use Playwright for all browser testing, form interaction, and UI validation
