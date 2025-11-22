# 선택 패키지 가이드

PRIZM NAS OS는 **최소 기능으로 시작**하여 필요한 기능만 추가하는 철학을 따릅니다.

기본 설치는 **~750MB ISO, ~1.2GB 설치 크기**로 순수 NAS + 네트워킹 기능을 제공합니다.
**개인 사용자 친화적**: WiFi, 통합 GPU, 일반 하드웨어용 펌웨어가 포함되어 있습니다.

아래 패키지들을 필요에 따라 추가 설치하세요.

## 🐳 컨테이너 플랫폼

### Docker
```bash
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**용도**: Plex, Nextcloud, Home Assistant 등 컨테이너 애플리케이션 실행

**설치 후 크기**: ~200MB

### Podman (Docker 대안)
```bash
sudo pacman -S podman podman-compose
```

**용도**: rootless 컨테이너 실행, Docker보다 보안성 높음

**설치 후 크기**: ~150MB

## 🌐 웹 관리 인터페이스

### Cockpit (권장)
```bash
sudo pacman -S cockpit cockpit-storaged cockpit-machines
sudo systemctl enable --now cockpit.socket
```

**접속**: `https://<nas-ip>:9090`

**기능**:
- 시스템 관리 대시보드
- 스토리지 관리
- 네트워크 설정
- 터미널 접속

**설치 후 크기**: ~100MB

### Webmin
```bash
yay -S webmin
sudo systemctl enable --now webmin
```

**접속**: `https://<nas-ip>:10000`

**설치 후 크기**: ~50MB

## 📊 모니터링

### Netdata (실시간)
```bash
sudo pacman -S netdata
sudo systemctl enable --now netdata
```

**접속**: `http://<nas-ip>:19999`

**기능**: 실시간 성능 모니터링, 메트릭 수집

**설치 후 크기**: ~100MB

### Prometheus + Grafana
```bash
sudo pacman -S prometheus grafana
sudo systemctl enable --now prometheus grafana
```

**용도**: 시계열 데이터 수집 및 시각화

**설치 후 크기**: ~150MB

## 💾 고급 스토리지

### ZFS
```bash
yay -S zfs-dkms zfs-utils
sudo modprobe zfs
```

**용도**: 고급 파일시스템 (스냅샷, 압축, 복제)

**설치 후 크기**: ~50MB

### LVM (논리 볼륨 관리)
```bash
sudo pacman -S lvm2
```

**용도**: 유연한 디스크 파티션 관리

**설치 후 크기**: ~20MB

### mdadm (소프트웨어 RAID)
```bash
sudo pacman -S mdadm
```

**용도**: RAID 0/1/5/6/10 구성

**설치 후 크기**: ~10MB

## 🔐 고급 VPN

### OpenVPN
```bash
sudo pacman -S openvpn easy-rsa
```

**용도**: WireGuard보다 광범위한 호환성

**설치 후 크기**: ~30MB

### StrongSwan (IPsec)
```bash
sudo pacman -S strongswan
```

**용도**: 엔터프라이즈급 VPN (Cisco/Juniper 호환)

**설치 후 크기**: ~40MB

## 🌐 고급 네트워킹

### HAProxy (로드 밸런서)
```bash
sudo pacman -S haproxy
```

**용도**: HTTP/TCP 로드 밸런싱, SSL 종료

**설치 후 크기**: ~20MB

### Squid (프록시/캐시)
```bash
sudo pacman -S squid
```

**용도**: 웹 프록시, 캐싱, 컨텐츠 필터링

**설치 후 크기**: ~30MB

### FRR (고급 라우팅)
```bash
sudo pacman -S frr
```

**용도**: BGP, OSPF, RIP 라우팅 프로토콜

**설치 후 크기**: ~50MB

### Keepalived (HA)
```bash
sudo pacman -S keepalived
```

**용도**: VRRP를 통한 고가용성 구성

**설치 후 크기**: ~10MB

## 👨‍💻 개발 환경

### Python
```bash
sudo pacman -S python python-pip
```

**설치 후 크기**: ~100MB

### Node.js
```bash
sudo pacman -S nodejs npm
```

**설치 후 크기**: ~50MB

### Go
```bash
sudo pacman -S go
```

**설치 후 크기**: ~200MB

