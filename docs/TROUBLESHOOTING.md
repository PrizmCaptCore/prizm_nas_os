# Troubleshooting Guide

## Boot Issues

### "Failed to mount '' on real root"

**Cause**: ISO label mismatch or CD/DVD device detection failure

**Solution**:

#### In VirtualBox:
1. VM Settings → Storage
2. Use **SATA Controller** instead of IDE
3. Attach ISO to SATA port
4. Verify "Type: DVD" setting

#### Modify boot options:
Press `e` in GRUB menu to edit boot options:
```
linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=NAS_OS_202511 copytoram
```

Then press `Ctrl+X` or `F10` to boot.

### Black screen after boot

**Possible causes**:
1. Graphics driver issue
2. Resolution incompatibility
3. KMS (Kernel Mode Setting) problem

**Solution**:

Add to kernel parameters (press `e` in GRUB):
```
nomodeset
```

Or for specific graphics:
- NVIDIA: `nouveau.modeset=0`
- AMD: `amdgpu.modeset=0`

### Boot hangs at "Loading initial ramdisk"

**Cause**: Corrupted ISO or USB write error

**Solution**:
1. Verify ISO checksum
2. Rewrite USB with verified ISO:
   ```bash
   sudo dd if=nas_os.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
3. Try different USB port (USB 2.0 instead of 3.0)

## Installation Issues

### "Failed to install packages"

**Cause**: Network issue or mirror unavailable

**Solution**:
1. Check network connection:
   ```bash
   ping archlinux.org
   ```

2. Update mirror list manually:
   ```bash
   nano /etc/pacman.d/mirrorlist
   ```
   Uncomment closer mirrors

3. Refresh package database:
   ```bash
   pacman -Syy
   ```

### "Disk not found" during partitioning

**Cause**: Disk not detected or wrong device name

**Solution**:
1. List all disks:
   ```bash
   lsblk
   fdisk -l
   ```

2. For NVMe drives, use:
   - `/dev/nvme0n1` instead of `/dev/sda`
   - Partitions: `nvme0n1p1`, `nvme0n1p2`, etc.

### GRUB installation fails

**UEFI system**:
```bash
# Remount EFI partition
mount /dev/sdX1 /boot

# Reinstall GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable

# Regenerate config
grub-mkconfig -o /boot/grub/grub.cfg
```

**BIOS system**:
```bash
grub-install --target=i386-pc /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

## Network Issues

### No network after boot

**Check interface**:
```bash
ip link show
```

**Enable DHCP**:
```bash
systemctl start dhcpcd
systemctl enable dhcpcd
```

**Manual IP configuration**:
```bash
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1
```

### WiFi not working

**Check wireless interface**:
```bash
ip link show
iwctl device list
```

**Connect to WiFi**:
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "NetworkName"
```

## Performance Issues

### Slow boot time

**Check boot time**:
```bash
systemd-analyze blame
```

**Disable unnecessary services**:
```bash
systemctl disable servicename
```

### High memory usage

**Check memory usage**:
```bash
free -h
htop
```

**Clear cache if needed**:
```bash
sync; echo 3 > /proc/sys/vm/drop_caches
```

## Package Manager Issues

### "Database lock" error

**Cause**: Another pacman process running or interrupted update

**Solution**:
```bash
# Check for running pacman
ps aux | grep pacman

# Remove lock file (only if no pacman is running)
sudo rm /var/lib/pacman/db.lck
```

### Key import failed

**Update keyring**:
```bash
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring
```

## Disk & Storage Issues

### RAID array won't assemble

**Check RAID status**:
```bash
cat /proc/mdstat
mdadm --detail /dev/mdX
```

**Force assemble**:
```bash
mdadm --assemble --force /dev/md0 /dev/sda1 /dev/sdb1
```

### Btrfs filesystem errors

**Check filesystem**:
```bash
btrfs scrub start /mount/point
btrfs scrub status /mount/point
```

**Repair (unmount first)**:
```bash
umount /mount/point
btrfs check --repair /dev/sdX
```

## Getting Help

If issues persist:

1. **Check logs**:
   ```bash
   journalctl -xb
   dmesg | tail -50
   ```

2. **Community support**:
   - GitHub Issues: https://github.com/yourusername/nas_project/issues
   - Arch Linux Forums: https://bbs.archlinux.org/
   - Arch Linux Wiki: https://wiki.archlinux.org/

3. **Include in bug reports**:
   - Hardware specifications
   - ISO version
   - Full error messages
   - Output of `journalctl -xb`
   - Steps to reproduce

---

**Korean Guide Available**: See [TROUBLESHOOTING_ko.md](TROUBLESHOOTING_ko.md) for Korean version.
