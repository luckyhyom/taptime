# 2-Layer MVVM과 Drift: 과설계를 피한 아키텍처 선택

> 2026-03-18 | Taptime v1.0 Phase 0-1

## 배경

Taptime은 프리셋 기반 뽀모도로 타이머 앱이다. 첫 기술 선택에서 가장 중요했던 질문은 "1인 개발 규모에 맞는 아키텍처는 무엇인가?"였다. Flutter 커뮤니티에서 흔히 추천하는 Clean Architecture(3-layer)를 바로 적용할 수도 있었지만, 실제로 이 앱에 필요한 복잡도를 먼저 따져보기로 했다.

## 핵심 결정

### 1. 3-Layer Clean Architecture 대신 2-Layer MVVM

Flutter 앱의 아키텍처로 Clean Architecture(Presentation → Domain → Data)가 자주 언급된다. 하지만 이 구조를 적용하면 기능 하나당 8~12개 파일이 생긴다: Entity, Use Case, Repository Interface, Repository Impl, Data Source, Model, Mapper, Screen, ViewModel...

실제로 Taptime의 기능 대부분은 "DB에서 읽고 → 화면에 표시" 또는 "사용자 입력 → DB에 저장"이다. Use Case가 Repository를 그대로 통과시키는 pass-through 코드가 될 것이 뻔했다.

```
// Clean Architecture의 전형적인 pass-through Use Case
class GetAllPresetsUseCase {
  final PresetRepository _repository;
  Future<List<Preset>> call() => _repository.getAllPresets();
}
```

이런 코드는 유지보수 비용만 늘린다. 그래서 Flutter 공식 아키텍처 가이드(2025)가 권장하는 2-Layer 구조를 채택했다:

```
UI (presentation) → Data (repository + data source)
                  ↘ shared models/interfaces
```

- **UI 레이어:** Screen, Widget, Notifier(ViewModel)
- **Data 레이어:** Repository 구현체, Data Source
- **Shared:** 모델, Repository 인터페이스 (의존성 역전용)

만약 특정 기능이 복잡해지면 해당 기능 내부에만 `domain/` 폴더를 추가하면 된다. 전체를 3-layer로 만들 필요가 없다.

### 2. Feature-First 폴더 구조

Layer-first(`lib/domain/`, `lib/data/`, `lib/presentation/`)는 타이머 기능을 수정할 때 3개 폴더를 오가야 한다. Feature-first는 관련 파일이 한 곳에 모인다:

```
lib/features/timer/
├── data/                  # Repository 구현, Data Source
│   └── active_timer_repository_impl.dart
└── ui/                    # Screen, Widget, Notifier
    ├── timer_screen.dart
    └── timer_notifier.dart
```

`preset` 기능을 작업하면 `lib/features/preset/` 안에서만 움직인다. 크로스-기능 의존성은 `lib/shared/`의 Repository 인터페이스를 통해서만 허용된다.

### 3. Isar 대신 Drift (SQLite)

원래 local DB로 Isar를 선택했다. NoSQL이라 스키마 정의가 간단하고 Dart 네이티브라 설정이 쉬웠다. 그런데 실제로 의존성을 설치하자 문제가 드러났다: Isar 프로젝트가 사실상 중단되었고, 코드 제너레이션에서 의존성 충돌이 발생했다.

Drift(SQLite 기반)로 전환한 이유:

- **적극적 유지보수:** 정기 릴리즈와 빠른 이슈 대응
- **타입 안전 쿼리:** Dart 코드 제너레이션으로 컴파일 타임 체크
- **반응형 스트림:** `watch()` 메서드가 Riverpod과 자연스럽게 통합
- **구조화된 마이그레이션:** production에서 스키마 버전 관리 가능

```dart
// Drift의 watch() — DB 변경 시 자동으로 새 리스트를 emit
@override
Stream<List<Preset>> watchAllPresets() {
  return (_db.select(_db.presets)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch()
      .map((rows) => rows.map(_toModel).toList());
}
```

이 `watch()`가 Riverpod의 `StreamProvider`와 결합되면, DB에 프리셋이 추가/수정/삭제될 때 UI가 자동으로 갱신된다.

### 4. Local-First: 백엔드 없이 시작하기

Supabase를 처음부터 붙이고 싶은 유혹이 있었지만, MVP에서는 로컬 전용으로 결정했다:

- 타이머는 지하철에서도 동작해야 한다 (오프라인 필수)
- 연간 데이터 규모가 ~3,000 세션 수준이라 서버가 필요 없다
- Repository 인터페이스가 `shared/repositories/`에 있으므로, 나중에 Supabase 구현체를 추가할 때 UI 코드를 건드릴 필요가 없다

```dart
// shared/repositories/preset_repository.dart — 인터페이스
abstract class PresetRepository {
  Future<List<Preset>> getAllPresets();
  Future<void> createPreset(Preset preset);
  // ...
}

// features/preset/data/preset_repository_impl.dart — Drift 구현
class PresetRepositoryImpl implements PresetRepository {
  // 나중에 SupabasePresetRepository를 만들면 이것만 교체하면 된다
}
```

실제로 v2.0에서 Supabase를 추가했을 때, UI 코드는 한 줄도 바꾸지 않았다.

## 코드 워크스루: 데이터 레이어 설계 리뷰

Phase 1이 끝난 후, Phase 2-7의 요구사항을 미리 점검하는 "설계 리뷰"를 진행했다. 이 리뷰에서 8개 갭을 발견했고 구현 전에 모두 수정했다.

가장 중요한 발견은 **크래시 복구 메커니즘의 부재**였다. 타이머가 돌아가는 중에 앱이 죽으면 진행 중인 세션이 사라진다. 해결책으로 `ActiveTimer` 모델을 설계했다:

```dart
// lib/shared/models/active_timer.dart
class ActiveTimer {
  /// DB에 항상 1개만 존재하는 싱글턴 행.
  static const singletonId = 'singleton';

  final String id;           // 항상 'singleton'
  final String presetId;
  final DateTime startedAt;
  final bool isPaused;
  final DateTime? pausedAt;
  final int pausedDurationSeconds;
  final int remainingSeconds;
}
```

INSERT OR REPLACE로 테이블에 항상 0~1개의 행만 유지한다. 타이머 상태가 변할 때마다(시작, 일시정지, 재개) 이 행을 갱신하고, 앱 재시작 시 이 행이 있으면 타이머를 복구한다.

## 배운 점

- **아키텍처는 규모에 맞게 선택해야 한다.** Clean Architecture의 형식을 갖추는 것이 좋은 설계는 아니다. 2-Layer로 시작하고 복잡도가 올라갈 때 Domain layer를 추가하는 것이 현실적이다.
- **구현 전 설계 리뷰가 비용을 줄인다.** Phase 2-7의 요구사항을 미리 데이터 레이어에 반영함으로써 각 Phase에서 스키마를 수정하는 비용을 피했다.
- **의존성의 건강 상태를 확인해야 한다.** Isar처럼 인기 있던 라이브러리도 유지보수가 중단될 수 있다. 선택 전에 최근 커밋 빈도와 이슈 대응 속도를 확인하자.
