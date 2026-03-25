# App Store Deploy Checklist

> Apple App Store 심사 제출 전 필수 항목 체크리스트.

## iOS 프로젝트 설정

- [ ] `ITSAppUsesNonExemptEncryption` — Info.plist에 추가
  - SQLCipher 사용으로 `YES` 설정 필요
  - 또는 암호화가 면제 대상인 경우 `NO` + 면제 사유 문서화
- [ ] `PrivacyInfo.xcprivacy` — 앱 레벨 프라이버시 매니페스트 생성
  - 수집 데이터 유형 선언: 위치 데이터, 사용자 ID, 사용 패턴
  - API 사용 이유 선언: UserDefaults, fileTimestamp 등
- [ ] 암호화 수출 규정 (Export Compliance)
  - SQLCipher (AES-256) 사용 → App Store Connect에서 수출 규정 질문에 응답 필요
  - 참고: https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations

## 개인정보 처리방침 (Privacy Policy)

- [ ] 개인정보 처리방침 웹페이지 작성 및 호스팅
  - 수집 항목: 위치 데이터, 세션 기록, 계정 정보 (Google/Apple ID)
  - 저장 방식: 로컬 SQLCipher 암호화 + Supabase 서버 (암호화 at rest)
  - 제3자 제공: 없음 (Supabase 인프라 제외)
  - 삭제 방법: 설정 > 데이터 초기화
- [ ] App Store Connect에 Privacy Policy URL 등록
- [ ] 앱 내에서 Privacy Policy 링크 제공 (설정 화면)

## App Store Connect 설정

- [ ] App Privacy Details (영양 라벨) 작성
  - Location: 앱 기능 (지오펜스)
  - Identifiers: User ID (인증)
  - Usage Data: 세션 기록 (앱 기능)
- [ ] 스크린샷 준비 (6.7", 6.1", iPad)
- [ ] 앱 설명, 키워드, 카테고리 설정
- [ ] 앱 아이콘 1024x1024 (이미 생성됨)

## 빌드 설정

- [ ] Bundle ID 확인 (com.taptime.taptime)
- [ ] 버전/빌드 번호 설정
- [ ] Release 모드 빌드 테스트
- [ ] 코드 서명 (Distribution certificate + Provisioning profile)

## 참고 문서

- [Apple: App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple: App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Apple: Required Privacy Manifest Reasons API](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files/describing-use-of-required-reason-api)
- [Apple: Complying with Encryption Export Regulations](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations)
