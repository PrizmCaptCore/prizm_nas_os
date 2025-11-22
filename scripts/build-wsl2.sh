#!/bin/bash
# Official Arch Linux ISO Build Script for WSL2/Ubuntu
# Uses the official releng profile without modifications

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CACHE_DIR="$PROJECT_ROOT/cache/pacman"

# Create cache directory
mkdir -p "$CACHE_DIR"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   Arch Linux ISO Build${NC}"
echo -e "${GREEN}   Official releng profile${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker not found${NC}"
    echo ""
    echo "Install Docker:"
    echo "  sudo apt update"
    echo "  sudo apt install -y docker.io"
    echo "  sudo systemctl start docker"
    echo "  sudo usermod -aG docker \$USER"
    echo ""
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon not running${NC}"
    echo ""
    echo "Start Docker:"
    echo "  sudo systemctl start docker"
    echo ""
    exit 1
fi

# Clean previous build if exists
if [ -d "$PROJECT_ROOT/output/work" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    docker run --rm -v "$PROJECT_ROOT:/build" archlinux:latest rm -rf /build/output/work 2>/dev/null || \
    sudo rm -rf "$PROJECT_ROOT/output/work"
fi

mkdir -p "$PROJECT_ROOT/output"

echo "Project: $PROJECT_ROOT"
echo "Building ISO..."
echo ""

# Run build in Docker container with interactive output
docker run --rm -it --privileged \
    -v "$PROJECT_ROOT:/build" \
    -v "$CACHE_DIR:/var/cache/pacman/pkg" \
    -v /dev:/dev \
    --cap-add=SYS_ADMIN \
    --cap-add=MKNOD \
    --device-cgroup-rule='b 7:* rmw' \
    -w /build \
    archlinux:latest \
    bash -c "
        set -e

        echo '==> Configuring faster mirrors (Korea)...'
        cat > /etc/pacman.d/mirrorlist << 'EOF'
Server = https://mirror.yuki.net.uk/archlinux/\$repo/os/\$arch
Server = https://mirrors.xtom.com/archlinux/\$repo/os/\$arch
Server = https://archive.archlinux.org/repos/last/\$repo/os/\$arch
EOF

        echo '==> Updating package database...'
        pacman -Sy --noconfirm

        echo '==> Installing archiso...'
        pacman -S --noconfirm archiso

        echo ''
        echo '==> Building ISO with official releng profile...'
        echo '    (Progress will be shown in real-time)'
        echo ''
        mkarchiso -v -w /build/output/work -o /build/output /build/iso

        echo ''
        echo '==> Setting permissions...'
        chmod 644 /build/output/*.iso 2>/dev/null || true
    "

# Check result
if [ $? -eq 0 ]; then
    ISO_FILE=$(ls -t "$PROJECT_ROOT/output"/*.iso 2>/dev/null | head -1)
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
    echo "  ./scripts/test-qemu.sh"
    echo ""
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi