#!/bin/bash
#
# PRIZM NAS OS Auto Installer
#
# This script automates the installation of NAS OS to a target disk.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   PRIZM NAS OS Installer${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Function to print error and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to print warning
warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Function to print success
success() {
    echo -e "${GREEN}$1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run as root"
fi

# Display available disks
echo "Available disks:"
lsblk -d -n -o NAME,SIZE,TYPE | grep disk | while read line; do
    echo "  /dev/$line"
done
echo ""

# Ask for target disk
read -p "Enter target disk (e.g., sda, nvme0n1): " TARGET_DISK
TARGET_DISK="/dev/${TARGET_DISK}"

# Verify disk exists
if [ ! -b "$TARGET_DISK" ]; then
    error_exit "Disk $TARGET_DISK does not exist"
fi

# Show disk info
echo ""
echo "Target disk information:"
lsblk "$TARGET_DISK"
echo ""

# Warning
warning "ALL DATA ON $TARGET_DISK WILL BE DESTROYED!"
read -p "Type 'YES' to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Starting installation..."

# Determine partition names
if [[ "$TARGET_DISK" =~ "nvme" ]] || [[ "$TARGET_DISK" =~ "mmcblk" ]]; then
    PART_BIOS="${TARGET_DISK}p1"
    PART_EFI="${TARGET_DISK}p2"
    PART_ROOT="${TARGET_DISK}p3"
else
    PART_BIOS="${TARGET_DISK}1"
    PART_EFI="${TARGET_DISK}2"
    PART_ROOT="${TARGET_DISK}3"
fi

# Step 1: Partition the disk
echo ""
echo "[1/10] Partitioning disk..."
parted -s "$TARGET_DISK" mklabel gpt
parted -s "$TARGET_DISK" mkpart primary 1MiB 2MiB
parted -s "$TARGET_DISK" set 1 bios_grub on
parted -s "$TARGET_DISK" mkpart ESP fat32 2MiB 514MiB
parted -s "$TARGET_DISK" set 2 esp on
parted -s "$TARGET_DISK" mkpart primary btrfs 514MiB 100%
success "✓ Partitioning complete"

# Step 2: Format partitions
echo ""
echo "[2/10] Formatting partitions..."
# BIOS boot partition doesn't need formatting
mkfs.fat -F32 "$PART_EFI"
mkfs.btrfs -f "$PART_ROOT"
success "✓ Formatting complete"

# Step 3: Mount partitions
echo ""
echo "[3/10] Mounting partitions..."
mount "$PART_ROOT" /mnt
mkdir -p /mnt/boot
mount "$PART_EFI" /mnt/boot
success "✓ Partitions mounted"

# Step 4: Install base system
echo ""
echo "[4/10] Installing base system (this may take a while)..."
pacstrap /mnt base linux linux-firmware
success "✓ Base system installed"

# Step 5: Generate fstab
echo ""
echo "[5/10] Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
success "✓ fstab generated"

# Step 5.5: Initialize pacman keyring
echo ""
echo "Initializing pacman keyring..."
arch-chroot /mnt pacman-key --init
arch-chroot /mnt pacman-key --populate archlinux
success "✓ Keyring initialized"

# Step 6: Configure system
echo ""
echo "[6/10] Configuring system..."

# Timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/UTC /etc/localtime
arch-chroot /mnt hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

# Hostname
read -p "Enter hostname for this NAS [default: prizm-nas]: " HOSTNAME
HOSTNAME=${HOSTNAME:-prizm-nas}
echo "$HOSTNAME" > /mnt/etc/hostname

# hosts file
cat > /mnt/etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

success "✓ System configured"

# Step 7: Install bootloader
echo ""
echo "[7/10] Installing bootloader..."

# Check if system is booted in UEFI mode
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

# Step 8: Install NAS packages
echo ""
echo "[8/10] Installing NAS packages..."
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
    gptfdisk

success "✓ NAS packages installed"

# Step 9: Enable services
echo ""
echo "[9/10] Enabling services..."
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl enable dhcpcd
success "✓ Services enabled"

# Step 10: Set root password
echo ""
echo "[10/10] Setting root password..."
echo "Please enter root password for the installed system:"
arch-chroot /mnt passwd

success "✓ Root password set"

# Create default user (optional)
echo ""
read -p "Create a non-root user? (y/n) [default: n]: " CREATE_USER

if [ "$CREATE_USER" = "y" ] || [ "$CREATE_USER" = "Y" ]; then
    read -p "Enter username: " USERNAME
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Please enter password for user $USERNAME:"
    arch-chroot /mnt passwd "$USERNAME"

    # Enable sudo for wheel group
    echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
    chmod 440 /mnt/etc/sudoers.d/wheel

    success "✓ User $USERNAME created"
fi

# Cleanup
echo ""
echo "Unmounting partitions..."
umount -R /mnt

echo ""
success "================================"
success "  Installation Complete!"
success "================================"
echo ""
echo "You can now reboot into your new NAS OS."
echo ""
echo "To reboot, run: reboot"
echo ""
