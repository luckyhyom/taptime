import 'package:flutter/foundation.dart';

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
  const Session({
    required this.id,
    required this.presetId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.status,
    required this.createdAt,
    this.memo,
  });

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

  /// id 기반 동등성
  @override
  bool operator ==(Object other) => other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Session(id: $id, presetId: $presetId, status: $status)';
}
