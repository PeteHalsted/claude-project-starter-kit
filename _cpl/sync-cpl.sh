#!/usr/bin/env bash
set -euo pipefail

# sync-cpl.sh — All-or-nothing CPL install/update
# Source: _cpl/ in claude-project-starter-kit repo
# Target: ~/bin/, ~/Applications/, ~/Library/Application Support/iTerm2/DynamicProfiles/

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CPL_DIR="$SCRIPT_DIR"
BIN_DIR="$CPL_DIR/bin"

DEST_BIN="$HOME/bin"
DEST_APP="$HOME/Applications"
DEST_ITERM="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
VERSION_FILE="$CPL_DIR/VERSION"
INSTALLED_VERSION_FILE="$HOME/.cpl-version"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; exit 1; }
info() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }

# Parse flags
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    *) error "Unknown flag: $arg" ;;
  esac
done

# Read versions
[[ -f "$VERSION_FILE" ]] || error "VERSION file not found: $VERSION_FILE"
REPO_VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")

INSTALLED_VERSION=""
if [[ -f "$INSTALLED_VERSION_FILE" ]]; then
  INSTALLED_VERSION=$(tr -d '[:space:]' < "$INSTALLED_VERSION_FILE")
fi

# Compare versions
if [[ "$REPO_VERSION" == "$INSTALLED_VERSION" ]]; then
  success "CPL v${REPO_VERSION} is current. Nothing to do."
  exit 0
fi

if [[ -z "$INSTALLED_VERSION" ]]; then
  info "CPL not installed. Install v${REPO_VERSION}?"
else
  info "CPL update available: v${INSTALLED_VERSION} → v${REPO_VERSION}. Install?"
fi

# Confirm unless --force
if [[ "$FORCE" != true ]]; then
  read -r -p "Proceed? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) echo "Cancelled."; exit 0 ;;
  esac
fi

echo ""
info "Installing CPL v${REPO_VERSION}..."
echo ""

# Ensure target directories exist
mkdir -p "$DEST_BIN"
mkdir -p "$DEST_APP"
mkdir -p "$DEST_ITERM"

# 1. Copy bash scripts to ~/bin/ and chmod +x
BASH_SCRIPTS=(cpl cpl-launch cpl-slot cpl-cleanup)
for script in "${BASH_SCRIPTS[@]}"; do
  cp "$BIN_DIR/$script" "$DEST_BIN/$script"
  chmod +x "$DEST_BIN/$script"
  echo "  Installed $script → ~/bin/$script"
done

# 2. Copy CPL.md to ~/bin/
cp "$BIN_DIR/CPL.md" "$DEST_BIN/CPL.md"
echo "  Installed CPL.md → ~/bin/CPL.md"

# 3. Compile and install Swift binaries
echo ""
info "Compiling Swift sources..."

# cpl-picker
echo "  Compiling cpl-picker.swift..."
swiftc -O "$BIN_DIR/cpl-picker.swift" -o "$DEST_BIN/cpl-picker" 2>&1
chmod +x "$DEST_BIN/cpl-picker"
echo "  Installed cpl-picker → ~/bin/cpl-picker"

# cpl-close-zed
echo "  Compiling cpl-close-zed.swift..."
swiftc -O "$BIN_DIR/cpl-close-zed.swift" -o "$DEST_BIN/cpl-close-zed" 2>&1
chmod +x "$DEST_BIN/cpl-close-zed"
echo "  Installed cpl-close-zed → ~/bin/cpl-close-zed"

# 4. Compile AppleScript → CPL.app
echo ""
info "Compiling CPL.app..."
# Copy source to ~/bin/ for reference
cp "$BIN_DIR/cpl-app.applescript" "$DEST_BIN/cpl-app.applescript"
# Compile to .app bundle
osacompile -o "$DEST_APP/CPL.app" "$BIN_DIR/cpl-app.applescript" 2>&1
echo "  Installed CPL.app → ~/Applications/CPL.app"

# 5. Copy iTerm2 profile
echo ""
cp "$CPL_DIR/iterm2/CPL.json" "$DEST_ITERM/CPL.json"
echo "  Installed CPL.json → ~/Library/Application Support/iTerm2/DynamicProfiles/CPL.json"

# 6. Write installed version
echo "$REPO_VERSION" > "$INSTALLED_VERSION_FILE"

echo ""
success "CPL v${REPO_VERSION} installed successfully."
