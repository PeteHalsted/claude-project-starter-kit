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

### Layout Config

Layout is configured in `~/.cpl.conf` (required, per-machine). Generated on first `sync-cpl` with auto-detected display values. Edit for your setup.

| Key | Description |
|-----|-------------|
| `monX` | X offset where the Claude slots monitor starts |
| `monW` | Width of the Claude slots monitor |
| `monH` | Height of the Claude slots monitor |
| `editorX` | X offset where the Zed window starts |
| `editorW` | Width of the Zed window |
| `maxSlots` | Number of Claude iTerm2 slots (split equally across monW) |
| `zedAppName` | Zed app name as in /Applications (e.g., "Zed Preview") |
| `zedProcessName` | Zed process name as in Activity Monitor (e.g., "zed") |

All keys are required. CPL will show an error dialog identifying the missing key.

### Example Layouts

**Dual monitor — Zed on left, Claude on right (3440x1440 each):**

```
~/.cpl.conf:
  monX=3440  monW=3440  monH=1440  editorX=0  editorW=3440  maxSlots=3

┌─────── Left Monitor (3440x1440) ───────┬─────── Right Monitor (3440x1440) ──────┐
│                                         │                                         │
│  ┌───────────────────────────────────┐  │  ┌───────────┬───────────┬───────────┐  │
│  │              Zed                  │  │  │  Slot 3   │  Slot 2   │  Slot 1   │  │
│  │          full monitor             │  │  │  ~1147px  │  ~1147px  │  ~1147px  │  │
│  │         editorX=0                 │  │  │           │           │           │  │
│  │        editorW=3440               │  │  │           │           │           │  │
│  └───────────────────────────────────┘  │  └───────────┴───────────┴───────────┘  │
│                                         │                                         │
└─────────────────────────────────────────┴─────────────────────────────────────────┘
```

**Single ultrawide — Zed left half, Claude overlapping (3840x1080):**

```
~/.cpl.conf:
  monX=0  monW=3840  monH=1080  editorX=0  editorW=1920  maxSlots=3

┌──────────────────── Single Monitor (3840x1080) ────────────────────┐
│                                                                     │
│  ┌───────────────────┐                                              │
│  │       Zed         │  (behind Claude slots — Cmd+Tab to switch)   │
│  │   editorX=0       │                                              │
│  │  editorW=1920     │                                              │
│  └───────────────────┘                                              │
│  ┌────────────┬────────────┬────────────┐                           │
│  │   Slot 3   │   Slot 2   │   Slot 1   │                          │
│  │   1280px   │   1280px   │   1280px   │                          │
│  │            │            │            │                           │
│  └────────────┴────────────┴────────────┘                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Claude Slots

- **Layout:** `maxSlots` equal-width slots filling right-to-left across the full monitor (Slot 1 = rightmost, Slot 3 = leftmost)
- **Slot files:** `~/.cpl-slots/{1,2,3}` — contain PID of owning process
- **Stale cleanup:** On claim, checks if slot's PID is alive; reclaims if dead or missing

### Zed Positioning

In `both` and `zed` modes, Zed is positioned at `editorX` with width `editorW` via System Events. On single-monitor setups Zed sits behind the Claude slots — switch via Cmd+Tab. On dual-monitor setups, set `editorX` to the other monitor's offset for a non-overlapping layout.

**Accessibility permission required:** System Events window positioning requires the calling app (CPL.app or Script Editor) to have Accessibility access in System Settings > Privacy & Security > Accessibility.

### Claude Binary

`cpl-launch` and `cpl` invoke `claude` via PATH resolution (not a hardcoded path). This supports all install methods (`~/.local/bin/`, `/opt/homebrew/bin/`, etc.).

## Zed Close on Exit

EXIT trap in `cpl-launch` calls `cpl-cleanup`, which calls compiled `cpl-close-zed` (Accessibility API, ~0.4s). Total delay ~9-10s after window close due to Claude's graceful shutdown — unavoidable.

**Why not other approaches:** ~10 alternatives were tested (HUP trap, TTY polling, PTY POLLHUP, AX API window monitor, CGWindowListCopyWindowInfo). All failed because iTerm2 keeps the window/PTY alive for 5-8s after close (undo-close feature).

## Required macOS Permissions

The Zed auto-close and window positioning features use the macOS Accessibility API (`AXUIElement`). Without proper permissions, `cpl-close-zed` exits 0 but silently fails.

### Accessibility (System Settings > Privacy & Security > Accessibility)

| App | Why |
|-----|-----|
| **iTerm** (`/Applications/iTerm.app`) | Parent process running `cpl-close-zed`. Accessibility grants are inherited through the process chain |
| **cpl-close-zed** (`~/bin/cpl-close-zed`) | Directly calls `AXUIElement` APIs to find and close Zed windows |
| **CPL.app** or **Script Editor** | `cpl-app.applescript` uses System Events to position Zed windows |

To add `cpl-close-zed`: click **+**, then **Cmd+Shift+G** and type `/Users/<username>/bin/cpl-close-zed` (the standard file picker won't show `~/bin`).

### Automation (System Settings > Privacy & Security > Automation)

| App | Controls | Why |
|-----|----------|-----|
| **Script Editor** / `osascript` | **iTerm** | `cpl-app.applescript` creates windows, sets bounds, writes commands |
| **Script Editor** / `osascript` | **System Events** | Window positioning for Zed |
| **Script Editor** / `osascript` | **Zed Preview** | `open -a` and positioning on launch |

Automation permissions are prompted on first use — run `cpl-app.applescript` once and approve each dialog.

### Verification

```bash
# Test cpl-close-zed (open Zed on a project first):
~/bin/cpl-close-zed "myproject"
# Zed closes = permissions correct
# Zed stays open + exit code 0 = Accessibility missing

# Test AppleScript can see Zed windows:
osascript -e 'tell application "System Events" to get name of every window of process "zed"'
# Returns window titles = working. Empty = permission missing.
```

### Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `cpl-close-zed` exits 0 but Zed stays open | Accessibility not granted to iTerm or the binary | Add both to Accessibility in System Settings |
| AppleScript returns empty window list | Automation not granted for System Events | Run AppleScript manually to trigger prompt |
| "Not authorized to send Apple events" | Automation permission denied | Enable in System Settings > Automation |
| Works on one machine but not another | Permissions are per-machine, not synced | Grant on each machine after `sync-cpl` |
| Permission granted but still fails | Binary was recompiled/resynced (different signature) | Remove and re-add the Accessibility entry |

### New Machine Setup

After running `sync-cpl.sh` on a new machine:

1. **Edit `~/.cpl.conf`** for your monitor resolution and layout preferences
2. Grant Accessibility to iTerm, `cpl-close-zed`, and CPL.app/Script Editor
3. Run CPL once in "Claude + Zed" mode — approve all Automation prompts
4. Verify with `~/bin/cpl-close-zed "testproject"`

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
