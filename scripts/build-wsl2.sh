#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CACHE_DIR="$PROJECT_ROOT/cache/pacman"

mkdir -p "$CACHE_DIR" "$PROJECT_ROOT/output"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not found" >&2
    echo "" >&2
    echo "Install with:" >&2
    echo "  sudo apt update && sudo apt install -y docker.io" >&2
    echo "  sudo systemctl start docker" >&2
    echo "  sudo usermod -aG docker \$USER" >&2
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Error: Docker daemon not running" >&2
    echo "Start with: sudo systemctl start docker" >&2
    exit 1
fi

# Clean previous build
if [ -d "$PROJECT_ROOT/output/work" ]; then
    docker run --rm -v "$PROJECT_ROOT:/build" archlinux:latest rm -rf /build/output/work 2>/dev/null || \
    sudo rm -rf "$PROJECT_ROOT/output/work"
fi

# Build in Docker
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
        
        cat > /etc/pacman.d/mirrorlist << 'MIRROREOF'
Server = https://mirror.yuki.net.uk/archlinux/\$repo/os/\$arch
Server = https://mirrors.xtom.com/archlinux/\$repo/os/\$arch
Server = https://archive.archlinux.org/repos/last/\$repo/os/\$arch
MIRROREOF
        
        pacman -Sy --noconfirm
        pacman -S --noconfirm archiso
        
        mkarchiso -v -w /build/output/work -o /build/output /build/iso
        
        chmod 644 /build/output/*.iso 2>/dev/null || true
    "

# Show result
if [ $? -eq 0 ]; then
    ISO_FILE=$(ls -t "$PROJECT_ROOT/output"/*.iso 2>/dev/null | head -1)
    echo ""
    echo "ISO: $ISO_FILE"
    echo "Size: $(ls -lh "$ISO_FILE" | awk '{print $5}')"
else
    echo "Build failed" >&2
    exit 1
fi
