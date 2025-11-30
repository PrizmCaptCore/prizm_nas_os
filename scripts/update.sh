#!/bin/bash
#
# PRIZM NAS OS Update Script
# Updates the NAS system from GitHub
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/PrizmCaptCore/prizm_nas_os.git"
UPDATE_DIR="/tmp/nas_update"
INSTALL_DIR="/opt/nas-webui"
SERVICE_NAME="nas-webui"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   PRIZM NAS OTA Update${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run as root"
fi

# Check current version
CURRENT_VERSION="unknown"
if [ -f "${INSTALL_DIR}/VERSION" ]; then
    CURRENT_VERSION=$(cat "${INSTALL_DIR}/VERSION")
fi

echo "Current version: ${CURRENT_VERSION}"
echo ""

# Install git if not available
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    pacman -Sy --noconfirm git || error_exit "Failed to install git"
fi

# Clone latest version
echo "Downloading latest version from GitHub..."
rm -rf "$UPDATE_DIR"
git clone --depth 1 "$REPO_URL" "$UPDATE_DIR" || error_exit "Failed to clone repository"

# Check new version
NEW_VERSION="unknown"
if [ -f "${UPDATE_DIR}/webui/VERSION" ]; then
    NEW_VERSION=$(cat "${UPDATE_DIR}/webui/VERSION")
fi

echo "Latest version: ${NEW_VERSION}"
echo ""

if [ "$CURRENT_VERSION" = "$NEW_VERSION" ] && [ "$CURRENT_VERSION" != "unknown" ]; then
    warning "Already running the latest version"
    read -p "Continue anyway? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
        echo "Update cancelled"
        exit 0
    fi
fi

echo "Stopping service..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true

echo "Backing up current installation..."
if [ -d "$INSTALL_DIR" ]; then
    cp -r "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "Installing new version..."
mkdir -p "$INSTALL_DIR"
cp -r "${UPDATE_DIR}/webui/"* "$INSTALL_DIR/"

# Update systemd service if changed
if [ -f "${UPDATE_DIR}/systemd/nas-webui.service" ]; then
    cp "${UPDATE_DIR}/systemd/nas-webui.service" /etc/systemd/system/
    systemctl daemon-reload
fi

echo "Starting service..."
systemctl start "$SERVICE_NAME"
systemctl status "$SERVICE_NAME" --no-pager

# Cleanup
rm -rf "$UPDATE_DIR"

echo ""
success "================================"
success "  Update Complete!"
success "================================"
echo ""
echo "Version: ${CURRENT_VERSION} → ${NEW_VERSION}"
echo ""
