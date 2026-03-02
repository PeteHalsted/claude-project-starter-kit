### Browser Testing with agent-browser

**Policy:**
- You have browser access. DO NOT ask the user to test, check console, or verify UI — do it yourself
- ALWAYS test and iterate until you have a correct result
- Use email/password login only — Google OAuth is blocked by Playwright bot detection
- Check `.env` for test credentials before asking the user

**Startup Sequence (always use this):**
```bash
agent-browser --headed open http://localhost:3001
agent-browser set viewport 1920 1080
agent-browser wait --load networkidle
agent-browser snapshot -i
```
- `--headed` is required so the user can see the browser
- `set viewport 1920 1080` is required — Playwright defaults to 1280x720 and config files don't override it
- Dev server: `http://localhost:3001` (never start it yourself — see project rules)
- Always `snapshot -i` after navigation or DOM changes to get fresh refs

**Debugging:**
- Check console after interactions: `agent-browser eval 'JSON.stringify(console)' ` or use snapshot to verify state
- Take screenshots when visual verification is needed
- Check network failures with eval if API calls seem broken

**Auth:**
- Login via email/password form fields
- Google OAuth will not work — don't attempt it
- If login state is needed across commands, use `agent-browser state save/load`
