# NAS OS Installation Guide

This guide provides detailed instructions for installing and setting up NAS OS.

## Pre-Installation

### Download or Build ISO

#### Option 1: Build from Source
```bash
cd nas_project
sudo ./scripts/build.sh
```

#### Option 2: Use Pre-built ISO
Download from releases (if available)

### Prepare Installation Media

#### USB Drive
```bash
# Find your USB device
lsblk

# Write ISO to USB (replace /dev/sdX with your device)
sudo dd if=output/nas-os-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

#### Burn to DVD
Use your preferred DVD burning software (e.g., Brasero, K3b, Nero)

### Hardware Requirements Check

- x86_64 CPU
- 2GB RAM minimum (4GB+ recommended)
- 8GB system drive minimum
- Additional drives for storage
- Ethernet connection

## Installation Steps

### 1. Boot from Installation Media

1. Insert USB drive or DVD
2. Power on the system
3. Enter BIOS/UEFI (usually F2, F12, Del, or Esc)
4. Set boot priority to USB/DVD
5. Save and exit

### 2. Initial Login

The system boots into a live environment:

```
Username: root
Password: (no password, just press Enter)
```

### 3. Network Configuration

#### Check Network Status
```bash
ip addr show
```

#### Using DHCP (Automatic)
```bash
# Should work automatically via NetworkManager
nmcli device status
```

#### Static IP Configuration
```bash
# List available interfaces
nmcli device status

# Configure static IP
nmcli con add type ethernet con-name static-eth0 ifname eth0 \
  ip4 192.168.1.100/24 gw4 192.168.1.1

# Add DNS
nmcli con mod static-eth0 ipv4.dns "8.8.8.8,8.8.4.4"

# Activate connection
nmcli con up static-eth0
```

### 4. Disk Preparation

#### View Available Disks
```bash
lsblk
fdisk -l
```

#### Partition Scheme (UEFI)

Example for `/dev/sda`:

```bash
# Create partitions
gdisk /dev/sda

# Create:
# - 512MB EFI partition (type EF00)
# - Remaining space for root (type 8300)

# Format partitions
mkfs.fat -F32 /dev/sda1    # EFI
mkfs.btrfs /dev/sda2       # Root (or ext4)

# Mount
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```

#### Partition Scheme (BIOS)

```bash
# Create partitions
fdisk /dev/sda

# Create:
# - 1MB BIOS boot partition
# - Remaining space for root

# Format
mkfs.btrfs /dev/sda2

# Mount
mount /dev/sda2 /mnt
```

### 5. Install Base System

```bash
# Install essential packages
pacstrap /mnt base linux linux-firmware btrfs-progs

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new system
arch-chroot /mnt
```

### 6. System Configuration

#### Set Timezone
```bash
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc
```

#### Localization
```bash
# Edit /etc/locale.gen and uncomment needed locales
nano /etc/locale.gen

# Generate locales
locale-gen

# Set LANG variable
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

#### Network Configuration
```bash
echo "nas-os" > /etc/hostname

cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   nas-os.localdomain nas-os
EOF
```

#### Set Root Password
```bash
passwd
```

### 7. Install NAS Packages

```bash
# Update package database
pacman -Syu

# Install NAS essentials
pacman -S --needed \
  networkmanager \
  openssh \
  samba \
  nfs-utils \
  docker \
  docker-compose \
  cockpit \
  netdata \
  fail2ban \
  ufw \
  smartmontools \
  mdadm \
  lvm2

# Enable services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable docker
systemctl enable smb
systemctl enable nmb
systemctl enable nfs-server
systemctl enable cockpit.socket
systemctl enable netdata
systemctl enable fail2ban
systemctl enable ufw
```

### 8. Install Bootloader

#### UEFI
```bash
pacman -S grub efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=NASOS

grub-mkconfig -o /boot/grub/grub.cfg
```

#### BIOS
```bash
pacman -S grub

grub-install --target=i386-pc /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg
```

### 9. Create User

