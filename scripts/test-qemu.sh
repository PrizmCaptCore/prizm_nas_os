#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/output"
DISK_IMG="$OUTPUT_DIR/test-disk.img"

# Find latest ISO
ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo "Error: No ISO found in $OUTPUT_DIR" >&2
    echo "Build first with: sudo ./scripts/build.sh" >&2
    exit 1
fi

# Check QEMU
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: QEMU not found" >&2
    echo "" >&2
    echo "Install with:" >&2
    echo "  Arch: sudo pacman -S qemu-full" >&2
    echo "  Ubuntu: sudo apt install qemu-system-x86" >&2
    exit 1
fi

# Create virtual disk
if [ ! -f "$DISK_IMG" ]; then
    qemu-img create -f qcow2 "$DISK_IMG" 20G > /dev/null
fi

# Check KVM
KVM_OPTS=""
if [ -e /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_OPTS="-enable-kvm"
fi

echo "Starting QEMU VM..."
echo ""
echo "Network: VM will be accessible at 192.168.100.2"
echo "Web UI:  http://192.168.100.2"
echo "SSH:     ssh root@192.168.100.2"
echo ""
echo "Press Ctrl+C to stop VM"
echo ""

# Run QEMU with user networking and port forwarding
# Host port 8080 -> VM port 80 (Web UI)
# Host port 2222 -> VM port 22 (SSH)
qemu-system-x86_64 \
  -boot d \
  -cdrom "$ISO_FILE" \
  -hda "$DISK_IMG" \
  -m 2048 \
  -smp 2 \
  $KVM_OPTS \
  -net nic -net user,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
  -serial stdio \
  -display gtk
