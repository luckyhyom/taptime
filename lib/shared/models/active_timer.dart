import 'package:flutter/foundation.dart';

/// 현재 실행 중인 타이머의 상태를 나타내는 모델.
///
/// 앱이 크래시되거나 예기치 않게 종료되었을 때
/// 타이머 상태를 복구하기 위해 DB에 저장한다.
///
/// 단일행 패턴(singleton pattern)을 사용하여
/// 테이블에 항상 0개 또는 1개의 행만 존재한다.
/// 타이머가 실행 중이면 1개, 아니면 0개.
@immutable
class ActiveTimer {
  const ActiveTimer({
    required this.id,
    required this.presetId,
    required this.startedAt,
    required this.pausedDurationSeconds,
    required this.isPaused,
    required this.remainingSeconds,
    required this.createdAt,
    this.pausedAt,
  })  : assert(remainingSeconds >= 0, 'remainingSeconds must be >= 0'),
        assert(pausedDurationSeconds >= 0, 'pausedDurationSeconds must be >= 0'),
        assert(!isPaused || pausedAt != null, 'pausedAt required when isPaused');

  /// Map에서 ActiveTimer 인스턴스를 생성한다.
  factory ActiveTimer.fromMap(Map<String, dynamic> map) {
    return ActiveTimer(
      id: map['id'] as String,
      presetId: map['presetId'] as String,
      startedAt: _parseDateTime(map['startedAt']),
      pausedDurationSeconds: map['pausedDurationSeconds'] as int,
      isPaused: map['isPaused'] as bool,
      pausedAt: map['pausedAt'] == null ? null : _parseDateTime(map['pausedAt']),
      remainingSeconds: map['remainingSeconds'] as int,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  /// 항상 'singleton' — 테이블에 하나의 행만 존재하도록 한다.
  final String id;

  /// 이 타이머가 속한 프리셋의 id (외래키 역할)
  final String presetId;

  /// 타이머가 최초로 시작된 시각
  final DateTime startedAt;

  /// 지금까지 누적된 일시정지 시간 (초 단위).
  /// resume할 때마다 (resumeTime - pausedAt) 만큼 더한다.
  final int pausedDurationSeconds;

  /// 현재 일시정지 상태인지 여부
  final bool isPaused;

  /// 현재 일시정지가 시작된 시각.
  /// 타이머가 running 상태이면 null.
  final DateTime? pausedAt;

  /// 마지막으로 DB에 저장한 시점의 남은 시간 (초 단위).
  /// 크래시 복구 시 이 값과 경과 시간을 비교하여
  /// 타이머를 이어서 진행하거나 자동 완료 처리한다.
  final int remainingSeconds;

  /// 이 행이 처음 생성된 시각
  final DateTime createdAt;

  /// 단일행 패턴에 사용하는 고정 id 값
  static const singletonId = 'singleton';

  ActiveTimer copyWith({int? pausedDurationSeconds, bool? isPaused, DateTime? pausedAt, int? remainingSeconds}) {
    return ActiveTimer(
      id: id,
      presetId: presetId,
      startedAt: startedAt,
      pausedDurationSeconds: pausedDurationSeconds ?? this.pausedDurationSeconds,
      isPaused: isPaused ?? this.isPaused,
      // pausedAt는 null로 설정할 수 있어야 하므로 별도 처리하지 않는다.
      // clearPausedAt()를 사용하여 명시적으로 null로 설정.
      pausedAt: pausedAt ?? this.pausedAt,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      createdAt: createdAt,
    );
  }

  /// pausedAt를 null로 설정한 새 인스턴스를 반환한다.
  /// copyWith에서 null 전달이 "변경 없음"으로 처리되므로
  /// 명시적으로 null로 설정할 때 이 메서드를 사용한다.
  ActiveTimer clearPausedAt() {
    return ActiveTimer(
      id: id,
      presetId: presetId,
      startedAt: startedAt,
      pausedDurationSeconds: pausedDurationSeconds,
      isPaused: isPaused,
      remainingSeconds: remainingSeconds,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is ActiveTimer && other.id == id;

  @override
  int get hashCode => id.hashCode;

  /// JSON 직렬화용 Map으로 변환한다.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'presetId': presetId,
      'startedAt': startedAt.toIso8601String(),
      'pausedDurationSeconds': pausedDurationSeconds,
      'isPaused': isPaused,
      'pausedAt': pausedAt?.toIso8601String(),
      'remainingSeconds': remainingSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ActiveTimer(presetId: $presetId, isPaused: $isPaused, remaining: $remainingSeconds)';
}
