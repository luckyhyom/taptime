# Local-First 앱에 클라우드 동기화 붙이기: Supabase + Last-Write-Wins

> 2026-03-22 | Taptime v2.0

## 배경

v1.0에서 "나중에 클라우드를 붙일 수 있도록" Repository 인터페이스를 분리해 두었다. v2.0에서 실제로 Supabase를 연동하면서, 그 결정이 빛을 발했다. 하지만 동기화 엔진 자체는 예상보다 복잡했다. Push/Pull 순서, FK 의존성, 충돌 해결, Soft Delete, Provider 재배선... 각 결정의 이유를 정리한다.

## 핵심 결정

### 1. Push 먼저, Pull 나중에

동기화의 기본 흐름은 "로컬 변경을 서버에 올리고(Push), 서버 변경을 로컬에 반영(Pull)"이다. 이 순서가 중요하다:

```dart
// lib/features/sync/data/supabase_sync_service.dart

Future<void> syncNow() async {
  if (_isSyncing) return;       // 재진입 방지
  if (!await _connectivity.isOnline) return;  // 오프라인 무시

  // Push → Pull 순서: 로컬 변경을 먼저 올리고 서버 변경을 받는다.
  await _pushLocationTriggers(userId);
  await _pushPresets(userId);
  await _pushSessions(userId);

  // Pull 전에 timestamp 캡처 — 양쪽 pull이 동일한 기준점 사용
  final lastPull = await SyncMetadata.getLastPullTimestamp();
  await _pullTable('location_triggers', userId, lastPull, _mergeLocationTrigger);
  await _pullTable('presets', userId, lastPull, _mergePreset);
  await _pullTable('sessions', userId, lastPull, _mergeSession);
  await SyncMetadata.setLastPullTimestamp(DateTime.now().toUtc());
}
```

Pull을 먼저 하면 위험하다: 서버의 오래된 데이터가 로컬의 최신 변경을 덮어쓸 수 있다. Push를 먼저 해서 내 변경이 서버에 반영된 상태에서 Pull하면 "lost write"를 방지할 수 있다.

### 2. FK 의존 순서

Push와 Pull 모두 테이블 순서를 지킨다: `location_triggers → presets → sessions`.

이유: `presets.locationTriggerId`가 `location_triggers.id`를 참조하고, `sessions.presetId`가 `presets.id`를 참조한다. 부모 테이블을 먼저 동기화해야 FK 제약을 위반하지 않는다.

이 순서가 깨지면 서버에서 "이 preset이 참조하는 location_trigger가 아직 없다"는 오류가 발생한다.

### 3. Last-Write-Wins 충돌 해결

두 기기에서 같은 프리셋을 수정하면 충돌이 발생한다. 복잡한 CRDT나 사용자 선택 다이얼로그 대신 `updatedAt` 비교로 최신 것을 유지한다:

```dart
Future<void> _mergePreset(Map<String, dynamic> serverJson) async {
  final localRow = await (_db.select(_db.presets)
        ..where((t) => t.id.equals(serverId)))
      .getSingleOrNull();

  // Case 1: 로컬에 없음 → 서버 데이터 삽입
  if (localRow == null) {
    if (serverDeletedAt != null) return;  // 이미 삭제된 것은 무시
    await _db.into(_db.presets).insert(/* ... */);
    return;
  }

  // Case 2: 로컬이 pending이고 서버보다 최신 → 로컬 유지
  if (localRow.syncStatus == SyncStatusDb.pending &&
      localRow.updatedAt.isAfter(serverUpdatedAt)) {
    return;  // 다음 Push에서 로컬이 서버를 덮어씀
  }

  // Case 3: 서버가 최신 → 서버 데이터로 덮어씀
  await (_db.update(_db.presets)..where((t) => t.id.equals(serverId))).write(
    PresetsCompanion(
      name: Value(preset.name),
      syncStatus: const Value(SyncStatusDb.synced),
      // ...
    ),
  );
}
```

LWW의 장점:
- **결정론적:** 동일한 데이터에 대해 항상 같은 결과
- **사용자 개입 불필요:** 충돌 다이얼로그 없음
- **오프라인 보호:** 로컬이 pending이고 서버보다 새로우면 로컬이 보존됨

단점은 동시 수정 시 한쪽이 유실되는 것이지만, 1인 사용자 앱에서 동시 수정은 극히 드물다.

