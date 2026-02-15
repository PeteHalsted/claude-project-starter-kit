# CPL Launcher System

Spotlight-launchable app for opening Claude Code + Zed projects with automatic window management.

## Source of Truth

CPL source lives in `_cpl/` within the [claude-project-starter-kit](https://github.com/petehalsted/claude-project-starter-kit) repo. All changes should be made there and synced via `sync-cpl.sh`.

### Install / Update

```bash
# From starter kit repo:
./_cpl/sync-cpl.sh

# From any project (via Claude Code slash command):
/sync-cpl

# Non-interactive (e.g., from scripts):
./_cpl/sync-cpl.sh --force
```

### Version Tracking

- **Source version:** `_cpl/VERSION` in repo
- **Installed version:** `~/.cpl-version`
- Sync script compares these and only installs when they differ

## Components

| Source File | Installs To | Method |
|-------------|-------------|--------|
| `_cpl/bin/cpl-app.applescript` | `~/Applications/CPL.app` | `osacompile` |
| `_cpl/bin/cpl-picker.swift` | `~/bin/cpl-picker` | `swiftc -O` |
| `_cpl/bin/cpl-close-zed.swift` | `~/bin/cpl-close-zed` | `swiftc -O` |
| `_cpl/bin/cpl-launch` | `~/bin/cpl-launch` | `cp` + `chmod +x` |
| `_cpl/bin/cpl-slot` | `~/bin/cpl-slot` | `cp` + `chmod +x` |
| `_cpl/bin/cpl-cleanup` | `~/bin/cpl-cleanup` | `cp` + `chmod +x` |
| `_cpl/bin/cpl` | `~/bin/cpl` | `cp` + `chmod +x` |
| `_cpl/bin/CPL.md` | `~/bin/CPL.md` | `cp` |
| `_cpl/iterm2/CPL.json` | `~/Library/Application Support/iTerm2/DynamicProfiles/` | `cp` |

### Archived (git-tracked only, not installed)

| File | Why Archived |
|------|-------------|
| `_cpl/archived/cpl-monitor.swift` | Monitored iTerm2 window — EXIT trap approach won |
| `_cpl/archived/cpl-tty-wait.swift` | Polled PTY for POLLHUP — same reason |

## Launch Modes

Picker offers 4 radio buttons:

| Mode | Slot | iTerm2 | Zed | Profile |
|------|------|--------|-----|---------|
| **Claude + Zed** (`both`) | Yes | Yes | Yes | CPL |
| **Claude Only** (`claude`) | Yes | Yes | No | CPL |
| **Zed Only** (`zed`) | No | No | Yes | — |
| **Terminal Only** (`terminal`) | Yes | Yes | No | Default |

## Window Management

- **Monitor:** Right monitor (x=3440, width=3440)
- **Layout:** 3 equal slots filling right-to-left (Slot 1 = rightmost, Slot 3 = leftmost)
- **Slot files:** `~/.cpl-slots/{1,2,3}` — contain PID of owning process
- **Stale cleanup:** On claim, checks if slot's PID is alive; reclaims if dead or missing

## Zed Close on Exit

EXIT trap in `cpl-launch` calls `cpl-cleanup`, which calls compiled `cpl-close-zed` (Accessibility API, ~0.4s). Total delay ~9-10s after window close due to Claude's graceful shutdown — unavoidable.

**Why not other approaches:** ~10 alternatives were tested (HUP trap, TTY polling, PTY POLLHUP, AX API window monitor, CGWindowListCopyWindowInfo). All failed because iTerm2 keeps the window/PTY alive for 5-8s after close (undo-close feature).

## Key Design Decisions

### iTerm2 Cold Launch Handling

iTerm2 creates a default startup window on cold launch regardless of config. To prevent an extra window when CPL is the first to launch iTerm2:

1. Set `OpenNoWindowsAtStartup = true` via `defaults write` **before** `activate`
2. After iTerm2 responds, restore the original setting
3. Safety-net: close any startup windows via `repeat while count > 0; close window 1`
4. `activate` always runs in the main `tell` block (not conditional on warm/cold)

**Critical detail:** The `defaults write` must happen *before* `activate`, not after. Ordering matters — iTerm2 reads prefs during its launch sequence.

### Stale Slot Cleanup

Slots with no PID line or a dead PID are both treated as stale:
```bash
[ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null
```

### Window Title

Claude Code sends escape sequences that override iTerm2 tab titles. Fixed via CPL profile: `Title Components: 1`, `Allow Title Setting: false`.

### Zed App Name

Installed as "Zed Preview" — all scripts reference `Zed Preview` in `open -a` and AppleScript commands.
