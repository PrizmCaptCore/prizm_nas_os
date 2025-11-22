#!/bin/bash
# PRIZM NAS OS Build Script - Arch Linux Native
# Requirements: Arch Linux with archiso package

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$PROJECT_ROOT/iso"
OUTPUT_DIR="$PROJECT_ROOT/output"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   PRIZM NAS OS Build${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}Error: This script requires Arch Linux${NC}"
    echo ""
    echo "Detected OS: $(cat /etc/os-release | grep "^NAME=" | cut -d'"' -f2)"
    echo ""
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Run: sudo $0"
    exit 1
fi

# Check if archiso is installed
if ! command -v mkarchiso &> /dev/null; then
    echo -e "${YELLOW}Installing archiso...${NC}"
    pacman -Sy --noconfirm archiso
fi

# Show build info
PACKAGE_COUNT=$(grep -v "^#" "$ISO_DIR/packages.x86_64" | grep -v "^$" | wc -l)
echo "Profile: $ISO_DIR"
echo "Packages: $PACKAGE_COUNT"
echo "Expected size: ~1.1GB ISO, ~1.5GB installed"
echo ""

# Clean previous builds
if [ -d "$OUTPUT_DIR/work" ]; then
    echo -e "${YELLOW}Cleaning work directory...${NC}"
    rm -rf "$OUTPUT_DIR/work"
fi

mkdir -p "$OUTPUT_DIR"

# Build
echo -e "${GREEN}Building ISO...${NC}"
echo ""

mkarchiso -v -w "$OUTPUT_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"

# Success
if [ $? -eq 0 ]; then
    ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
    ISO_SIZE=$(ls -lh "$ISO_FILE" | awk '{print $5}')

    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}   Build Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "ISO: $ISO_FILE"
    echo "Size: $ISO_SIZE"
    echo ""
    echo "Next steps:"
    echo "  Test in QEMU: ./scripts/test-qemu.sh"
    echo "  Write to USB: sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress"
    echo ""
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
