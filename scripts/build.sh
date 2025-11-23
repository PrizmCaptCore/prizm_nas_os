#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$PROJECT_ROOT/iso"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "Error: Requires Arch Linux" >&2
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Must run as root" >&2
    echo "Run: sudo $0" >&2
    exit 1
fi

# Install archiso if needed
if ! command -v mkarchiso &> /dev/null; then
    pacman -Sy --noconfirm archiso
fi

# Clean previous builds
[ -d "$OUTPUT_DIR/work" ] && rm -rf "$OUTPUT_DIR/work"
mkdir -p "$OUTPUT_DIR"

# Build
mkarchiso -v -w "$OUTPUT_DIR/work" -o "$OUTPUT_DIR" "$ISO_DIR"

# Show result
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
echo ""
echo "ISO: $ISO_FILE"
echo "Size: $(ls -lh "$ISO_FILE" | awk '{print $5}')"
