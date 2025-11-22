# Changelog

All notable changes to NAS OS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- ZFS integration
- Web-based GUI improvements
- ARM architecture support
- Automated backup solutions
- Multi-language support

## [0.1.0] - 2025-11-21

### Added
- Initial release of NAS OS
- Arch Linux based system (x86_64)
- File sharing support (Samba/NFS)
- Advanced filesystem support (Btrfs, ext4)
- Docker container support
- Cockpit web management interface
- Netdata real-time monitoring
- Security features (fail2ban, UFW firewall)
- Custom management scripts:
  - `nas-setup`: Interactive setup wizard
  - `nas-status`: System status overview
- Comprehensive documentation:
  - Installation guide
  - Contributing guidelines
  - README with quick start
- Build system using archiso
- Testing scripts for QEMU

### Features
- SMB/CIFS file sharing via Samba
- NFS server support
- Btrfs with RAID and compression
- Docker and Docker Compose pre-installed
- Web-based system management (Cockpit)
- Real-time performance monitoring (Netdata)
- Intrusion prevention (fail2ban)
- Firewall management (UFW)
- Storage management tools (mdadm, LVM, smartmontools)
- Network management (NetworkManager)
- SSH server enabled by default

### Infrastructure
- archiso-based build system
- Automated service enablement
- Pre-configured firewall rules
- Sample configuration files for all services
- Build and test scripts

### Documentation
- Complete README
- Detailed installation guide
- Contributing guidelines
- Changelog
- Code comments and inline documentation

### Notes
- ZFS support requires manual installation from AUR
- Default root password is empty (must be set on first boot)
- Recommended minimum 4GB RAM for optimal performance

---

## Version History

- **0.1.0** (2025-11-21) - Initial release

## Future Roadmap

### Version 0.2.0 (Planned)
- Integrated ZFS support
- Improved web UI
- Automated system updates
- Backup automation tools
- Email notification system

### Version 0.3.0 (Planned)
- ARM64 support
- Plugin system
- Custom app store
- Mobile management app
- Multi-node clustering

### Version 1.0.0 (Planned)
- Production-ready release
- Full documentation
- Professional support options
- Long-term stability guarantees
- Enterprise features

---

For detailed changes, see the [commit history](https://github.com/your-repo/commits/main).

To report issues or suggest features, please [open an issue](https://github.com/your-repo/issues).
