#!/bin/bash

# PastebinInit installer
# Installs pastebininit to /usr/local/bin
# Run with: sudo ./install.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/pastebininit.sh"
INSTALL_PATH="/usr/local/bin/pastebininit"

# Print messages
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Need root for /usr/local/bin
if [[ $EUID -ne 0 ]]; then
    error "Need root access (use: sudo ./install.sh)"
    exit 1
fi

# Make sure the main script is there
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    error "Can't find: $MAIN_SCRIPT"
    exit 1
fi

info "Installing PastebinInit..."

# Check what's missing
info "Checking dependencies..."
MISSING_DEPS=()

for cmd in curl jq; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    else
        success "Found: $cmd"
    fi
done

# Try to install missing stuff
if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    warning "Missing: ${MISSING_DEPS[*]}"
    
    # Detect package manager and install
    if command -v apt-get &> /dev/null; then
        info "Installing via apt-get..."
        apt-get update
        apt-get install -y "${MISSING_DEPS[@]}" bc
    elif command -v brew &> /dev/null; then
        info "Installing via Homebrew..."
        brew install "${MISSING_DEPS[@]}" bc
    elif command -v apk &> /dev/null; then
        info "Installing via apk..."
        apk add "${MISSING_DEPS[@]}" bc
    else
        warning "Couldn't auto-install"
        warning "Install these manually: ${MISSING_DEPS[*]} bc"
    fi
fi

# Make executable and copy
chmod 755 "$MAIN_SCRIPT"
success "Set permissions"

info "Copying to $INSTALL_PATH..."
cp "$MAIN_SCRIPT" "$INSTALL_PATH"
chmod 755 "$INSTALL_PATH"
success "Installed!"

# Check if it worked
if command -v pastebininit &> /dev/null; then
    success "All set!"
    info ""
    info "Try it:"
    info "  pastebininit --help"
    info ""
    info "Quick test:"
    info "  echo 'Hello World' > test.txt"
    info "  pastebininit -f test.txt"
else
    error "Installation might have failed. Check your PATH"
    exit 1
fi