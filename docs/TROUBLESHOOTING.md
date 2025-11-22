# 문제 해결 가이드

## 부팅 문제

### "Failed to mount '' on real root"

**원인**: ISO 레이블 불일치 또는 CD/DVD 장치 인식 실패

**해결 방법**:

#### VirtualBox에서:
1. VM 설정 → Storage
2. Controller: IDE가 아닌 **SATA Controller** 사용
3. ISO를 SATA 포트에 연결
4. "Type: DVD" 설정 확인

#### 부팅 옵션 수정:
GRUB 메뉴에서 `e` 키를 눌러 부팅 옵션 편집:
```
linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=NAS_OS_202511 copytoram
initrd /%INSTALL_DIR%/boot/x86_64/initramfs-linux.img
```

또는 디버깅을 위해:
```
linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux archisobasedir=arch archisolabel=NAS_OS_202511 copytoram debug
```

### "Switch Root Failed"

**원인**: initramfs에서 실제 root로 전환 실패

**확인 사항**:
1. `base` 패키지가 포함되어 있는지 확인
2. `systemd` 패키지 포함 확인
3. mkinitcpio hooks 설정 확인

### VirtualBox 권장 설정

```
Type: Linux
Version: Arch Linux (64-bit)
RAM: 2048 MB (최소 512MB)
Storage Controller: SATA (not IDE)
Enable PAE/NX: Yes
Processor: 2 CPUs
```

### QEMU 테스트

```bash
qemu-system-x86_64 \
  -boot d \
  -cdrom output/nas-os-*.iso \
  -m 2048 \
  -enable-kvm
```

## 패키지 설치 문제

### "failed to retrieve some files"

**원인**: 미러 서버 연결 실패

**해결**:
```bash
# 미러 리스트 업데이트
sudo reflector --country Korea,Japan --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy
```

### "community.db not found"

**원인**: community 저장소가 2023년에 extra로 통합됨

**해결**: pacman.conf에서 `[community]` 섹션 제거

## 네트워크 문제

### WiFi 작동 안 함

**확인**:
```bash
# 펌웨어 확인
dmesg | grep firmware

# linux-firmware 설치 확인
pacman -Q linux-firmware

# WiFi 장치 확인
ip link
```

### SSH 접속 안 됨

**확인**:
```bash
# SSH 서비스 상태
systemctl status sshd

# 방화벽 확인
sudo ufw status

# SSH 포트 열기
sudo ufw allow 22
```

## 빌드 문제

### Docker 권한 에러

```bash
# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 로그아웃 후 다시 로그인
```

### "work directory permission denied"

**원인**: 이전 빌드의 work 디렉토리가 root 소유

**해결**:
빌드 스크립트가 자동으로 정리하지만, 수동으로는:
```bash
# Docker 컨테이너로 삭제
docker run --rm --privileged -v $(pwd):/build archlinux:latest rm -rf /build/output/work
```

## 성능 문제

### 부팅이 느림

1. `copytoram` 옵션 사용 (RAM에 전체 로드)
2. SSD/NVMe 사용
3. VM의 경우 호스트 CPU 기능 활성화

### 메모리 부족

**최소 요구사항**:
- 기본 시스템: 512MB
- Docker 사용: +1GB
- 웹 UI: +512MB

## 하드웨어 호환성

### GPU 드라이버 누락

```bash
# Intel GPU
sudo pacman -S mesa intel-media-driver

# AMD GPU
sudo pacman -S mesa xf86-video-amdgpu

# NVIDIA
sudo pacman -S nvidia nvidia-utils
```

### WiFi 펌웨어 누락 메시지

```bash
# 무시해도 됨 (대부분의 경우)
# 특정 펌웨어만 필요하면:
dmesg | grep firmware
# 해당 펌웨어 패키지 설치
```

## 도움 받기

1. **로그 수집**:
   ```bash
   journalctl -b > boot.log
   dmesg > dmesg.log
   ```

2. **GitHub Issue 생성**: https://github.com/PrizmCaptCore/prizm_nas_os/issues
   - 에러 메시지 전체
   - 하드웨어 정보 (CPU, RAM, Storage)
   - 부팅 로그

3. **Arch Wiki**: https://wiki.archlinux.org/
