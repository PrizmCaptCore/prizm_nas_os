# PRIZM NAS OS

[![License](https://img.shields.io/github/license/PrizmCaptCore/prizm_nas_os)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/based%20on-Arch%20Linux-1793D1?logo=arch-linux)](https://archlinux.org/)

**미니멀리즘**

> **설계 철학**: 최소한의 기능만을 유지하고자 합니다.

## 특징

### TODO :
**Storage & File Sharing**
- SMB/NFS 파일 공유
- Btrfs RAID, 압축, 스냅샷
- ZFS 지원 (AUR)
- LVM, mdadm, SMART 모니터링

**Network & Routing**
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
- 고급 네트워크 도구 (선택 설치)

## 설계 철학

**개인 사용자 편의 위주**: web GUI 개발 예정
**개인 편의 위주**: CLI 부분을 최대한 수면 아래로 내릴 예정
**개인 환경 위주**: WiFi/GPU 펌웨어 포함

## 빠른 시작

### 1. ISO 빌드

**Arch Linux에서:**
```bash
sudo pacman -S archiso
cd nas_project
sudo ./scripts/build.sh
```

### 2. 테스트 (QEMU)

```bash
# QEMU 설치
sudo pacman -S qemu-full

# ISO 테스트
./scripts/test-qemu.sh
```

### 3. USB 설치 미디어 만들기

```bash
# USB 장치 확인
lsblk

# ISO를 USB에 쓰기 (주의: USB 내용이 삭제됩니다!)
sudo dd if=output/nas-os-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```


## 문서

### 변경 이력
- **[변경 이력](docs/CHANGELOG.md)** - 릴리스 노트

### 참여하기
- **[기여 가이드](docs/CONTRIBUTING.md)** - 프로젝트에 기여하는 방법
- **[트러블 슈팅](docs/TROUBLESHOOTING.md)** - 프로젝트에 참여해주시는 또 다른 방법
- **[기여자 목록](docs/CONTRIBUTORS.md)** - 기여해주신 분들

## 시스템 요구사항

### 테스트 시스템
- **CPU**: x86_64 (64비트) (4 Core, ARL)
- **RAM**: 512MB 최소, 1GB 권장
- **저장공간**: 시스템 2~3GB + 데이터 드라이브
- **네트워크**: 이더넷 (유선/무선)

전체 목록: `iso/packages.x86_64` (35개 패키지)

## 기여

기여 환영합니다! [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) 참조

## 라이선스

교육 및 개인 사용 목적으로 제공. 포함된 패키지는 각자의 라이선스를 따릅니다.

---

**주의**: 커스텀 운영체제입니다. 사용 전 중요 데이터를 백업하세요.
