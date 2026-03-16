<!-- translated from: docs/planning/MVP_SPEC.md @ commit c197f75 (2026-03-17) -->

# Taptime - MVP 사양

> **버전:** 1.0
> **최종 업데이트:** 2026-03-14
> **범위:** 최소 기능 제품 — 개인 사용, 로컬 저장 전용

## 1. MVP 목표

사용자가 다음을 할 수 있는 기능적 시간 추적 앱 제공:
1. 활동을 위한 프리셋 생성
2. 프리셋을 탭하여 뽀모도로 타이머 시작
3. 기록된 세션과 기본 통계 확인
4. 일일 목표 설정 및 추적

**MVP 범위 밖:** 인증, 클라우드 동기화, Google Calendar, 휴식 타이머, 이펙트/애니메이션, 스트릭, 주간/월간 목표, 데이터 내보내기, 위젯.

---

## 2. MVP 기능

### 2.1 홈 화면 (프리셋 그리드)

**우선순위:** P0

- 프리셋을 그리드 레이아웃 (2열)으로 표시
- 각 프리셋 카드에 표시: 아이콘, 이름, 시간, 오늘의 진행률 바
- 프리셋 카드 탭 → 타이머 화면으로 이동
- 롱프레스 → 프리셋 편집
- FAB (플로팅 액션 버튼) → 새 프리셋 생성
- 첫 실행 시 3개 기본 프리셋 제공:
  - 공부 (25분, book 아이콘, 파란색)
  - 운동 (30분, dumbbell 아이콘, 빨간색)
  - 독서 (20분, glasses 아이콘, 초록색)

### 2.2 프리셋 생성/편집 화면

**우선순위:** P0

- 필드:
  - 이름 (필수, 최대 20자)
  - 시간 (분 단위, 필수, 1-180 범위, 기본 25)
  - 아이콘 (사전 정의된 아이콘 세트에서 선택, ~20개)
  - 색상 (사전 정의된 팔레트에서 선택, ~8개)
  - 일일 목표 (분 단위, 선택, 0 = 목표 없음)
- 저장 / 삭제 버튼
- 검증: 이름 비어있으면 안 됨, 시간은 0보다 커야 함

### 2.3 타이머 화면

**우선순위:** P0

- 큰 카운트다운 표시 (MM:SS)
- 원형 진행 표시기
- 프리셋 이름과 아이콘 표시
- 컨트롤:
  - **일시정지/재개** 토글 버튼
  - **정지** 버튼 (확인 대화상자 포함)
- 타이머 상태: `running` → `paused` → `running` / `stopped` / `completed`
- 완료 시:
  - 시스템 알림음 재생
  - 기기 진동
  - 세션 요약이 포함된 완료 대화상자 표시
  - 세션 자동 저장
- 수동 정지 시:
  - 확인 대화상자: "타이머를 정지하시겠습니까? X분이 기록됩니다."
  - 경과 시간으로 세션 저장
- 백그라운드에서 타이머 지속 (Flutter 백그라운드 서비스 / isolate 사용)
- 타이머 상태를 로컬 DB에 저장 (충돌 복구)

### 2.4 세션 히스토리 화면

**우선순위:** P0

- 날짜별 그룹화된 기록된 세션 목록
- 각 세션 항목에 표시:
  - 프리셋 아이콘 + 이름
  - 시작 시간 → 종료 시간
  - 소요 시간
  - 상태 뱃지 (완료 / 정지)
- 세션 탭 → 메모 편집 또는 삭제
- 당겨서 새로고침 (향후 동기화 호환성)

### 2.5 통계 화면

**우선순위:** P1

- **오늘 탭:**
  - 오늘 총 기록 시간
  - 프리셋별 분류 (수평 막대 차트)
  - 프리셋별 목표 진행률 (진행률 바 + 퍼센트)
- **주간 탭:**
  - 일별 총 시간 막대 차트 (월-일)
  - 주간 프리셋별 파이/도넛 차트
- 날짜 내비게이션 (이전/다음 일/주)

### 2.6 설정 화면

**우선순위:** P1

- 테마 토글 (라이트 / 다크)
- 타이머 사운드 온/오프
- 진동 온/오프
- 모든 데이터 초기화 (확인 대화상자 포함)
- 앱 버전 정보

