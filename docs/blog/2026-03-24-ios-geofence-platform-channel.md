# Flutter에서 iOS 지오펜스 구현하기: Platform Channel과 CLLocationManager

> 2026-03-24 | Taptime v2.1 Phase A-C

## 배경

v2.1의 목표는 "등록된 장소에 도착하면 자동으로 타이머 시작을 제안"하는 것이다. 이를 위해 iOS의 지오펜스(geofence) API인 `CLLocationManager`의 Region Monitoring을 사용해야 한다. Flutter에는 이 기능을 직접 호출하는 API가 없으므로 Platform Channel로 Dart ↔ Swift 통신을 구현했다.

## 핵심 결정

### 1. 서드파티 플러그인 대신 직접 Platform Channel

`geofencing_flutter` 같은 플러그인이 있지만, 직접 구현을 선택했다:

- API 표면이 작다: 영역 등록/제거, 모니터링 시작/중지, 권한 요청 — 메서드 5~6개
- v2.1은 iOS 전용이라 크로스 플랫폼 플러그인의 장점이 없다
- 알림을 Flutter가 아닌 Swift 네이티브에서 직접 보내야 한다 (핵심 이유)

마지막 이유가 가장 중요하다. 지오펜스 이벤트는 앱이 백그라운드일 때, 심지어 Flutter 엔진이 초기화되지 않은 상태에서도 발생할 수 있다. Flutter의 `flutter_local_notifications`로는 이 시점에 알림을 보낼 수 없다. Swift의 `UNUserNotificationCenter`는 네이티브 레벨에서 즉시 알림을 보낼 수 있다.

### 2. Dart 인터페이스: 기존 패턴 재사용

`GeofenceService` 인터페이스를 `shared/services/`에 정의했다. 이미 같은 위치에 `AuthService`, `SyncService`가 있으므로 일관된 패턴이다:

```dart
// lib/shared/services/geofence_service.dart

abstract class GeofenceService {
  Future<void> startMonitoring();
  Future<void> stopMonitoring();

  Future<void> addRegion({
    required String id,
    required String placeName,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required bool notifyOnEntry,
    required bool notifyOnExit,
  });

  Future<void> removeRegion(String id);
  Stream<GeofenceEvent> watchEvents();
  Future<GeofencePermissionStatus> requestPermission();
  Future<GeofencePermissionStatus> checkPermission();
}
```

비iOS 플랫폼에서는 `NoopGeofenceService`가 모든 메서드를 no-op으로 구현한다:

```dart
// Provider에서 플랫폼 분기
final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  if (Platform.isIOS) {
    return GeofenceServiceImpl();  // MethodChannel 기반
  }
  return NoopGeofenceService();    // Android, Web 등
});
```

### 3. Swift 네이티브: 알림은 반드시 네이티브에서

`GeofencePlugin.swift`의 핵심 설계 결정:

```swift
// ios/Runner/GeofencePlugin.swift

func locationManager(_ manager: CLLocationManager,
                     didEnterRegion region: CLRegion) {
    // 1. Dart에 이벤트 전달 (앱이 foreground일 때)
    channel.invokeMethod("onRegionEntered",
                         arguments: ["regionId": region.identifier])

    // 2. 네이티브 알림 직접 발송 (앱이 background여도 동작)
    showLocalNotification(regionId: region.identifier,
                          eventType: .entered)
}
```

`channel.invokeMethod`와 `showLocalNotification`을 모두 호출한다. Foreground에서는 Dart가 이벤트를 받아 UI를 갱신하고, Background에서는 네이티브 알림이 사용자에게 장소 도착을 알린다. 두 경로가 독립적이므로 어느 상태에서든 동작한다.

### 4. 20개 영역 제한 — iOS 하드웨어 제약

`CLLocationManager`는 동시에 최대 20개 `CLCircularRegion`만 모니터링할 수 있다. 이것은 iOS의 하드웨어 제약이므로 우회할 수 없다:

```swift
func handleAddRegion(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if locationManager.monitoredRegions.count >= 20 {
        result(FlutterError(code: "LIMIT_EXCEEDED",
                           message: "Maximum 20 regions",
                           details: nil))
        return
    }

    let region = CLCircularRegion(
        center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
        radius: CLLocationDistance(radiusMeters),
        identifier: id
    )
    region.notifyOnEntry = notifyOnEntry
    region.notifyOnExit = notifyOnExit

    placeNames[id] = placeName
    locationManager.startMonitoring(for: region)
    result(nil)
}
```

`placeNames` 딕셔너리를 Swift 메모리에 유지하는 이유: `CLCircularRegion`에는 identifier만 있고 place name을 저장할 필드가 없다. 알림에 "헬스장에 도착했습니다"처럼 장소 이름을 표시하려면 별도로 관리해야 한다. 앱 재시작 시 Phase D의 `GeofenceManager`가 DB에서 읽어 다시 등록한다.

### 5. 데이터 레이어: LocationTrigger와 Preset의 관계

`LocationTrigger`는 "장소"를 나타내고, `Preset`이 이를 참조한다. 1:N 관계가 아닌 1:1을 선택했다:

```dart
// Preset 모델에 FK 추가
class Preset {
  final String? locationTriggerId;  // nullable — 위치 트리거 없는 프리셋 허용

  Preset clearLocationTrigger() => Preset(
    // ... 모든 필드 복사, locationTriggerId만 null로
  );
}
```

DB 스키마에서 `onDelete: setNull`을 사용한다. 위치 트리거를 삭제하면 해당 프리셋의 `locationTriggerId`가 자동으로 null이 된다. CASCADE DELETE가 아니라 SET NULL인 이유: 프리셋 자체는 유지하되 위치 연결만 끊어야 하기 때문이다.

동기화도 FK 순서를 지킨다: `location_triggers → presets → sessions`. v2.0에서 확립한 패턴과 동일하다.

## 코드 워크스루: 지도 피커와 프리셋 폼 연동

장소 등록 UI는 `LocationPickerScreen`(FlutterMap 기반)과 `PresetFormScreen`이 데이터를 교환하는 구조다. GoRouter의 push/pop으로 결과를 전달한다:

```dart
// 프리셋 폼 → 지도 피커로 이동
onTap: () async {
  final triggerId = await context.push<String>('/location-picker');
  if (triggerId != null) {
    // 돌아온 triggerId로 폼 상태 업데이트
    ref.read(presetFormProvider.notifier)
       .setLocationTrigger(triggerId, triggerName);
  }
}

// 지도 피커에서 저장 후 → 프리셋 폼으로 복귀
onSave: (trigger) {
  await locationTriggerRepo.createLocationTrigger(trigger);
  context.pop(trigger.id);  // triggerId를 결과로 반환
}
```

이 패턴의 장점: 두 화면이 서로의 상태를 직접 참조하지 않는다. `push<String>`의 반환값이 유일한 통신 채널이다.

## 배운 점

- **Platform Channel의 API 표면이 작으면 Pigeon보다 MethodChannel이 적합하다.** 메서드 5~6개에 코드 제너레이션 도구를 도입하면 오히려 복잡해진다.
- **백그라운드 이벤트의 알림은 네이티브에서 보내야 한다.** Flutter 엔진이 초기화되지 않은 상태를 대비해야 한다.
- **하드웨어 제약은 우회가 아니라 설계에 반영해야 한다.** 20개 영역 제한은 UI에서 명확히 보여주고, 초과 시 등록을 거부하는 것이 올바른 처리다.
