### Browser Access Via Chrome DevTools

**Chrome DevTools MCP Server Configuration:**
The project includes Chrome DevTools MCP server which automatically enables browser automation for all Claude Code instances working on this project.

**Usage Guidelines:**
- The user is always testing the site via Chrome DevTools. This means you have access to the browser and the console logs
- DO NOT ask the user to test, view console logs if you can do so yourself. ALWAYS test and iterate until you have a correct result
- DO NOT close browser tabs unless explicitly instructed - the user is using them for testing!
- Use Chrome DevTools for all browser testing, form interaction, and UI validation
- **Authentication for Testing**: If testing requires login, check the `.env` file for test credentials (typically `TEST_ADMIN_EMAIL`, `TEST_ADMIN_PASSWORD`, `TEST_CLIENT_EMAIL`, `TEST_CLIENT_PASSWORD`)

**Core Capabilities:**

*Page Management & Navigation:*
- Open new pages, close tabs, switch between pages
- Navigate to URLs, go back/forward in history
- Resize viewport for responsive testing

*Interactive Testing:*
- Take snapshots of page structure (preferred over screenshots for AI analysis)
- Click elements, double-click, hover, drag-and-drop
- Fill forms (single fields or entire forms at once)
- Upload files through file inputs
- Handle dialogs (alerts, confirms, prompts)

*Network Analysis:*
- List all network requests with filtering by resource type
- Get detailed request/response data (headers, body, status)
- Emulate network throttling (3G, 4G, etc.)

*Performance Analysis:*
- Start/stop performance traces with automatic reload option
- Analyze Core Web Vitals (LCP, CLS, FID)
- Get Performance Insights for specific bottlenecks
- Emulate CPU throttling (1-20x slowdown)

*Debugging & Inspection:*
- List console messages (errors, warnings, logs)
- Execute JavaScript in page context with async support
- Take screenshots (full page, viewport, or specific elements)
- Wait for text to appear on page

**Best Practices:**
- Always use `take_snapshot` first to get element UIDs before interacting
- Snapshots become stale after interactions - take a fresh snapshot when needed
- Use `fill_form` for multiple fields to reduce round trips
- Check console logs proactively when debugging issues
- Test responsive designs by resizing viewport to common breakpoints (375x667 mobile, 768x1024 tablet, 1920x1080 desktop)