---

## 3. 데이터 모델

### 3.1 Preset

```dart
class Preset {
  String id;          // UUID v4
  String name;        // 예: "공부"
  int durationMin;    // 타이머 시간 (분)
  String icon;        // 아이콘 식별자 (예: "book")
  String color;       // Hex 색상 (예: "#4A90D9")
  int dailyGoalMin;   // 일일 목표 (분, 0 = 목표 없음)
  int sortOrder;      // 그리드 내 위치
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 3.2 Session

```dart
class Session {
  String id;          // UUID v4
  String presetId;    // Preset FK
  DateTime startedAt; // 타이머 시작 타임스탬프
  DateTime endedAt;   // 타이머 종료 타임스탬프
  int durationSeconds;// 정밀 소요 시간
  String status;      // "completed" | "stopped"
  String? memo;       // 선택적 세션 후 메모
  DateTime createdAt;
}
```

### 3.3 UserSettings

```dart
class UserSettings {
  String themeMode;       // "light" | "dark" | "system"
  bool soundEnabled;      // 기본: true
  bool vibrationEnabled;  // 기본: true
}
```

---

## 4. 아키텍처

> **정식 출처:** `.claude/rules/architecture.md` — 결정 근거는 ADR-0002 참조.

### 4.1 개요

**패턴:** 2레이어 MVVM + Repository (기능 우선 폴더 구조)

```
UI (presentation) → Data (repository + data source)
                  ↘ shared models/interfaces
```

- UI 레이어는 shared 모델과 repository 인터페이스에만 의존 — data 구현체에 직접 의존 금지
- Data 레이어는 repository 인터페이스를 구현 — UI에서 import 금지
- 비즈니스 로직이 복잡해질 때만 해당 기능 내부에 Domain 레이어 추가

### 4.2 주요 아키텍처 결정

| 결정 | 선택 | 근거 |
|------|------|------|
| 아키텍처 | **2레이어 MVVM + Repository** | 이 앱 복잡도에 풀 Clean Architecture는 과도한 보일러플레이트 (ADR-0002) |
| 상태 관리 | **Riverpod** | 타입 안전, 테스트 가능, BuildContext 의존 없음 (ADR-0003) |
| 로컬 데이터베이스 | **Drift** | 타입 안전 SQLite, 리액티브 스트림, 활발한 유지보수 (ADR-0007) |
| 라우팅 | **GoRouter** | 선언적, 딥 링크 지원 |
| DI | **Riverpod 프로바이더** | 상태 관리에 내장; 인터페이스를 구현체에 연결 |

### 4.3 Repository 패턴 (교체 가능한 Data 레이어)

```dart
// shared/repositories/ - 추상 인터페이스
abstract class SessionRepository {
  Future<List<Session>> getSessionsByDate(DateTime date);
  Future<List<Session>> getSessionsByDateRange(DateTime start, DateTime end);
  Future<void> saveSession(Session session);
  Future<void> deleteSession(String id);
  Future<void> updateSession(Session session);
}

// features/history/data/ - 로컬 구현 (MVP)
class SessionRepositoryImpl implements SessionRepository {
  // Drift (SQLite) 사용
}
```

```dart
// shared/services/ - 캘린더 인터페이스 (향후 Google Calendar용)
abstract class CalendarService {
  Future<void> exportSession(Session session);
  Future<void> exportSessions(List<Session> sessions);
  Future<List<CalendarEvent>> getEvents(DateTime start, DateTime end);
}

