# PRIZM NAS OS

[![GitHub Stars](https://img.shields.io/github/stars/PrizmCaptCore/prizm_nas?style=social)](https://github.com/PrizmCaptCore/prizm_nas/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/PrizmCaptCore/prizm_nas)](https://github.com/PrizmCaptCore/prizm_nas/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/PrizmCaptCore/prizm_nas)](https://github.com/PrizmCaptCore/prizm_nas/pulls)
[![License](https://img.shields.io/github/license/PrizmCaptCore/prizm_nas)](LICENSE)

** 미니멀리즘 **

> 💡 **철학**: 최소한의 기능만을 유지하고자 합니다.

## 특징

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

**사용자 편의 위주** 

**기본 시스템** (~800MB):
```bash
파일공유(SMB/NFS) + SSH + Btrfs + 방화벽 = NAS의 본질
```
- 포함: 파일 공유, 스토리지, 네트워킹, CLI 도구
- 제외: 웹 UI, Docker, 모니터링 (선택 설치)
- **개인 PC 기준**: WiFi/GPU 펌웨어 포함

**관리 방식**:
```bash
nas-setup    # 대화형 초기 설정
nas-status   # 시스템 상태 확인
nas-network  # 네트워크 설정
# SSH + CLI = 빠르고 효율적
```

**확장**:
```bash
pacman -S docker cockpit netdata  # 필요한 것만 추가
```

📖 **자세한 철학**: [PHILOSOPHY.md](docs/PHILOSOPHY.md)
📦 **추가 패키지**: [OPTIONAL_PACKAGES.md](docs/OPTIONAL_PACKAGES.md)

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

### 4. 설치 및 설정

```bash
# USB로 부팅 후 root로 로그인 (비밀번호 없음)
nas-setup        # 초기 설정 마법사
nas-network      # 네트워크 설정 (VPN, VLAN 등)
nas-status       # 시스템 상태 확인
```

### 5. 웹 인터페이스 접속

- **Cockpit**: `https://<nas-ip>:9090` - 시스템 관리
- **Netdata**: `http://<nas-ip>:19999` - 모니터링

## 관리 도구

### nas-setup
초기 설정 마법사 - 네트워크, 사용자, 공유 폴더, 방화벽 설정

### nas-network
고급 네트워크 설정 - VLAN, VPN, DHCP/DNS, 포트 포워딩, 로드 밸런싱

### nas-status
시스템 상태 확인 - 네트워크, 서비스, 스토리지, Docker 컨테이너

## 사용 예시

**홈 서버 + 라우터**
```bash
nas-network  # DHCP/DNS 서버, NAT 설정
```

**VPN 게이트웨이**
```bash
nas-network  # WireGuard VPN 서버 자동 설정
```

**멀티미디어 서버**
```bash
docker run -d --name=plex -p 32400:32400 plexinc/pms-docker
```

## 문서

### 시작하기
- **[선택 패키지 가이드](docs/OPTIONAL_PACKAGES.md)** - Docker, 웹 UI 등 추가 기능 설치 ⭐
- **[빠른 시작](docs/QUICKSTART.md)** - 5분 안에 시작하기
- **[설치 가이드](docs/INSTALLATION.md)** - 상세 설치 방법
- **[프로젝트 요약](docs/PROJECT_SUMMARY.md)** - 전체 구조 한눈에 보기

### 기능별 가이드
- **[네트워킹](docs/NETWORKING.md)** - VPN, VLAN, 라우팅 설정
- **[변경 이력](docs/CHANGELOG.md)** - 릴리스 노트

### 참여하기
- **[기여 가이드](docs/CONTRIBUTING.md)** - 프로젝트에 기여하는 방법
- **[초보자 환영 이슈](docs/GOOD_FIRST_ISSUES.md)** - 처음 기여하기 좋은 이슈들
- **[로드맵](docs/ROADMAP.md)** - 개발 계획 및 로드맵
- **[기여자 목록](docs/CONTRIBUTORS.md)** - 기여해주신 분들

## 프로젝트 구조

```
nas_project/
├── iso/                    # Archiso 빌드 프로파일
│   ├── airootfs/          # 루트 파일시스템 오버레이
│   ├── packages.x86_64    # 패키지 목록
│   └── profiledef.sh      # ISO 정의
├── scripts/               # 빌드 스크립트
├── docs/                  # 문서
└── README.md
```

## 시스템 요구사항

### 기본 시스템
- **CPU**: x86_64 (64비트)
- **RAM**: 512MB 최소, 1GB 권장
- **저장공간**: 시스템 2~3GB + 데이터 드라이브
- **네트워크**: 이더넷 (유선/무선)

### 추가 기능 설치 시
- Docker 사용: 1~2GB RAM 추가 권장
- 웹 UI (Cockpit): 512MB RAM 추가 권장
- 모니터링 (Netdata): 512MB RAM 추가 권장
- 저장공간: 추가 기능당 평균 100~500MB

## 포함된 패키지 (기본 설치)

**시스템 & 부팅**: base, linux, grub, efibootmgr
**네트워크**: NetworkManager, OpenSSH, iproute2, iptables
**파일 공유**: Samba, NFS
**스토리지**: Btrfs, parted, smartmontools
**VPN**: WireGuard
**DNS/DHCP**: dnsmasq
**보안**: UFW 방화벽
**유틸리티**: vim, wget, curl, rsync, bash-completion

전체 목록: `iso/packages.x86_64` (25개 패키지)

추가 기능 (선택 설치): [선택 패키지 가이드](docs/OPTIONAL_PACKAGES.md) 참조


자세한 내용: [docs/INSTALLATION.md](docs/INSTALLATION.md)

## 기여

기여 환영합니다! [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) 참조

## 라이선스

교육 및 개인 사용 목적으로 제공. 포함된 패키지는 각자의 라이선스를 따릅니다.

---

**주의**: 커스텀 운영체제입니다. 사용 전 중요 데이터를 백업하세요.
