#!/bin/bash
#
# PRIZM NAS OS Auto Installer
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   PRIZM NAS OS Installer${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run as root"
fi

echo "Available disks:"
lsblk -d -n -o NAME,SIZE,TYPE | grep disk | while read line; do
    echo "  /dev/$line"
done
echo ""

read -p "Enter target disk (e.g., sda, nvme0n1): " TARGET_DISK
TARGET_DISK="/dev/${TARGET_DISK}"

if [ ! -b "$TARGET_DISK" ]; then
    error_exit "Disk $TARGET_DISK does not exist"
fi

echo ""
echo "Target disk information:"
lsblk "$TARGET_DISK"
echo ""

warning "ALL DATA ON $TARGET_DISK WILL BE DESTROYED!"
read -p "Type 'YES' to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Starting installation..."

if [[ "$TARGET_DISK" =~ "nvme" ]] || [[ "$TARGET_DISK" =~ "mmcblk" ]]; then
    PART_BIOS="${TARGET_DISK}p1"
    PART_EFI="${TARGET_DISK}p2"
    PART_ROOT="${TARGET_DISK}p3"
else
    PART_BIOS="${TARGET_DISK}1"
    PART_EFI="${TARGET_DISK}2"
    PART_ROOT="${TARGET_DISK}3"
fi

echo ""
echo "[1/11] Partitioning disk..."
parted -s "$TARGET_DISK" mklabel gpt
parted -s "$TARGET_DISK" mkpart primary 1MiB 2MiB
parted -s "$TARGET_DISK" set 1 bios_grub on
parted -s "$TARGET_DISK" mkpart ESP fat32 2MiB 514MiB
parted -s "$TARGET_DISK" set 2 esp on
parted -s "$TARGET_DISK" mkpart primary btrfs 514MiB 100%
success "✓ Partitioning complete"

echo ""
echo "[2/11] Formatting partitions..."
mkfs.fat -F32 "$PART_EFI"
mkfs.btrfs -f "$PART_ROOT"
success "✓ Formatting complete"

echo ""
echo "[3/11] Mounting partitions..."
mount "$PART_ROOT" /mnt
mkdir -p /mnt/boot
mount "$PART_EFI" /mnt/boot
success "✓ Partitions mounted"

echo ""
echo "[4/11] Installing base system (this may take a while)..."
pacstrap /mnt base linux linux-firmware
success "✓ Base system installed"

echo ""
echo "[5/11] Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
success "✓ fstab generated"

echo ""
echo "Initializing pacman keyring..."
arch-chroot /mnt pacman-key --init
arch-chroot /mnt pacman-key --populate archlinux
success "✓ Keyring initialized"

echo ""
echo "[6/11] Configuring system..."

arch-chroot /mnt ln -sf /usr/share/zoneinfo/UTC /etc/localtime
arch-chroot /mnt hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

read -p "Enter hostname for this NAS [default: prizm-nas]: " HOSTNAME
HOSTNAME=${HOSTNAME:-prizm-nas}
echo "$HOSTNAME" > /mnt/etc/hostname

cat > /mnt/etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

success "✓ System configured"

echo ""
echo "[7/11] Installing bootloader..."

if [ -d /sys/firmware/efi/efivars ]; then
    echo "Installing GRUB for UEFI..."
    arch-chroot /mnt pacman -S --noconfirm grub efibootmgr
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable 2>/dev/null || {
        warning "UEFI boot entry registration failed, using fallback mode"
        arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --no-nvram
    }
else
    echo "Installing GRUB for BIOS..."
    arch-chroot /mnt pacman -S --noconfirm grub
    arch-chroot /mnt grub-install --target=i386-pc "$TARGET_DISK"
fi

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
success "✓ Bootloader installed"

echo ""
echo "[8/11] Installing NAS packages..."
arch-chroot /mnt pacman -S --noconfirm \
    openssh \
    rsync \
    mdadm \
    lvm2 \
    smartmontools \
    btrfs-progs \
    e2fsprogs \
    xfsprogs \
    sudo \
    nano \
    dhcpcd \
    ethtool \
    hdparm \
    nvme-cli \
    parted \
    gptfdisk \
    python \
    python-flask

success "✓ NAS packages installed"

echo ""
echo "[9/11] Installing Web UI..."
mkdir -p /mnt/opt/nas-webui/templates

# Copy web UI files
if [ -d /opt/nas-webui ]; then
    cp -r /opt/nas-webui/* /mnt/opt/nas-webui/
    
    # Copy systemd service
    if [ -f /etc/systemd/system/nas-webui.service ]; then
        mkdir -p /mnt/etc/systemd/system
        cp /etc/systemd/system/nas-webui.service /mnt/etc/systemd/system/
    fi
    
    success "✓ Web UI installed"
else
    warning "Web UI files not found, skipping"
fi

echo ""
echo "[10/11] Enabling services..."
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl enable dhcpcd

# Enable web UI if service file exists
if [ -f /mnt/etc/systemd/system/nas-webui.service ]; then
    arch-chroot /mnt systemctl enable nas-webui
fi

success "✓ Services enabled"

echo ""
echo "[11/11] Setting root password..."
echo "Please enter root password for the installed system:"
arch-chroot /mnt passwd

success "✓ Root password set"

echo ""
read -p "Create a non-root user? (y/n) [default: n]: " CREATE_USER

if [ "$CREATE_USER" = "y" ] || [ "$CREATE_USER" = "Y" ]; then
    read -p "Enter username: " USERNAME
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Please enter password for user $USERNAME:"
    arch-chroot /mnt passwd "$USERNAME"

    echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
    chmod 440 /mnt/etc/sudoers.d/wheel

    success "✓ User $USERNAME created"
fi

echo ""
echo "Unmounting partitions..."
umount -R /mnt

echo ""
success "================================"
success "  Installation Complete!"
success "================================"
echo ""
echo "Your NAS is ready!"
echo ""
echo "After reboot, access the Web UI at:"
echo "  http://<your-nas-ip>"
echo ""
echo "To reboot, run: reboot"
echo ""
