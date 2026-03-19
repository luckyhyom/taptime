import 'package:flutter/foundation.dart';

import 'package:taptime/core/utils/enum_utils.dart';

/// 세션(타이머 기록) 상태.
///
/// 타이머가 끝까지 돌았으면 completed,
/// 사용자가 중간에 멈추면 stopped.
enum SessionStatus { completed, stopped }

/// 세션(타이머 기록) 모델.
///
/// 타이머를 한 번 실행하면 하나의 Session이 생성된다.
/// 시작/종료 시각, 실제 소요 시간, 상태 등을 기록한다.
///
/// Preset과 마찬가지로 Drift와 독립된 순수 Dart 클래스이다.
@immutable
class Session {
  Session({
    required this.id,
    required this.presetId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.status,
    required this.createdAt,
    this.memo,
  })  : assert(durationSeconds >= 0, 'durationSeconds must be >= 0'),
        assert(!endedAt.isBefore(startedAt), 'endedAt must not be before startedAt');

  /// Map에서 Session 인스턴스를 생성한다.
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      presetId: map['presetId'] as String,
      startedAt: _parseDateTime(map['startedAt']),
      endedAt: _parseDateTime(map['endedAt']),
      durationSeconds: map['durationSeconds'] as int,
      status: safeEnumByName(SessionStatus.values, map['status'] as String?) ?? SessionStatus.completed,
      memo: map['memo'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  /// UUID v4
  final String id;

  /// 이 세션이 속한 프리셋의 id (외래키 역할)
  final String presetId;

  /// 타이머 시작 시각
  final DateTime startedAt;

  /// 타이머 종료 시각
  final DateTime endedAt;

  /// 실제 소요 시간 (초 단위).
  /// endedAt - startedAt과 다를 수 있다 (일시정지 시간 제외).
  final int durationSeconds;

  /// 완료(completed) 또는 중단(stopped)
  final SessionStatus status;

  /// 세션 후 사용자가 남기는 메모 (선택)
  final String? memo;

  final DateTime createdAt;

  Session copyWith({DateTime? endedAt, int? durationSeconds, SessionStatus? status, String? memo}) {
    return Session(
      id: id,
      presetId: presetId,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt,
    );
  }

  /// 메모를 명시적으로 null로 설정한 새 인스턴스를 반환한다.
  ///
  /// copyWith(memo: null)은 "변경 없음"으로 처리되므로
  /// 메모를 삭제할 때는 이 메서드를 사용해야 한다.
  Session clearMemo() {
    return Session(
      id: id,
      presetId: presetId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      status: status,
      createdAt: createdAt,
    );
  }

  /// id 기반 동등성
  @override
  bool operator ==(Object other) => other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;

  /// JSON 직렬화용 Map으로 변환한다.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'presetId': presetId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'status': status.name,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Session(id: $id, presetId: $presetId, status: $status)';
}
