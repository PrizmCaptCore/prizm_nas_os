# Contributing to NAS OS

Thank you for your interest in contributing to NAS OS! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/nas_project.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly
6. Commit and push
7. Create a pull request

## Development Environment

### Requirements

**Option 1: Native Arch Linux**
- Arch Linux or Arch-based distribution
- archiso package installed
- At least 10GB free disk space
- Basic knowledge of Bash scripting and Arch Linux

**Option 2: WSL2/Ubuntu/Debian (Recommended)**
- Docker installed and running
- At least 10GB free disk space
- Basic knowledge of Bash scripting

### Setup

**For Arch Linux:**
```bash
cd nas_project
sudo pacman -S archiso qemu-full
```

**For WSL2/Ubuntu/Debian:**
```bash
cd nas_project
# Install Docker if not already installed
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

## Areas for Contribution

### High Priority

- [ ] Installation automation scripts (nas-setup, nas-install)
- [ ] Automated testing (GitHub Actions workflows)
- [ ] Documentation improvements (guides, examples)
- [ ] Security hardening
- [ ] Size optimization (reduce ISO size further)

### Medium Priority

- [ ] ZFS integration and testing
- [ ] Backup solutions integration
- [ ] Notification system (email alerts, webhooks)
- [ ] Multi-language support for scripts
- [ ] ARM architecture support (aarch64)

### Nice to Have

- [ ] Web UI integration (Cockpit enhancements)
- [ ] Plugin/extension system
- [ ] Mobile monitoring app
- [ ] Cloud backup integration
- [ ] Advanced network features (VLANs, bonding)

## Coding Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Enable strict mode: `set -e`
- Use meaningful variable names
- Add comments for complex logic
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

Example:
```bash
#!/bin/bash
# Description of what this script does

set -e

# Constants in UPPERCASE
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/nas-os.log"

# Functions use lowercase with underscores
function check_requirements() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root"
        exit 1
    fi
}

# Main logic
check_requirements
# ...
```

### Configuration Files

- Use clear, descriptive comments
- Include examples
- Follow established conventions for each file type
- Test changes before committing

### Documentation

- Use clear, concise language
- Include examples where appropriate
- Keep README.md updated
- Add inline comments for complex code

## Testing

### Build Testing

Always test your changes by building the ISO:

**On Arch Linux:**
```bash
sudo ./scripts/build.sh
```

**On WSL2/Ubuntu/Debian:**
```bash
./scripts/build-wsl2.sh
```

The build process will:
1. Use Docker container with Arch Linux
2. Install archiso and dependencies
3. Build ISO using official releng profile
4. Output ISO to `output/` directory

### VM Testing

Test the built ISO in QEMU:

```bash
./scripts/test-qemu.sh
```

This will:
- Create a virtual disk if needed (20GB)
- Boot the ISO in QEMU
- Allow you to test installation and features

### Manual Testing Checklist

**Build & Boot:**
- [ ] ISO builds successfully (no errors)
- [ ] ISO size is reasonable (~1-1.5GB)
- [ ] System boots in both BIOS and UEFI modes
- [ ] Root login works (default: no password)

**Core Functionality:**
- [ ] Network connectivity works (dhcpcd)
- [ ] SSH daemon starts correctly
- [ ] Basic utilities work (nano, less, etc.)

**Storage (if testing storage features):**
- [ ] Btrfs/ext4/xfs formatting works
- [ ] LVM/mdadm works
- [ ] SMART monitoring works

**Optional Features (if installed):**
- [ ] Samba shares are accessible
- [ ] NFS exports work
- [ ] Docker containers can be created
- [ ] Web interfaces are accessible (Cockpit, etc.)

**General:**
- [ ] No regression in existing features
- [ ] No unexpected errors in logs

## Submitting Changes

### Commit Messages

Follow conventional commit format:

```
type(scope): brief description

Detailed explanation of what changed and why.

Fixes #issue_number
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, no code change
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(samba): add recycle bin support

Added vfs_recycle module to Samba configuration to enable
recycle bin functionality for all shares.

Fixes #42
```

```
fix(build): resolve package dependency issues

Updated packages.x86_64 to include missing dependencies
for cockpit-podman integration.
```

### Pull Request Process

1. **Before Submitting**
   - Ensure your code follows the guidelines
   - Test your changes thoroughly
   - Update documentation if needed
   - Rebase on latest main branch

2. **PR Description**
   - Clear title following commit message format
   - Describe what changed and why
   - Link related issues
   - Add screenshots for UI changes
   - List testing performed

3. **PR Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Refactoring

   ## Testing
   - [ ] Built ISO successfully
   - [ ] Tested in VM
   - [ ] All services work
   - [ ] No regressions

   ## Related Issues
   Fixes #

   ## Additional Notes
   Any other relevant information
   ```

4. **Review Process**
   - Address review comments
   - Keep discussion focused and professional
   - Be open to suggestions
   - Update PR based on feedback

## Adding New Features

### Adding Packages

1. Edit `iso/packages.x86_64`
2. Add package name (one per line)
3. Add comment explaining purpose
4. Test build

Example:
```
# Multimedia support
ffmpeg
imagemagick
```

### Adding Services

1. Add package to `iso/packages.x86_64`
2. Create service configuration in `iso/airootfs/etc/`
3. Test that service starts correctly after boot
4. Update documentation
5. Consider firewall implications (document if needed)

### Adding Scripts

1. Create script in `iso/airootfs/usr/local/bin/`
2. Add to `iso/profiledef.sh` file_permissions array
3. Ensure it's executable (755) and well-documented
4. Update README.md with usage examples

Example entry in `profiledef.sh`:
```bash
file_permissions=(
  ...
  ["/usr/local/bin/your-script"]="0:0:755"
)
```

### Adding Documentation

1. Create or update markdown files in `docs/`
2. Link from main README.md
3. Use clear headings and formatting
4. Include examples

## Code Review

### As a Reviewer

- Be respectful and constructive
- Focus on code quality and functionality
- Test changes when possible
- Respond in a timely manner
- Approve when satisfied or request changes clearly

### As an Author

- Respond to all comments
- Don't take criticism personally
- Explain your reasoning when necessary
- Make requested changes or discuss alternatives
- Thank reviewers for their time

## Reporting Issues

### Bug Reports

Include:
- NAS OS version
- Hardware specifications
- Steps to reproduce
- Expected behavior
- Actual behavior
- Relevant logs
- Screenshots if applicable

Template:
```markdown
**Describe the bug**
A clear description of the bug

**To Reproduce**
1. Step one
2. Step two
3. See error

**Expected behavior**
What should happen

**Environment**
- PRIZM NAS OS version/date:
- ISO size:
- Build method (Arch native / WSL2 Docker):
- Hardware (if applicable):
- QEMU/VM or bare metal:

**Logs**
```
Paste relevant logs here (dmesg, journalctl, build logs, etc.)
```
```

### Feature Requests

Include:
- Clear description of feature
- Use case / motivation
- Proposed implementation (optional)
- Examples from other projects (if applicable)

## Community Guidelines

- Be respectful and inclusive
- Help others learn
- Give credit where due
- Focus on constructive feedback
- Keep discussions on-topic

## Getting Help

- Check existing documentation
- Search closed issues
- Ask in discussions
- Be specific about your question
- Provide context and details

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be acknowledged in:
- Release notes
- CONTRIBUTORS.md file
- Project documentation

Thank you for contributing to NAS OS!