### Rust
```bash
sudo pacman -S rust
```

**설치 후 크기**: ~250MB

## 🗄️ 데이터베이스

### MariaDB
```bash
sudo pacman -S mariadb
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
```

**설치 후 크기**: ~150MB

### PostgreSQL
```bash
sudo pacman -S postgresql
sudo -u postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql
```

**설치 후 크기**: ~100MB

### Redis
```bash
sudo pacman -S redis
sudo systemctl enable --now redis
```

**설치 후 크기**: ~20MB

## 🔍 검색/인덱싱

### Elasticsearch
```bash
yay -S elasticsearch
sudo systemctl enable --now elasticsearch
```

**설치 후 크기**: ~500MB

## 📧 메일 서버

### Postfix + Dovecot
```bash
sudo pacman -S postfix dovecot
```

**용도**: 자체 메일 서버 운영

**설치 후 크기**: ~50MB

## 🎮 미디어 서버

### Jellyfin
```bash
sudo pacman -S jellyfin jellyfin-web jellyfin-ffmpeg
sudo systemctl enable --now jellyfin
```

**설치 후 크기**: ~100MB

### Plex (Docker 권장)
```bash
docker run -d --name=plex \
  --net=host \
  -e PUID=1000 -e PGID=1000 \
  -v /path/to/config:/config \
  -v /path/to/media:/media \
  plexinc/pms-docker
```

## 🔧 백업 도구

### restic
```bash
sudo pacman -S restic
```

**용도**: 증분 백업, 암호화, 클라우드 지원

**설치 후 크기**: ~30MB

### Borg
```bash
sudo pacman -S borg
```

**용도**: 중복 제거 백업

**설치 후 크기**: ~20MB

### rsnapshot
```bash
sudo pacman -S rsnapshot
```

**용도**: rsync 기반 스냅샷 백업

**설치 후 크기**: ~5MB

## 📝 추천 조합

### 홈 미디어 서버
```bash
sudo pacman -S docker docker-compose cockpit
# + Plex/Jellyfin Docker 컨테이너
```

**추가 크기**: ~300MB

### 파일 서버 + VPN
```bash
sudo pacman -S openvpn easy-rsa cockpit
```

**추가 크기**: ~130MB

### 완전한 홈랩 서버
```bash
sudo pacman -S docker docker-compose cockpit netdata
sudo pacman -S haproxy lvm2 mdadm
```

**추가 크기**: ~500MB

### 개발자 워크스테이션
```bash
sudo pacman -S docker docker-compose python nodejs
sudo pacman -S postgresql redis
```

**추가 크기**: ~500MB

## 🔧 서버 전용 경량화 (선택사항)

서버급 하드웨어에서 WiFi/GPU가 필요없다면 linux-firmware를 제거하여 ~250MB 절감 가능:

```bash
# 주의: WiFi, 통합 GPU, 일부 네트워크 카드가 작동하지 않을 수 있습니다!
sudo pacman -Rns linux-firmware

# 필요한 특정 펌웨어만 재설치 가능
# 예: Intel 유선랜만 필요한 경우
# sudo pacman -S linux-firmware-<specific>
```

**경고**: 개인 PC/노트북에서는 제거하지 마세요!

## 💡 설치 팁

### AUR 패키지 설치
```bash
# yay 설치 (AUR 헬퍼)
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### 패키지 검색
```bash
# 공식 저장소
pacman -Ss <검색어>

# AUR
yay -Ss <검색어>
```

### 설치된 패키지 크기 확인
```bash
pacman -Qi <패키지명> | grep Size
```

### 불필요한 패키지 제거
```bash
# 고아 패키지 제거
sudo pacman -Rns $(pacman -Qtdq)
```

## 📈 크기 참고

| 조합 | 추가 크기 | 총 크기 (1.2GB 기본 +) |
|------|----------|------------------------|
| 기본만 | 0MB | 1.2GB |
| + Docker | +200MB | 1.4GB |
| + Docker + Cockpit | +300MB | 1.5GB |
| + Docker + Cockpit + Netdata | +400MB | 1.6GB |
| 완전한 홈랩 | +500MB | 1.7GB |

---

**철학**: 필요한 것만 설치하여 시스템을 가볍고 빠르게 유지하세요.
