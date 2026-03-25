# [BUG] iOS 지오펜스 알림이 뜨지 않는 이유: 알림 권한은 별개다

> 2026-03-25 | Taptime v2.1 Geofence Bug Fix

## 증상

실기기에서 위치 기반 자동 트래킹이 전혀 동작하지 않았다. 등록한 장소에 도착해도:
- 포어그라운드: 아무 반응 없음
- 백그라운드: 알림 없음
- 화면 꺼짐: 알림 없음

## 핵심 원인: 위치 권한 ≠ 알림 권한

iOS에서 **위치 권한**과 **알림 권한**은 완전히 별개의 시스템이다.

```
CLLocationManager.requestAlwaysAuthorization()  → 위치 접근 허용
UNUserNotificationCenter.requestAuthorization() → 알림 표시 허용
```

지오펜스 모니터링(`CLLocationManager`)은 위치 권한만 있으면 동작한다. 진입/퇴장 이벤트는 OS 레벨에서 정상적으로 감지된다. 하지만 사용자에게 알림을 **표시**하려면 `UNUserNotificationCenter`의 알림 권한이 **별도로** 필요하다.

우리 코드에서는:
- 위치 권한: 설정 토글 시 정상 요청 ✓
- 알림 권한: `requestNotificationPermission()` 메서드가 **정의만 되고 호출되지 않음** ✗

```swift
// GeofencePlugin.swift — 정의는 되어있지만...
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(
        options: [.alert, .sound, .badge]
    ) { granted, error in ... }
}

// ...어디에서도 호출되지 않았다
```

결과: 지오펜스 이벤트가 발생해서 `showLocalNotification()`을 호출해도, 알림 권한이 없으니 `UNUserNotificationCenter.add(request)`가 조용히 실패한다. 에러 콜백에 print만 있었으므로 Xcode 콘솔을 보지 않으면 알 수 없었다.

## 수정

### 1. MethodChannel에 알림 권한 요청 추가

```swift
// GeofencePlugin.swift
case "requestNotificationPermission":
    handleRequestNotificationPermission(result: result)
```

기존 orphaned 메서드를 Dart에서 호출 가능하도록 MethodChannel에 연결했다.

### 2. 위치 트래킹 활성화 시 알림 권한도 함께 요청

```dart
// settings_screen.dart
if (status == GeofencePermissionStatus.authorizedAlways) {
  // 알림 권한도 함께 요청
  await geofenceService.requestNotificationPermission();
  await _updateSettings(ref, settings.copyWith(locationTrackingEnabled: true));
}
```

위치 권한 "항상 허용" 승인 후, 알림 권한을 연달아 요청한다. 사용자는 두 번의 시스템 다이얼로그를 보게 된다.

### 3. 에러 핸들러 추가

```dart
// geofence_service_impl.dart
case 'onError':
  final args = (call.arguments as Map).cast<String, dynamic>();
  debugPrint('[GeofenceService] Error: region=${args['regionId']}, message=${args['message']}');
```

기존에 비어있던 `onError` 핸들러에 로깅을 추가했다. 영역 등록 실패, 모니터링 실패 등의 에러를 콘솔에서 확인할 수 있다.

## 교훈

### iOS 권한 시스템은 세분화되어 있다

단일 기능이라도 여러 권한이 필요할 수 있다. 지오펜스 알림의 경우:

| 권한 | API | 역할 |
|------|-----|------|
| 위치 (Always) | `CLLocationManager` | 영역 진입/퇴장 감지 |
| 알림 | `UNUserNotificationCenter` | 사용자에게 알림 표시 |

위치 권한만 있으면 이벤트 **감지**는 되지만, 사용자에게 **보여주는 것**은 알림 권한이 없으면 불가능하다.

### 에러를 삼키지 마라

`UNUserNotificationCenter.add(request)` 실패 시 에러 콜백이 호출되지만, 앱이 크래시하지는 않는다. 이런 "조용한 실패"는 디버깅을 극도로 어렵게 만든다. 최소한 `debugPrint`라도 남겨야 한다.

## 참고 문서

- [Apple: Monitoring the User's Proximity to Geographic Regions](https://developer.apple.com/documentation/corelocation/monitoring-the-user-s-proximity-to-geographic-regions)
- [Apple: UNUserNotificationCenter.requestAuthorization](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/requestauthorization(options:completionhandler:))
- [Apple: CLLocationManager.startMonitoring(for:)](https://developer.apple.com/documentation/corelocation/cllocationmanager/startmonitoring(for:))
- [Apple: Asking Permission to Use Notifications](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications)
