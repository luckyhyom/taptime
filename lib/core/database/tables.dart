import 'package:drift/drift.dart';

// ────────────────────────────────────────────────────────────────
// Drift 테이블 정의
//
// 이 파일은 SQLite 테이블의 스키마를 Dart 코드로 정의한다.
// Drift의 코드 제너레이터(build_runner)가 이 정의를 읽고
// 타입 안전한 쿼리 코드를 자동 생성한다.
//
// 중요: 여기서 정의한 클래스명(Presets, Sessions 등)과
// 공유 모델(Preset, Session 등)의 이름이 충돌하지 않도록
// @DataClassName 어노테이션으로 생성되는 행 클래스 이름을
// PresetRow, SessionRow 등으로 지정한다.
//
// 각 컬럼 정의는 반드시 ()()로 끝나야 한다.
// 첫 번째 ()는 컬럼 빌더를 생성하고, 두 번째 ()는 빌더를 확정한다.
// ────────────────────────────────────────────────────────────────

/// 프리셋 테이블 — 사용자가 만든 활동 템플릿을 저장한다.
@DataClassName('PresetRow')
class Presets extends Table {
  // UUID v4 문자열을 기본키로 사용한다.
  // auto-increment 대신 UUID를 쓰는 이유:
  // 나중에 클라우드 동기화 시 기기 간 id 충돌을 방지하기 위해서다.
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 20)();

  /// 타이머 시간 (분 단위)
  IntColumn get durationMin => integer()();

  /// 아이콘 식별자 (예: 'menu_book') — AppConstants.presetIcons의 키
  TextColumn get icon => text()();

  /// 색상 hex 문자열 (예: '#4A90D9')
  TextColumn get color => text()();

  /// 일일 목표 시간 (분 단위, 0이면 목표 없음)
  IntColumn get dailyGoalMin => integer().withDefault(const Constant(0))();

  /// 홈 화면 그리드에서의 정렬 순서
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// clientDefault: Dart 코드에서 기본값을 제공한다.
  /// withDefault(SQL 레벨)과 달리 기존 테이블에 컬럼을 추가할 때
  /// 마이그레이션이 필요 없다는 장점이 있다.
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 세션 테이블 — 타이머 실행 기록을 저장한다.
///
/// presetId로 프리셋과 연결되며,
/// startedAt에 인덱스를 걸어 날짜별 조회 성능을 최적화한다.
/// 복합 인덱스(presetId + startedAt)는 프리셋별 날짜 범위 조회를
/// 최적화한다 (홈 화면의 프리셋별 진행률 등).
@DataClassName('SessionRow')
@TableIndex(name: 'idx_sessions_preset_id', columns: {#presetId})
@TableIndex(name: 'idx_sessions_started_at', columns: {#startedAt})
@TableIndex(name: 'idx_sessions_preset_started', columns: {#presetId, #startedAt})
class Sessions extends Table {
  TextColumn get id => text()();

  /// 외래키: 이 세션이 속한 프리셋의 id.
  /// references()로 외래키 관계를 선언한다.
  /// onDelete: KeyAction.cascade → 프리셋 삭제 시 관련 세션도 함께 삭제된다.
  TextColumn get presetId => text().references(Presets, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();

  /// 실제 소요 시간 (초 단위)
  IntColumn get durationSeconds => integer()();

  /// 'completed' 또는 'stopped' — SessionStatus enum과 대응
  TextColumn get status => text()();

  /// 선택적 메모
  TextColumn get memo => text().nullable()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 사용자 설정 테이블 — 앱 설정을 단일 행으로 저장한다.
///
/// 단일행 패턴: id를 항상 1로 고정하여
/// 테이블에 하나의 행만 존재하도록 한다.
/// 조회 시 WHERE id = 1, 저장 시 INSERT OR REPLACE.
@DataClassName('UserSettingsRow')
class UserSettingsTable extends Table {
  // id를 1로 고정하여 단일행 패턴을 구현한다.
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// 'light', 'dark', 'system' 중 하나
  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  BoolColumn get soundEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get vibrationEnabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Drift는 기본적으로 클래스 이름을 테이블 이름으로 사용한다.
  // UserSettingsTable → user_settings_table이 되는 걸 방지하기 위해
  // 명시적으로 테이블 이름을 지정한다.
  @override
  String get tableName => 'user_settings';
}

/// 활성 타이머 테이블 — 현재 실행 중인 타이머 상태를 저장한다.
///
/// 단일행 패턴: id를 항상 'singleton'으로 고정하여
/// 테이블에 0개 또는 1개의 행만 존재하도록 한다.
/// 앱 크래시 후 복구할 때 이 데이터로 타이머를 이어서 진행한다.
@DataClassName('ActiveTimerRow')
class ActiveTimers extends Table {
  /// 항상 'singleton' — 단일행 패턴
  TextColumn get id => text()();

  /// 외래키: 이 타이머가 실행 중인 프리셋의 id.
  /// 프리셋이 삭제되면 활성 타이머도 함께 삭제된다.
  TextColumn get presetId => text().references(Presets, #id, onDelete: KeyAction.cascade)();

  /// 타이머가 최초로 시작된 시각
  DateTimeColumn get startedAt => dateTime()();

  /// 지금까지 누적된 일시정지 시간 (초 단위)
  IntColumn get pausedDurationSeconds => integer().withDefault(const Constant(0))();

  /// 현재 일시정지 상태인지 여부
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();

  /// 현재 일시정지가 시작된 시각 (running이면 null)
  DateTimeColumn get pausedAt => dateTime().nullable()();

  /// 마지막 저장 시점의 남은 시간 (초 단위)
  IntColumn get remainingSeconds => integer()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
