# PRIZM NAS OS

<div align="center">

### 🌍 Language / 언어

**🇰🇷 한국어** (현재) | **[🇬🇧 English](README.md)**

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/based%20on-Arch%20Linux-1793D1?logo=arch-linux)](https://archlinux.org/)

</div>

**미니멀리즘 중심의 Arch Linux 기반 NAS OS**

> **디자인 철학**: 필수 요소만 유지하면서도 쉽게 확장 가능하도록

## 기능

### TODO:
**스토리지 & 파일 공유**
- SMB/NFS 파일 공유
- Btrfs RAID, 압축, 스냅샷
- ZFS 지원 (AUR)
- LVM, mdadm, SMART 모니터링

**네트워크 & 라우팅**
- VPN 서버 (WireGuard, OpenVPN)
- VLAN, Bridge, Bonding
- DHCP/DNS 서버 (dnsmasq)
- 로드 밸런서 (HAProxy)
- QoS, 트래픽 제어
- 고급 방화벽 (nftables, iptables, UFW)

**확장 가능**
- Docker (선택 설치)
- Cockpit 웹 관리 UI (선택 설치)
- Netdata 모니터링 (선택 설치)
- 고급 네트워킹 도구 (선택 설치)

## 디자인 철학

**사용자 편의성 우선**: 웹 GUI 개발 계획
**개인 편의성**: CLI 복잡성을 표면 아래에 숨길 계획
**개인 환경**: WiFi/GPU 펌웨어 포함

## 빠른 시작

### 1. ISO 빌드

**Arch Linux에서:**
```bash
sudo pacman -S archiso
cd nas_project
sudo ./scripts/build.sh
```

**WSL2/Ubuntu/Debian에서:**
```bash
cd nas_project
./scripts/build-wsl2.sh
```

### 2. 테스트 (QEMU)

```bash
# QEMU 설치
sudo pacman -S qemu-full  # Arch Linux
# 또는
sudo apt install qemu-system-x86  # Debian/Ubuntu

# ISO 테스트
./scripts/test-qemu.sh
```

### 3. USB 설치 미디어 생성

```bash
# USB 장치 확인
lsblk

# USB에 ISO 쓰기 (경고: USB 내용이 삭제됩니다!)
sudo dd if=output/archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## 문서

### 변경 로그
- **[Changelog](docs/CHANGELOG.md)** - 릴리스 노트

### 기여하기
- **[Contributing Guide](docs/CONTRIBUTING.md)** - 프로젝트 기여 방법
- **[Troubleshooting](docs/TROUBLESHOOTING_ko.md)** - 문제 해결 가이드 (한국어)
- **[Contributors](docs/CONTRIBUTORS.md)** - 기여자 목록

### 한국어 문서
- **[한국어 문서 목록](docs/README_KOREAN.md)** - 사용 가능한 한국어 문서

## 시스템 요구사항

### 테스트 시스템
- **CPU**: x86_64 (64-bit) (4 Core, ARL)
- **RAM**: 최소 512MB, 권장 1GB
- **스토리지**: 시스템 2~3GB + 데이터 드라이브
- **네트워크**: 이더넷 (유선/무선)

전체 목록: `iso/packages.x86_64` (37개 패키지)

## 포함된 패키지

**시스템 & 부트** (9개): base, linux, linux-firmware, mkinitcpio, mkinitcpio-archiso, grub, syslinux, efibootmgr, dosfstools

**네트워크** (2개): dhcpcd, openssh

**파일시스템** (3개): btrfs-progs, e2fsprogs, xfsprogs

**디스크 관리** (4개): mdadm, lvm2, parted, gptfdisk

**NAS 필수** (5개): rsync, smartmontools, ethtool, hdparm, nvme-cli

**CPU 마이크로코드** (2개): amd-ucode, intel-ucode

**기본 유틸리티** (10개): nano, sudo, less, arch-install-scripts, squashfs-tools, diffutils, kbd, util-linux

**웹 UI** (2개): python, python-flask

**총: 37개 패키지** - 전체 목록: [iso/packages.x86_64](iso/packages.x86_64)

**선택 설치**: Samba, NFS, Docker, Cockpit, Netdata, WireGuard 등

## 기여하기

기여를 환영합니다! [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) 참조

## 보안

보안 취약점을 발견하셨나요? GitHub Issues 또는 이메일로 신고해주세요.

**심각한 보안 취약점은 공개 이슈로 생성하지 마세요.** 관리자에게 직접 연락해주세요.

## 라이선스

교육 및 개인 사용 목적으로 제공됩니다. 포함된 패키지는 각각의 라이선스를 따릅니다.

---

**경고**: 이것은 커스텀 운영체제입니다. 사용 전 중요한 데이터를 백업하세요.
