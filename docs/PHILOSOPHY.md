# PRIZM NAS OS 설계 철학

## 핵심 원칙

### 1. NAS 본질에 집중
NAS의 핵심 기능은 **파일을 네트워크로 공유**하는 것입니다.
- ✅ 파일 공유 (SMB/NFS)
- ✅ SSH 관리
- ✅ 스토리지 관리
- ❌ 화려한 웹 UI는 본질이 아님

### 2. 최소에서 시작, 필요한 것만 추가

**기본 시스템** (~800MB):
```
파일시스템 → 파일공유 → 네트워크 → SSH
```

**선택적 추가**:
```bash
# 웹 UI가 필요하면
sudo pacman -S [경량 웹 UI]

# Docker가 필요하면
sudo pacman -S docker

# 모니터링이 필요하면
sudo pacman -S netdata
```

### 3. CLI First, GUI Optional

**대부분의 NAS 작업은 CLI가 더 효율적**:
- 설치: `nas-setup` (대화형)
- 상태 확인: `nas-status`
- 공유 추가: `nas-share-add /path/to/data`
- 사용자 관리: `nas-user-add john`

**웹 UI는 선택사항**:
- 모니터링 대시보드
- 파일 브라우저 (필요시)
- 설정 편집기

## Arch Linux를 선택한 이유

### 왜 Debian이 아닌가?

**Debian의 문제**:
1. 구버전 패키지 (Btrfs, ZFS 최신 기능 부족)
2. 불필요한 systemd 서비스 많음
3. apt는 pacman보다 느림
4. 업데이트 주기가 너무 길거나(stable) 너무 잦음(testing)

**Arch의 장점**:
1. ✅ **최신 커널** - 스토리지 기능 최신
2. ✅ **pacman** - 빠르고 간단한 패키지 관리
3. ✅ **AUR** - 커뮤니티 패키지 풍부
4. ✅ **최소주의** - 정말 필요한 것만 설치
5. ✅ **Arch Wiki** - 최고의 Linux 문서

### 안정성 문제 해결 전략

**우려**: Arch는 롤링 릴리즈라 업데이트 시 깨질 수 있음

**해결책**:
1. **보수적인 업데이트 정책**
   ```bash
   # 매달 한 번, 공지 확인 후 업데이트
   # https://archlinux.org/news/
   ```

2. **Btrfs 스냅샷 활용**
   ```bash
   # 업데이트 전 자동 스냅샷
   sudo btrfs subvolume snapshot / /.snapshots/before-update
   sudo pacman -Syu
   ```

3. **핵심 패키지만 설치**
   - base, kernel, file sharing, network
   - 실험적 패키지는 피함
   - AUR 패키지는 신중하게

4. **커뮤니티 지원**
   - Arch Wiki는 모든 문제의 해답
   - 포럼 활발, 문제 해결 빠름

## 용량 철학

### 기본 시스템: ~800MB

**포함**:
- Linux kernel + firmware (WiFi/GPU 지원)
- 파일 시스템: Btrfs, ext4
- 파일 공유: Samba, NFS
- 네트워크: SSH, WireGuard VPN, 방화벽
- 관리 도구: CLI 스크립트

**제외**:
- 웹 UI (선택 설치)
- Docker (선택 설치)
- 데스크톱 환경
- 불필요한 문서/로케일

### OpenWRT vs PRIZM NAS

**OpenWRT** (50-200MB):
- 라우터 특화
- 임베디드 시스템
- 기능 제한적

**PRIZM NAS** (~800MB):
- NAS/파일서버 특화
- 범용 x86_64 하드웨어
- 확장 가능

**크기 차이의 이유**:
- WiFi/GPU 펌웨어 (~250MB) - 개인 PC 지원
- 최신 커널 (~100MB) - 최신 스토리지 기능
- 완전한 GNU 환경 - Bash, coreutils 등

## 웹 UI 철학

### Cockpit은 무거움

**Cockpit 문제**:
- 100MB+ 크기
- 많은 의존성
- Red Hat 생태계 특화
- NAS에 불필요한 기능 많음

### 경량 커스텀 웹 UI 계획

**기술 스택**:
```
Backend: Go 또는 Flask (Python)
Frontend: Vanilla JS (no framework)
크기: ~10-20MB
```

**기능**:
- 📊 시스템 상태 대시보드
- 📁 공유 폴더 관리
- 👤 사용자 관리
- ⚙️ 설정 편집
- 📈 간단한 모니터링

**설치**:
```bash
# 선택 설치
sudo pacman -S prizm-nas-webui

# 또는 소스에서
git clone https://github.com/PrizmCaptCore/prizm-nas-webui
cd prizm-nas-webui && ./install.sh
```

## 타겟 사용자

### Primary: 기술적 호기심이 있는 개인 사용자

**특징**:
- CLI를 두려워하지 않음
- SSH 로그인 편함
- 최신 기술에 관심
- 커스터마이징 선호

**사용 사례**:
- 홈 미디어 서버 (Plex/Jellyfin)
- 개인 클라우드 (Nextcloud)
- 백업 스토리지
- 개발 환경

### Secondary: 리눅스 학습자

**가치**:
- Arch Linux 배우기
- 네트워크/스토리지 이해
- 실용적인 프로젝트
- 커뮤니티 기여

## 경쟁 제품 비교

### TrueNAS SCALE (Debian)
- ✅ 안정적, 엔터프라이즈급
- ❌ 무거움 (4GB+ RAM 필요)
- ❌ 구버전 패키지

### OpenMediaVault (Debian)
- ✅ 경량, 웹 UI 중심
- ❌ 플러그인 생태계 제한적
- ❌ Debian 구버전 패키지

### Unraid (Slackware)
- ✅ 독특한 스토리지 방식
- ❌ 유료 ($59-$129)
- ❌ 폐쇄 소스

### PRIZM NAS (Arch)
- ✅ 무료 오픈소스
- ✅ 최신 커널/패키지
- ✅ 최소주의, 확장 가능
- ✅ CLI 중심, GUI 선택
- ⚠️ 커뮤니티 지원 (기업 지원 없음)
- ⚠️ 초기 설정 필요

## 로드맵

### Phase 1: Core (현재)
- [x] 최소 부팅 가능한 ISO
- [x] Samba/NFS 파일 공유
- [x] SSH 접근
- [x] CLI 관리 스크립트

### Phase 2: 안정화
- [ ] 자동 업데이트 스크립트 (Btrfs 스냅샷 포함)
- [ ] 더 많은 CLI 도구 (nas-share, nas-user, nas-backup)
- [ ] 설정 백업/복원
- [ ] 문서 완성

### Phase 3: 웹 UI (선택)
- [ ] 경량 웹 대시보드 (~10MB)
- [ ] 파일 브라우저
- [ ] 모니터링 그래프
- [ ] 설정 편집기

### Phase 4: 커뮤니티
- [ ] 플러그인 시스템
- [ ] 커뮤니티 패키지 저장소
- [ ] 가이드/튜토리얼
- [ ] 포럼/Discord

## 결론

**PRIZM NAS는 "NAS의 본질"에 집중합니다**:
- 파일을 안전하고 빠르게 공유
- CLI로 효율적으로 관리
- 필요한 기능만 추가
- 최신 기술 활용
- 커뮤니티 중심

**웹 UI는 도구일 뿐, 목적이 아닙니다.**
