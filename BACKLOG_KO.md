<!-- translated from: BACKLOG.md @ commit 7a1078f (2026-03-19) -->

# Taptime - 백로그 (MVP 이후)

> MVP 완료 후 계획된 기능입니다. 의존성과 우선순위에 따라 정렬되어 있습니다.
> 현재 MVP 작업은 [PLAN.md](PLAN.md)를 참조하세요.

## v1.1 — 동기부여 & 확장 통계

- [ ] 히트맵 캘린더 (GitHub 스타일 활동 시각화)
- [ ] 스트릭 추적 (목표를 연속으로 달성한 일수)
- [ ] 스트릭 마일스톤 축하 (7, 30, 100일)
- [ ] 휴식 타이머 (5분 짧은 휴식 / 15분 긴 휴식)
- [ ] 주간/월간 목표
- [ ] 월간 통계 뷰

## v1.2 — Google Calendar & 이펙트

- [ ] Google Calendar 연동 (클라이언트 사이드 OAuth)
- [ ] 동기부여 이펙트 (완료 애니메이션)
- [ ] 업적 배지

## v2.0 — 클라우드 백업

> v2.1+에서 교차 디바이스 데이터 공유가 필요한 기능의 선행 조건입니다.

- [ ] Supabase 연동
- [ ] Google/Apple 소셜 로그인 (백업 전용, 커스텀 계정 없음)
- [ ] 클라우드 백업/복원

## v2.1 — 위치 기반 자동 기록 (iOS)

> 등록된 장소에 도착하면 자동 감지하고 타이머 시작을 제안합니다.
> 의존성: 교차 디바이스 패턴 분석을 위한 v2.0 (Supabase)

### 핵심 개념

Preset은 선택적으로 **location trigger**를 가집니다. iOS가 지오펜스 영역 진입을 감지하면, 앱은 사용자가 타이머를 시작할 수 있도록 알림을 표시합니다.

### 주요 기술 세부사항

- **iOS API:** Core Location geofencing (`CLCircularRegion`)
  - 앱당 최대 20개 region 모니터링 가능 (일반적으로 3-5개 장소 등록이면 충분)
  - 앱이 종료된 상태에서도 동작함 (iOS가 백그라운드에서 재실행)
  - 배터리 영향이 매우 적음 (지속 GPS가 아니라 셀/Wi-Fi 기반 위치 추정)
  - 건물 기준 실용 반경 최소값: 약 150-200m
  - 이벤트 지연: 1-5분 (절전을 위한 배치 처리)
- **권한:** "Always" 위치 권한 (`NSLocationAlwaysAndWhenInUseUsageDescription`)
  - iOS는 "When In Use" 후 "Always"의 2단계 권한 요청을 강제
  - App Store 심사에서도 자동 타이머 시작 목적이 명확하면 방어 가능
- **Flutter 패키지:**
  - `flutter_background_geolocation` (Transistor Software) — 가장 성숙하지만 유료 라이선스 (~$299/년)
  - `geofencing_api` — 무료, 유지보수 상태 확인 필요
  - Custom Platform Channel (~150-200줄 Swift) — 무료, 완전한 제어 가능
- **실내 GPS 정확도는 낮음** — Wi-Fi 보조 시 10-30m, 권장 반경은 150-200m

### UX 플로우

```text
사용자가 프리셋에 위치를 등록 (지도 핀 또는 현재 위치)
  → iOS가 백그라운드에서 지오펜스 모니터링
  → 진입 감지 → 로컬 알림: "헬스장에 도착했습니다. 운동 타이머를 시작할까요?"
  → 사용자가 알림 탭 → 앱이 열리고 해당 프리셋 준비 → 타이머 시작
  → (선택) 이탈 감지 → "타이머를 종료할까요?" 알림
```

### 작업 목록

- [ ] `LocationTrigger` 모델 추가 (placeName, lat/lng, radius)
- [ ] Preset에 선택적 위치 필드 추가
- [ ] 위치 등록 UI (지도 또는 현재 위치)
- [ ] 지오펜스 모니터링 서비스 (Platform Channel 또는 패키지)
- [ ] 진입/이탈 알림 처리
- [ ] 자동 시작 옵션 (확인 생략)
- [ ] 설정: 전역 위치 추적 활성화/비활성화

## v2.2 — macOS 활동 모니터 (Companion App)

> Mac에서 앱 사용을 추적하는 별도 네이티브 Swift 메뉴 바 앱입니다.
> Taptime iOS와 Supabase를 통해 데이터를 공유합니다.
> 의존성: v2.0 (Supabase)

### 핵심 개념

가벼운 macOS 메뉴 바 데몬이 현재 전경 앱을 모니터링하고, 브라우저 창 제목을 파싱해 사이트를 식별하며, 규칙과 로컬 AI로 활동을 분류한 뒤, 결과를 공유 Supabase 백엔드에 동기화하여 Taptime에서 통합 생활 패턴 분석을 제공합니다.

### 왜 Flutter Desktop이 아니라 Native Swift인가

