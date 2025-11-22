#!/bin/bash
# Clean build artifacts

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/output"

echo -e "${YELLOW}Cleaning build artifacts...${NC}"
echo ""

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Nothing to clean."
    exit 0
fi

# Show what will be deleted
echo "Will delete:"
if [ -d "$OUTPUT_DIR/work" ]; then
    echo "  - $OUTPUT_DIR/work/ (build cache)"
fi
if ls "$OUTPUT_DIR"/*.iso 1> /dev/null 2>&1; then
    echo "  - $OUTPUT_DIR/*.iso (built ISOs)"
fi

echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Clean
if [ -d "$OUTPUT_DIR/work" ]; then
    # Work directory might have root-owned files
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Using sudo to remove work directory...${NC}"
        sudo rm -rf "$OUTPUT_DIR/work"
    else
        rm -rf "$OUTPUT_DIR/work"
    fi
fi

if ls "$OUTPUT_DIR"/*.iso 1> /dev/null 2>&1; then
    rm -f "$OUTPUT_DIR"/*.iso
fi

echo ""
echo -e "${GREEN}✓ Cleaned${NC}"
