# 보안 정책 (Security Policy)

## 지원되는 버전

현재 보안 업데이트를 받는 PRIZM NAS OS 버전:

| 버전 | 지원 여부 |
| --- | --- |
| 0.1.x | :white_check_mark: |
| < 0.1 | :x: |

## 보안 취약점 보고

PRIZM NAS OS의 보안 취약점을 발견하셨다면, 책임감 있게 공개해 주시기 바랍니다.

### 보고 방법

**공개 이슈로 보고하지 마세요.** 대신:

1. **GitHub Security Advisory**를 사용하세요:
   - [여기서 보안 권고 생성](https://github.com/PrizmCaptCore/prizm_nas_os/security/advisories/new)

2. 또는 이메일로 연락:
   - 보안 관련 이메일 주소 (추가 예정)

### 보고 시 포함해야 할 정보

취약점 보고서에는 다음을 포함해 주세요:

- 취약점 유형 (예: SQL 인젝션, XSS, 권한 상승 등)
- 취약점이 발견된 파일/경로의 전체 경로
- 영향을 받는 소스 코드의 위치 (태그/브랜치/커밋 또는 직접 URL)
- 취약점을 재현하는 데 필요한 특별한 설정
- 이슈를 재현하는 단계별 지침
- 개념 증명 또는 익스플로잇 코드 (가능한 경우)
- 취약점의 잠재적 영향 (공격자가 무엇을 할 수 있는지)

### 응답 프로세스

1. **확인** - 24-48시간 내에 보고서 수신을 확인합니다
2. **조사** - 취약점을 검증하고 심각도를 평가합니다
3. **수정** - 패치를 개발합니다
4. **공개** - 패치가 준비되면 권고사항을 공개합니다
5. **크레딧** - 원하시면 발견자로 인정해 드립니다

### 보안 업데이트

보안 업데이트는:
- 최대한 빨리 릴리스됩니다
- [Security Advisories](https://github.com/PrizmCaptCore/prizm_nas_os/security/advisories)에 문서화됩니다
- CHANGELOG.md에 기록됩니다
- GitHub Release를 통해 알립니다

## 보안 모범 사례

PRIZM NAS OS 사용 시:

### 설치 후 즉시
- [ ] Root 비밀번호 변경
- [ ] 관리자 사용자 생성
- [ ] SSH 키 기반 인증 설정
- [ ] 방화벽 규칙 구성 (UFW/nftables)
- [ ] fail2ban 활성화

### 정기적으로
- [ ] 시스템 업데이트: `sudo pacman -Syu`
- [ ] 로그 검토: `sudo journalctl -p warning`
- [ ] 디스크 상태 확인: `sudo smartctl -a /dev/sdX`
- [ ] 백업 검증
- [ ] 불필요한 서비스 비활성화

### 네트워크 보안
- [ ] 불필요한 포트 닫기
- [ ] VPN 사용 (외부 접속 시)
- [ ] 강력한 비밀번호 사용
- [ ] 정기적인 비밀번호 변경
- [ ] VLAN으로 네트워크 분리

### 컨테이너 보안
- [ ] 공식 이미지만 사용
- [ ] 정기적인 이미지 업데이트
- [ ] 최소 권한 원칙 적용
- [ ] 네트워크 격리

## 알려진 보안 고려사항

### 현재 제한사항
- ISO는 기본적으로 root 비밀번호가 없습니다 (Live 환경)
- 설치 시 즉시 비밀번호를 설정해야 합니다
- SSH는 기본적으로 활성화됩니다

### 계획된 개선사항
- SELinux/AppArmor 통합 (v0.2.0)
- 자동 보안 업데이트 옵션 (v0.2.0)
- 침해 탐지 시스템 (v1.0.0)

## 감사의 말

책임감 있게 보안 취약점을 보고해 주신 분들:

(아직 없음 - 첫 보고자가 되어주세요!)

## 추가 자료

- [Arch Linux Security](https://wiki.archlinux.org/title/Security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

---

보안은 모두의 책임입니다. 안전한 PRIZM NAS OS를 함께 만들어 갑시다!