```bash
# Create user with sudo privileges
useradd -m -G wheel,docker -s /bin/bash admin

# Set password
passwd admin

# Enable sudo for wheel group
EDITOR=nano visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### 10. Finalize

```bash
# Exit chroot
exit

# Unmount
umount -R /mnt

# Reboot
reboot
```

## Post-Installation

### 1. First Boot Setup

After rebooting, log in as root or the user you created.

Run the NAS setup wizard:
```bash
sudo nas-setup
```

### 2. Configure Firewall

```bash
# Allow essential services
sudo ufw allow ssh
sudo ufw allow samba
sudo ufw allow 2049/tcp    # NFS
sudo ufw allow 9090/tcp    # Cockpit
sudo ufw allow 19999/tcp   # Netdata

# Enable firewall
sudo ufw enable
```

### 3. Set Up Storage

#### Create Storage Directories
```bash
sudo mkdir -p /srv/{samba,nfs,media,backups}
sudo chmod 755 /srv/{samba,nfs,media,backups}
```

#### Configure Btrfs Subvolumes (if using Btrfs)
```bash
# Create subvolumes
sudo btrfs subvolume create /srv/samba/data
sudo btrfs subvolume create /srv/media/videos
sudo btrfs subvolume create /srv/backups/snapshots

# Enable compression
sudo btrfs property set /srv/samba compression zstd
```

#### Set Up RAID (if using multiple drives)
```bash
# Create RAID 1 (mirror)
sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc

# Format
sudo mkfs.btrfs /dev/md0

# Add to fstab for auto-mount
echo "/dev/md0 /srv/storage btrfs defaults 0 0" | sudo tee -a /etc/fstab

# Mount
sudo mount -a
```

### 4. Configure Samba

Edit `/etc/samba/smb.conf`:

```ini
[storage]
    path = /srv/samba/storage
    writable = yes
    browseable = yes
    valid users = admin
    create mask = 0664
    directory mask = 0775
```

Add Samba user:
```bash
sudo smbpasswd -a admin
```

Restart Samba:
```bash
sudo systemctl restart smb nmb
```

### 5. Configure NFS

Edit `/etc/exports`:

```
/srv/nfs    192.168.1.0/24(rw,sync,no_subtree_check)
```

Apply changes:
```bash
sudo exportfs -rav
sudo systemctl restart nfs-server
```

### 6. Access Web Interfaces

Open in browser:
- **Cockpit**: `https://<nas-ip>:9090`
- **Netdata**: `http://<nas-ip>:19999`

### 7. Install Additional Software

#### ZFS Support
```bash
# Install yay (AUR helper)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install ZFS
yay -S zfs-dkms zfs-utils
sudo systemctl enable zfs-import-cache zfs-mount zfs.target
```

#### Additional Tools
```bash
# Media server
sudo docker run -d --name=plex -p 32400:32400 plexinc/pms-docker

# File sync
sudo pacman -S syncthing
```

## Troubleshooting

### System Won't Boot

1. Boot from installation media
2. Mount your system: `mount /dev/sda2 /mnt`
3. Chroot: `arch-chroot /mnt`
4. Reinstall bootloader (see step 8)

### Network Not Working

```bash
# Check status
nmcli device status
ip addr show

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check logs
journalctl -u NetworkManager
```

### Samba Not Accessible

```bash
# Check service status
sudo systemctl status smb nmb

# Check firewall
sudo ufw status

# Test configuration
testparm

# View logs
sudo journalctl -u smb
```

### Performance Issues

```bash
# Check system load
htop
nas-status

# Check disk health
sudo smartctl -a /dev/sda

# Monitor I/O
iotop
```

## Next Steps

- Set up automated backups
- Configure SMART monitoring
- Set up notifications
- Install additional Docker containers
- Configure remote access (VPN)
- Set up automated updates

## Additional Resources

- [Arch Wiki - Installation](https://wiki.archlinux.org/title/Installation_guide)
- [Arch Wiki - Samba](https://wiki.archlinux.org/title/Samba)
- [Arch Wiki - NFS](https://wiki.archlinux.org/title/NFS)
- [Arch Wiki - Docker](https://wiki.archlinux.org/title/Docker)
