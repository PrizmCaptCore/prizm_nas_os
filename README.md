# PRIZM NAS OS

<div align="center">

### 🌍 Language / 언어

**[🇰🇷 한국어](README_ko.md)** | **🇬🇧 English** (Current)

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/based%20on-Arch%20Linux-1793D1?logo=arch-linux)](https://archlinux.org/)

</div>

**Minimalism-focused Arch Linux based NAS OS**

> **Design Philosophy**: Maintain only the essentials while keeping it easily extensible.

## Features

### TODO:
**Storage & File Sharing**
- SMB/NFS file sharing
- Btrfs RAID, compression, snapshots
- ZFS support (AUR)
- LVM, mdadm, SMART monitoring

**Network & Routing**
- VPN server (WireGuard, OpenVPN)
- VLAN, Bridge, Bonding
- DHCP/DNS server (dnsmasq)
- Load balancer (HAProxy)
- QoS, traffic control
- Advanced firewall (nftables, iptables, UFW)

**Extensible**
- Docker (optional install)
- Cockpit web management UI (optional install)
- Netdata monitoring (optional install)
- Advanced networking tools (optional install)

## Design Philosophy

**User Convenience First**: Web GUI development planned
**Personal Convenience**: Planning to hide CLI complexity beneath the surface
**Personal Environment**: WiFi/GPU firmware included

## Quick Start

### 1. Build ISO

**On Arch Linux:**
```bash
sudo pacman -S archiso
cd nas_project
sudo ./scripts/build.sh
```

**On WSL2/Ubuntu/Debian:**
```bash
cd nas_project
./scripts/build-wsl2.sh
```

### 2. Test (QEMU)

```bash
# Install QEMU
sudo pacman -S qemu-full  # On Arch Linux
# or
sudo apt install qemu-system-x86  # On Debian/Ubuntu

# Test ISO
./scripts/test-qemu.sh
```

### 3. Create USB Installation Media

```bash
# Check USB device
lsblk

# Write ISO to USB (WARNING: This will erase USB contents!)
sudo dd if=output/archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Documentation

### Changelog
- **[Changelog](docs/CHANGELOG.md)** - Release notes

### Contributing
- **[Contributing Guide](docs/CONTRIBUTING.md)** - How to contribute to the project
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Another way to contribute
- **[Contributors](docs/CONTRIBUTORS.md)** - List of contributors

### Korean Documentation
- **[Korean Docs Index](docs/README_KOREAN.md)** - 한국어 문서 목록

## System Requirements

### Test System
- **CPU**: x86_64 (64-bit) (4 Core, ARL)
- **RAM**: 512MB minimum, 1GB recommended
- **Storage**: System 2~3GB + data drives
- **Network**: Ethernet (wired/wireless)

Full list: `iso/packages.x86_64` (35 packages)

## Included Packages

**System & Boot** (9): base, linux, linux-firmware, mkinitcpio, mkinitcpio-archiso, grub, syslinux, efibootmgr, dosfstools

**Network** (2): dhcpcd, openssh

**Filesystems** (3): btrfs-progs, e2fsprogs, xfsprogs

**Disk Management** (4): mdadm, lvm2, parted, gptfdisk

**NAS Essentials** (5): rsync, smartmontools, ethtool, hdparm, nvme-cli

**CPU Microcode** (2): amd-ucode, intel-ucode

**Basic Utilities** (10): nano, sudo, less, arch-install-scripts, squashfs-tools, diffutils, kbd, util-linux

**Web UI** (2): python, python-flask

**Total: 37 packages** - Full list: [iso/packages.x86_64](iso/packages.x86_64)

**Optional Install**: Samba, NFS, Docker, Cockpit, Netdata, WireGuard, etc.

## Contributing

Contributions are welcome! See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)

## Security

Found a security vulnerability? Please report it via GitHub Issues or email.

**Do NOT** create public issues for serious security vulnerabilities. Contact maintainers directly.

## License

Provided for educational and personal use. Included packages are subject to their respective licenses.

---

**Warning**: This is a custom operating system. Please backup important data before use.
