# Quick Start Guide

Get your NAS OS up and running in minutes!

## Prerequisites

**For building:**
- Arch Linux (native build) OR
- Ubuntu/WSL2 with Docker (cross-platform build)

**For installation:**
- x86_64 hardware (64-bit PC)
- 512MB RAM minimum (1GB recommended)
- USB drive (2GB+) or DVD for installation media

## Build ISO

### Option A: Arch Linux (Native)

```bash
# Install archiso
sudo pacman -S archiso

# Navigate to project
cd nas_project

# Build the ISO
sudo ./scripts/build.sh
```

### Option B: Ubuntu/WSL2 (Docker)

```bash
# Install Docker (if not already installed)
sudo apt update
sudo apt install docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect

# Navigate to project
cd nas_project

# Build the ISO
./scripts/build-docker.sh
```

The ISO will be created in `output/` directory (~750MB, includes WiFi/GPU firmware for personal use).

## Test in Virtual Machine

```bash
# Install QEMU
sudo pacman -S qemu-desktop

# Test the ISO
./scripts/test-vm.sh
```

## Install to Hardware

### 1. Create Bootable USB
```bash
# Find your USB device
lsblk

# Write ISO to USB (CAUTION: This erases the USB!)
sudo dd if=output/nas-os-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### 2. Boot and Install

1. Boot from USB
2. Login as `root` (no password)
3. Run setup wizard:
   ```bash
   nas-setup
   ```

### 3. Add Optional Features (if needed)

The base system is minimal (~1.2GB, includes WiFi/GPU firmware). Add features as needed:

```bash
# Web management UI
sudo pacman -S cockpit
sudo systemctl enable --now cockpit.socket

# Docker containers
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker

# Real-time monitoring
sudo pacman -S netdata
sudo systemctl enable --now netdata
```

See [Optional Packages Guide](OPTIONAL_PACKAGES.md) for more options.

### 4. Access System

- **SSH**: `ssh root@<nas-ip>` or `ssh <username>@<nas-ip>`
- **Cockpit** (if installed): `https://<nas-ip>:9090`
- **Netdata** (if installed): `http://<nas-ip>:19999`

## Check System Status

```bash
nas-status
```

## Configure Network (Advanced)

```bash
sudo nas-network
```

Set up:
- VPN servers (WireGuard/OpenVPN)
- VLAN and network bridges
- DHCP/DNS server
- Port forwarding
- Network monitoring

## What's Included

**Base System (always included):**
- File sharing: Samba (SMB) and NFS
- Storage: Btrfs file system, parted, SMART monitoring
- Network: WireGuard VPN, DHCP/DNS (dnsmasq)
- Security: UFW firewall
- Tools: vim, wget, curl, rsync, bash-completion

**Optional (install as needed):**
- Containers: Docker + Docker Compose
- Web UI: Cockpit management
- Monitoring: Netdata real-time stats
- Advanced storage: LVM, mdadm RAID, ZFS
- Advanced VPN: OpenVPN, StrongSwan
- Load balancing: HAProxy, Squid

See [Optional Packages Guide](OPTIONAL_PACKAGES.md) for full list.

## Next Steps

1. Configure storage pools
2. Create file shares
3. Set up Docker containers
4. Configure backups
5. Harden security

For detailed instructions, see:
- [README.md](../README.md) - Overview
- [INSTALLATION.md](INSTALLATION.md) - Full installation guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribute to the project

## Getting Help

- Check documentation in `docs/`
- Review example configurations in `iso/airootfs/etc/`
- Read Arch Linux Wiki: https://wiki.archlinux.org/

## Common Commands

```bash
# System status
nas-status

# Firewall management
sudo ufw status
sudo ufw allow <port>

# Service management
sudo systemctl status <service>
sudo systemctl restart <service>

# View logs
sudo journalctl -u <service>
sudo journalctl -f  # Follow logs

# Docker (if installed)
docker ps
docker logs <container>

# Storage
df -h
lsblk
sudo smartctl -a /dev/sda

# Package management
sudo pacman -Syu        # Update system
sudo pacman -S <package> # Install package
sudo pacman -Rns <package> # Remove package
```

Enjoy your NAS OS!
