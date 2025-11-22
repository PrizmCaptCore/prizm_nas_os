#!/bin/bash
# Test PRIZM NAS OS in QEMU

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/output"
DISK_IMG="$OUTPUT_DIR/test-disk.img"

# Find latest ISO
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo -e "${RED}Error: No ISO file found in $OUTPUT_DIR${NC}"
    echo "Build first with: sudo ./scripts/build.sh"
    exit 1
fi

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   PRIZM NAS OS - QEMU Test${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "ISO: $ISO_FILE"
echo "Size: $(ls -lh "$ISO_FILE" | awk '{print $5}')"
echo ""

# Create virtual disk if not exists
if [ ! -f "$DISK_IMG" ]; then
    echo -e "${YELLOW}Creating virtual disk (20GB)...${NC}"
    qemu-img create -f qcow2 "$DISK_IMG" 20G
    echo -e "${GREEN}✓ Virtual disk created${NC}"
else
    echo "Using existing virtual disk: $DISK_IMG"
fi
echo ""

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo -e "${YELLOW}QEMU not found.${NC}"
    echo ""
    echo "Install with:"
    echo "  Arch Linux: sudo pacman -S qemu-full"
    echo "  Ubuntu/Debian: sudo apt install qemu-system-x86"
    echo ""
    exit 1
fi

# Check for KVM support
KVM_OPTS=""
if [ -e /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    echo -e "${GREEN}✓ KVM acceleration available${NC}"
    KVM_OPTS="-enable-kvm"
else
    echo -e "${YELLOW}! KVM not available, using software emulation (slower)${NC}"
fi

echo ""
echo -e "${GREEN}Starting QEMU...${NC}"
echo ""
echo "Controls:"
echo "  Ctrl+Alt+G - Release mouse"
echo "  Ctrl+Alt+F - Toggle fullscreen"
echo "  Ctrl+C - Stop VM"
echo ""

# Run QEMU
# -m 2048: 2GB RAM
# -smp 2: 2 CPU cores
# -boot d: Boot from CD-ROM
# -hda: Virtual hard disk for installation
# -serial stdio: Show serial console in terminal
qemu-system-x86_64 \
  -boot d \
  -cdrom "$ISO_FILE" \
  -hda "$DISK_IMG" \
  -m 2048 \
  -smp 2 \
  $KVM_OPTS \
  -serial stdio \
  -display gtk
