# Good First Issues

처음 기여하시는 분들을 위한 시작하기 좋은 이슈들입니다!

## 🎯 초보자 환영 이슈들

### 문서 개선

**난이도: ⭐ (쉬움)**

1. **한글 문서 개선**
   - 오타 수정
   - 명확하지 않은 설명 개선
   - 예제 추가
   - 관련: `docs/*.md`

2. **영어 번역**
   - README 영문 버전 작성
   - 주요 문서 영문 번역
   - 관련: 새 파일 `README.en.md`

3. **스크린샷 추가**
   - 설치 과정 스크린샷
   - 웹 UI 스크린샷
   - 관련: `docs/INSTALLATION.md`

### 스크립트 개선

**난이도: ⭐⭐ (보통)**

4. **nas-status 출력 개선**
   - 색상 추가로 가독성 향상
   - 더 많은 정보 표시 (CPU 온도, 네트워크 속도 등)
   - 관련: `iso/airootfs/usr/local/bin/nas-status`

5. **nas-setup 메뉴 개선**
   - 사용자 경험 개선
   - 오류 처리 강화
   - 진행 상황 표시
   - 관련: `iso/airootfs/usr/local/bin/nas-setup`

6. **빌드 스크립트 로깅**
   - 빌드 진행 상황 로그 파일 저장
   - 오류 발생 시 상세 정보 출력
   - 관련: `scripts/build.sh`

### 패키지 및 설정

**난이도: ⭐⭐ (보통)**

7. **추가 파일시스템 지원**
   - XFS, F2FS 등 추가
   - 관련: `iso/packages.x86_64`

8. **기본 설정 최적화**
   - Samba 설정 최적화
   - NFS 설정 최적화
   - 관련: `iso/airootfs/etc/`

9. **서비스 자동 시작 개선**
   - 더 많은 서비스 자동 활성화 옵션
   - 관련: `iso/airootfs/root/.automated_script.sh`

### 새 기능 (작은 것)

**난이도: ⭐⭐⭐ (중간)**

10. **디스크 헬스 체크 스크립트**
    - SMART 정보 요약
    - 경고 상태 알림
    - 새 파일: `iso/airootfs/usr/local/bin/nas-health`

11. **백업 스크립트**
    - 간단한 백업 스크립트 작성
    - rsync 기반
    - 새 파일: `iso/airootfs/usr/local/bin/nas-backup`

12. **네트워크 속도 테스트**
    - iperf3 기반 네트워크 벤치마크
    - nas-network에 통합
    - 관련: `iso/airootfs/usr/local/bin/nas-network`

## 📚 어떻게 시작하나요?

### 1. 개발 환경 설정

```bash
# 저장소 포크 및 클론
git clone https://github.com/YOUR_USERNAME/prizm_nas_os.git
cd prizm_nas_os

# 새 브랜치 생성
git checkout -b feature/your-feature-name
```

### 2. 변경 작업

```bash
# 파일 수정
vim iso/airootfs/usr/local/bin/nas-status

# 테스트 (가능하면)
sudo ./scripts/build.sh
./scripts/test-vm.sh
```

### 3. 커밋 및 PR

```bash
# 변경사항 커밋
git add .
git commit -m "feat: nas-status에 CPU 온도 표시 추가"

# 푸시
git push origin feature/your-feature-name

# GitHub에서 PR 생성
```

## 💡 도움말

### 코딩 스타일
- Bash 스크립트: Google Shell Style Guide 따르기
- 들여쓰기: 스페이스 4칸
- 주석: 복잡한 로직에는 설명 추가

### 테스트
- 변경사항은 반드시 테스트
- VM에서 테스트하는 것을 권장
- 빌드가 성공하는지 확인

### 도움 요청
- 막히면 Issue에서 질문하세요
- [Discussions](https://github.com/PrizmCaptCore/prizm_nas_os/discussions)에서 토론
- 커뮤니티가 도와드립니다!

## 🏆 기여자 인정

기여해주신 모든 분들은:
- CONTRIBUTORS.md에 이름이 등재됩니다
- 릴리스 노트에 감사 인사가 포함됩니다
- GitHub 프로필에 기여 기록이 남습니다

## 다음 단계

첫 PR이 머지되면:
- ⭐⭐ 난이도 이슈에 도전해보세요
- 새로운 기능을 제안해보세요
- 다른 기여자를 도와주세요

---

**궁금한 점이 있으신가요?** [Q&A 이슈](https://github.com/PrizmCaptCore/prizm_nas_os/issues/new?template=question.md)를 열어주세요!