- 메뉴 바 데몬은 항상 실행되어야 함: Native는 약 10-20MB RAM, Flutter는 약 80-150MB
- 필요한 UI가 최소 수준임 (메뉴 바 드롭다운 + 설정 창)
- Platform Channel 없이 macOS API에 직접 접근 가능
- 예상 코드 규모: Swift 총 약 1,300줄

### 주요 기술 세부사항

**추적 (데이터 수집):**

| API | 데이터 | 권한 | 역할 |
|-----|------|------|------|
| `NSWorkspace` notifications | 앱 이름, bundle ID, 전환 시각 | 없음 | 핵심 앱 단위 추적 |
| `CGEventSource` | 마지막 입력 이후 초 | 없음 | 핵심 idle 감지 |
| AppleScript (`NSAppleScript`) | 브라우저 활성 탭 URL | 없음 (최초 사용 시 Automation 권한) | 사이트 추적 시작점으로 권장 |
| `CGWindowListCopyWindowInfo` | 창 제목 (페이지 제목) | Screen Recording | 사이트 추적 대안 |
| Accessibility API (`AXUIElement`) | URL 바 값, UI 요소 | Accessibility | 정밀 URL 추출 (고급) |

- **권장 경로:** 먼저 AppleScript 사용 (권한 부담 적고 Chrome/Safari 지원)
- AppleScript만 쓰는 접근은 **Mac App Store** 배포 가능성이 있음
- CGWindowList/Accessibility 접근은 **공증된 직접 다운로드**가 필요

**분류 (이 활동이 무엇인가?):**

단계별 3단계 접근:

| 단계 | 방식 | 동작 방식 |
|------|------|----------|
| 1. 규칙 기반 | 도메인/키워드 → 카테고리 테이블 | `github.com` → Dev, `youtube.com` → Entertainment. 사용자 수정 가능. 약 80% 커버 |
| 2. Core ML | 온디바이스 텍스트 분류기 | 누적된 규칙 기반 결과로 학습. Apple Create ML + Natural Language framework. 모델 크기 수 MB |
| 3. Local LLM (실험) | MLX (앱 내 포함) | "YouTube dev tutorial"을 Learning으로 구분하는 식의 문맥 인식. 별도 설치 불필요. 메모리 1-4GB |

**Fallback chain:** 사용자 규칙 → Core ML → MLX (앞 단계에서 매치되지 않을 때만 다음 단계로 진행)

> 분류 규칙은 Supabase를 통해 동기화하여, macOS 설정 창뿐 아니라 Taptime 모바일 앱에서도 관리할 수 있습니다.

**필터링 (무엇을 기록하지 않을 것인가?):**

- Blocklist: 제외할 앱/도메인 지정 (예: 메신저, 소셜 미디어)
- Allowlist mode: 등록된 앱/사이트만 기록
- Minimum duration: N초 미만 앱 전환은 무시
- Private/incognito 브라우징은 기본적으로 제외
- 설정 UI에서 사용자 조정 가능

### 아키텍처

```text
Tracker (NSWorkspace + CGEvent + AppleScript)
  → Classifier (rules → Core ML → MLX)
  → Filter (blocklist/allowlist)
  → SQLite (local buffer)
  → Supabase (periodic sync)
```

### 작업 목록

- [ ] Swift 프로젝트 설정 (menu bar app, SPM)
- [ ] 앱 전환 추적기 (`NSWorkspace` notifications)
- [ ] 브라우저 URL 추적기 (Chrome/Safari용 AppleScript)
- [ ] idle 감지 (`CGEventSource`, 5분 기준)
- [ ] JSON 설정 기반 규칙 분류기
- [ ] 필터 엔진 (blocklist/allowlist)
- [ ] 로컬 SQLite 저장소
- [ ] Supabase 동기화 (주기 업로드)
- [ ] 설정 UI (SwiftUI): 카테고리, 규칙, 필터
- [ ] 로그인 시 자동 실행 (`SMAppService`)
- [ ] Core ML 텍스트 분류기 (데이터 축적 후)
- [ ] Local LLM 연동 (실험, MLX 내장)

## v2.3 — 생활 패턴 대시보드

> iOS 수동/자동 세션과 macOS 활동 데이터를 결합한 통합 분석.
> 의존성: v2.1 + v2.2 데이터가 Supabase로 들어오는 것

### 핵심 개념

Taptime iOS 앱에 새로운 분석 화면을 추가하여, 모든 데이터 소스를 결합하고 사용자가 실제로 기기와 위치를 넘나들며 시간을 어떻게 쓰는지 보여줍니다.

### 기능

- [ ] 일일 타임라인 — 수동 + 자동 + Mac 데이터를 시간대별로 시각화
- [ ] 카테고리 시간 분포 — 도넛 차트 (Dev, Exercise, Learning, SNS...)
- [ ] 요일별 패턴 — "월/수/금: 헬스장, 화/목: 카페 공부"
- [ ] 디바이스 비교 — Mac vs Mobile 시간 분포
- [ ] 위치 인사이트 — 등록된 장소별 체류 시간
- [ ] 생산적/비생산적 비율 — 카테고리 기반

## v2.4 — 플랫폼 확장

- [ ] iOS 홈 화면 위젯
- [ ] Apple Watch / Wear OS 지원
