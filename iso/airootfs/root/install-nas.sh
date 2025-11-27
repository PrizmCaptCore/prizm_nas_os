#!/bin/bash
#
# PRIZM NAS OS Bootstrap Installer
# Downloads and runs the main installer from GitHub
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/haje-hwang/nas_project.git"
INSTALL_DIR="/tmp/nas_project"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   PRIZM NAS OS Installer${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}$1${NC}"
}

if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run as root"
fi

echo "Preparing installer..."

# Install git if not available
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    pacman -Sy --noconfirm git || error_exit "Failed to install git"
fi

# Clone repository
echo "Downloading latest installer from GitHub..."
rm -rf "$INSTALL_DIR"
git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || error_exit "Failed to clone repository"

success "✓ Installer downloaded"
echo ""

# Run main installer
chmod +x "${INSTALL_DIR}/scripts/install.sh"
exec "${INSTALL_DIR}/scripts/install.sh"
