#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/output"

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Nothing to clean"
    exit 0
fi

# Show what will be deleted
echo "Will delete:"
[ -d "$OUTPUT_DIR/work" ] && echo "  - $OUTPUT_DIR/work/"
ls "$OUTPUT_DIR"/*.iso &> /dev/null && echo "  - $OUTPUT_DIR/*.iso"

echo ""
read -p "Continue? (y/N) " -n 1 -r
echo

[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# Clean
if [ -d "$OUTPUT_DIR/work" ]; then
    if [ "$EUID" -ne 0 ]; then
        sudo rm -rf "$OUTPUT_DIR/work"
    else
        rm -rf "$OUTPUT_DIR/work"
    fi
fi

rm -f "$OUTPUT_DIR"/*.iso 2>/dev/null || true

echo "Cleaned"
