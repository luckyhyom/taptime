import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// 네트워크 연결 상태를 감시한다.
///
/// 오프라인에서 온라인으로 전환될 때 동기화를 트리거하기 위해 사용한다.
/// connectivity_plus 패키지를 래핑하여 테스트 시 교체 가능하게 한다.
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// 현재 온라인 상태인지 확인한다.
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  /// 연결 상태 변경을 스트림으로 관찰한다.
  /// true = 온라인, false = 오프라인.
  Stream<bool> watchConnectivity() {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile || r == ConnectivityResult.ethernet,
    );
  }
}
