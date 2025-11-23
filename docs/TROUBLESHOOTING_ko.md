# 문제 해결 가이드 (한국어)

> **English version**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

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
```

`Ctrl+X` 또는 `F10`을 눌러 부팅.

### 부팅 후 검은 화면

**가능한 원인**:
1. 그래픽 드라이버 문제
2. 해상도 비호환
3. KMS (Kernel Mode Setting) 문제

**해결 방법**:

커널 파라미터에 추가 (GRUB에서 `e` 누름):
```
nomodeset
```

또는 특정 그래픽 카드:
- NVIDIA: `nouveau.modeset=0`
- AMD: `amdgpu.modeset=0`

### "Loading initial ramdisk"에서 멈춤

**원인**: ISO 손상 또는 USB 쓰기 오류

**해결 방법**:
1. ISO 체크섬 확인
2. 확인된 ISO로 USB 다시 쓰기:
   ```bash
   sudo dd if=nas_os.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```
3. 다른 USB 포트 시도 (USB 3.0 대신 2.0)

## 설치 문제

### "Failed to install packages"

**원인**: 네트워크 문제 또는 미러 서버 불가

**해결 방법**:
1. 네트워크 연결 확인:
   ```bash
   ping archlinux.org
   ```

2. 미러 리스트 수동 업데이트:
   ```bash
   nano /etc/pacman.d/mirrorlist
   ```
   가까운 미러 주석 해제

3. 패키지 데이터베이스 새로고침:
   ```bash
   pacman -Syy
   ```

### 파티셔닝 중 "Disk not found"

**원인**: 디스크 미감지 또는 잘못된 장치명

**해결 방법**:
1. 모든 디스크 목록 확인:
   ```bash
   lsblk
   fdisk -l
   ```

2. NVMe 드라이브의 경우:
   - `/dev/sda` 대신 `/dev/nvme0n1` 사용
   - 파티션: `nvme0n1p1`, `nvme0n1p2` 등

### GRUB 설치 실패

**UEFI 시스템**:
```bash
# EFI 파티션 다시 마운트
mount /dev/sdX1 /boot

# GRUB 재설치
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable

# 설정 재생성
grub-mkconfig -o /boot/grub/grub.cfg
```

**BIOS 시스템**:
```bash
grub-install --target=i386-pc /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

## 네트워크 문제

### 부팅 후 네트워크 없음

**인터페이스 확인**:
```bash
ip link show
```

**DHCP 활성화**:
```bash
systemctl start dhcpcd
systemctl enable dhcpcd
```

**수동 IP 설정**:
```bash
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1
```

### WiFi 작동 안 함

**무선 인터페이스 확인**:
```bash
ip link show
iwctl device list
```

**WiFi 연결**:
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "네트워크이름"
```

## 성능 문제

### 느린 부팅 시간

**부팅 시간 확인**:
```bash
systemd-analyze blame
```

**불필요한 서비스 비활성화**:
```bash
systemctl disable 서비스명
```

### 높은 메모리 사용량

**메모리 사용량 확인**:
```bash
free -h
htop
```

**필요시 캐시 정리**:
```bash
sync; echo 3 > /proc/sys/vm/drop_caches
```

## 패키지 관리자 문제

### "Database lock" 오류

**원인**: 다른 pacman 프로세스 실행 중 또는 중단된 업데이트

**해결 방법**:
```bash
# 실행 중인 pacman 확인
ps aux | grep pacman

# lock 파일 제거 (pacman이 실행 중이지 않을 때만)
sudo rm /var/lib/pacman/db.lck
```

### 키 가져오기 실패

**키링 업데이트**:
```bash
pacman-key --init
pacman-key --populate archlinux
pacman -Sy archlinux-keyring
```

## 디스크 & 스토리지 문제

### RAID 배열이 조립되지 않음

**RAID 상태 확인**:
```bash
cat /proc/mdstat
mdadm --detail /dev/mdX
```

**강제 조립**:
```bash
mdadm --assemble --force /dev/md0 /dev/sda1 /dev/sdb1
```

### Btrfs 파일시스템 오류

**파일시스템 확인**:
```bash
btrfs scrub start /마운트/포인트
btrfs scrub status /마운트/포인트
```

**복구 (먼저 언마운트)**:
```bash
umount /마운트/포인트
btrfs check --repair /dev/sdX
```

## 도움 받기

문제가 지속되면:

1. **로그 확인**:
   ```bash
   journalctl -xb
   dmesg | tail -50
   ```

2. **커뮤니티 지원**:
   - GitHub Issues: https://github.com/yourusername/nas_project/issues
   - Arch Linux 포럼: https://bbs.archlinux.org/
   - Arch Linux Wiki: https://wiki.archlinux.org/

3. **버그 리포트에 포함할 내용**:
   - 하드웨어 사양
   - ISO 버전
   - 전체 오류 메시지
   - `journalctl -xb` 출력
   - 재현 단계