### 4. Decorator 패턴으로 동기화 관심사 분리

기존 `PresetRepositoryImpl`에 동기화 코드를 넣으면 SRP 위반이다. 대신 Decorator로 감쌌다:

```dart
// lib/features/sync/data/sync_aware_preset_repository.dart

class SyncAwarePresetRepository implements PresetRepository {
  SyncAwarePresetRepository(this._inner, this._syncService);

  final PresetRepository _inner;
  final SyncService _syncService;

  // 읽기: 그대로 위임
  @override
  Future<List<Preset>> getAllPresets() => _inner.getAllPresets();

  // 쓰기: 위임 + 동기화 트리거
  @override
  Future<void> createPreset(Preset preset) async {
    await _inner.createPreset(preset);
    unawaited(_syncService.syncNow());  // fire-and-forget
  }
}
```

핵심은 `unawaited(_syncService.syncNow())`다. 쓰기 작업은 로컬 DB 저장이 끝나면 즉시 반환하고, 동기화는 백그라운드에서 진행된다. 사용자는 네트워크 지연을 느끼지 않는다.

### 5. 조건부 Provider 래핑

로그인하지 않은 사용자는 동기화가 필요 없다. Provider에서 조건부로 Decorator를 적용한다:

```dart
// 로그인 상태에 따라 bare repository 또는 sync-aware decorator 선택
final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  final repo = PresetRepositoryImpl(ref.read(databaseProvider));
  final syncService = ref.read(syncServiceProvider);
  if (syncService != null) {
    return SyncAwarePresetRepository(repo, syncService);
  }
  return repo;
});
```

UI 코드는 `ref.watch(presetRepositoryProvider)`만 호출한다. 동기화 여부를 알 필요가 없다. v1.0에서 정의한 `PresetRepository` 인터페이스 덕분이다.

### 6. Soft Delete

동기화가 있으면 `DELETE FROM`을 바로 하면 안 된다. 삭제를 다른 기기에 전파할 방법이 없기 때문이다. `deletedAt` 타임스탬프를 쓰는 soft delete로 전환했다:

```dart
// 삭제 시: 실제 DELETE 대신 deletedAt 설정
Future<void> deletePreset(String id) async {
  await (_db.update(_db.presets)..where((t) => t.id.equals(id))).write(
    PresetsCompanion(
      deletedAt: Value(DateTime.now()),
      syncStatus: const Value(SyncStatusDb.pending),
    ),
  );
}

// 조회 시: deletedAt이 null인 것만 반환
Future<List<Preset>> getAllPresets() async {
  return (_db.select(_db.presets)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get()
      .then((rows) => rows.map(_toModel).toList());
}
```

Push 시 `deletedAt`이 있는 행도 서버에 올리고, Pull 시 서버의 `deletedAt`이 있는 행은 로컬에도 soft delete를 적용한다.

## 코드 워크스루: 동기화 트리거 시점

동기화가 너무 자주 일어나면 배터리를 소모하고, 너무 드물면 데이터가 오래 뒤처진다. 4가지 트리거로 균형을 잡았다:

```dart
@override
Future<void> start() async {
  await syncNow();  // 1. 로그인 직후 즉시 동기화

  _periodicTimer = Timer.periodic(
    const Duration(minutes: 15),  // 2. 15분 주기
    (_) => syncNow(),
  );

  _connectivitySub = _connectivity.watchConnectivity().listen((isOnline) {
    if (isOnline) syncNow();  // 3. 네트워크 복원 시
  });
}

// 4. 앱 포그라운드 복귀 시 (AppLifecycleState.resumed)
```

`_isSyncing` 플래그로 중복 실행을 방지하고, 오프라인이면 즉시 반환한다.

## 배운 점

- **Repository 인터페이스의 가치는 시간이 지나야 증명된다.** v1.0에서 "과설계"로 보일 수 있었던 인터페이스 분리가 v2.0에서 UI 코드 변경 없이 동기화를 추가할 수 있게 했다.
- **Push → Pull 순서와 FK 의존 순서는 동기화의 기본이다.** 순서가 틀리면 데이터 유실이나 FK 위반이 발생한다.
- **Decorator 패턴은 관심사 분리의 실전적 방법이다.** 기존 클래스를 수정하지 않고 새로운 동작(동기화 트리거)을 추가할 수 있다. `unawaited()`로 fire-and-forget하면 사용자 경험에 영향을 주지 않는다.