// No-op 구현 (MVP) — 향후 연동을 위한 플레이스홀더
class NoOpCalendarService implements CalendarService { ... }
```

### 4.4 폴더 구조

```
lib/
├── main.dart
├── app.dart                     # MaterialApp, 테마, 라우터
├── core/                        # 공유 유틸리티
│   ├── theme/                   # 라이트/다크 테마, 색상, 타이포그래피
│   ├── constants/               # 앱 전역 상수, 기본 프리셋
│   ├── utils/                   # 날짜, 시간 헬퍼
│   └── router/                  # GoRouter 설정
├── features/
│   ├── preset/
│   │   ├── data/                # Repository 구현, 데이터 소스
│   │   └── ui/                  # 화면, 위젯, 뷰 모델
│   ├── timer/
│   │   ├── data/
│   │   └── ui/
│   ├── home/
│   │   └── ui/                  # Home은 자체 data 없음, preset/session repo 사용
│   ├── history/
│   │   ├── data/
│   │   └── ui/
│   ├── stats/
│   │   ├── data/
│   │   └── ui/
│   └── settings/
│       ├── data/
│       └── ui/
└── shared/                      # 기능 간 공유 코드
    ├── models/                  # Preset, Session, UserSettings 엔티티
    ├── repositories/            # 추상 repository 인터페이스
    └── services/                # 추상 서비스 인터페이스 (calendar, auth)
```

---

## 5. 화면 플로우

```
┌──────────┐     프리셋 탭     ┌─────────────┐
│          │ ───────────────►  │             │
│   홈     │                   │   타이머    │
│   화면   │  ◄─────────────── │   화면      │
│          │   완료/정지       │             │
├──────────┤                   └─────────────┘
│ [+] FAB  │──► 프리셋 폼
├──────────┤
│ 내비 바  │
│ ┌──┬──┬──┤
│ │홈│통│설│
│ │  │계│정│
│ │  │  │  │
└─┴──┴──┴──┘
      │   │
      ▼   ▼
  ┌──────┐ ┌──────────┐
  │통계  │ │ 설정     │
  │화면  │ │ 화면     │
  └──────┘ └──────────┘

  히스토리: 홈에서 접근 (앱 바 아이콘 버튼)
```

---

## 6. 내비게이션

- **하단 내비게이션 바** 3개 탭: 홈, 통계, 설정
- **히스토리**는 홈 앱 바의 아이콘 버튼으로 접근
- **타이머**는 전체 화면 push 라우트 (하단 내비 없음)
- **프리셋 폼**은 홈에서 push 라우트

---

## 7. MVP 마일스톤

| # | 마일스톤 | 기능 | 예상 화면 수 |
|---|---------|------|-------------|
| 1 | **기반** | 프로젝트 설정, 테마, 라우팅, DB 스키마, repository 인터페이스 | 0 |
| 2 | **프리셋** | 홈 화면, 프리셋 CRUD, 기본 프리셋 | 2 |
| 3 | **타이머** | 타이머 화면, 카운트다운 로직, 백그라운드 지속, 세션 저장 | 1 |
| 4 | **히스토리** | 세션 목록, 날짜별 그룹, 메모 편집, 삭제 | 1 |
| 5 | **통계** | 일간/주간 차트, 목표 진행률 | 1 |
| 6 | **설정** | 테마 토글, 사운드/진동, 데이터 초기화 | 1 |
| 7 | **마무리** | 애니메이션, 예외 케이스, 테스팅, 성능 | 0 |

---

## 8. 의존성 (Flutter 패키지)

| 패키지 | 목적 | 버전 전략 |
|--------|------|----------|
| `flutter_riverpod` | 상태 관리 | 최신 안정 버전 |
| `drift` + `drift_flutter` | 로컬 데이터베이스 | 최신 안정 버전 |
| `go_router` | 내비게이션/라우팅 | 최신 안정 버전 |
| `fl_chart` | 통계 차트 | 최신 안정 버전 |
| `uuid` | 고유 ID 생성 | 최신 안정 버전 |
| `flutter_local_notifications` | 타이머 완료 알림 | 최신 안정 버전 |
| `vibration` | 햅틱 피드백 | 최신 안정 버전 |
| `audioplayers` | 타이머 완료 사운드 | 최신 안정 버전 |

---

## 9. 품질 체크리스트 (MVP 종료 기준)

- [ ] 모든 P0 기능 동작
- [ ] 백그라운드에서 타이머 정상 작동
- [ ] 앱 재시작 후 타이머 상태 유지
- [ ] 세션이 올바른 타임스탬프로 저장됨
- [ ] 통계가 정확한 데이터 표시
- [ ] 라이트 및 다크 테마 작동
- [ ] 기본 사용자 플로우에서 충돌 없음
- [ ] iOS 및 Android 에뮬레이터에서 테스트 완료
