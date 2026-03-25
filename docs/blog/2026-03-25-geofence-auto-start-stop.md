# 위치 기반 타이머 자동 시작/정지: 확인 다이얼로그 없이 바로 동작하게

> 2026-03-25 | Taptime v2.1 Geofence UX 개선

## 배경

기존 구현은 등록된 장소에 도착하면 "타이머를 시작하시겠습니까?" 다이얼로그를 표시했다. 사용자가 알림을 탭하고, 앱을 열고, 다이얼로그에서 "시작"을 눌러야 타이머가 돌아갔다. 3단계나 거쳐야 하는 UX는 "자동 트래킹"이라고 부르기 어려웠다.

또한 장소를 떠나도 타이머가 계속 돌아가서 수동으로 정지해야 했다.

## 변경 내용

### 1. 진입 → 자동 시작

`GeofenceManager._handleEvent()`에서 진입 이벤트를 받으면 바로 타이머 화면으로 이동한다. 확인 다이얼로그와 `autoStart` 분기를 제거했다.

```dart
// Before: autoStart 여부에 따라 분기
if (action.autoStart) {
  appRouter.push(AppRoutes.timerPath(action.presetId));
} else {
  _showConfirmDialog(action);
}

// After: 항상 자동 시작
case GeofenceActionType.start:
  appRouter.push(AppRoutes.timerPath(action.presetId));
```

### 2. 퇴장 → 자동 정지

기존에는 퇴장 이벤트를 무시했다. 이제 `GeofenceAction`에 `type` 필드를 추가하여 진입/퇴장을 구분한다.

```dart
enum GeofenceActionType { start, stop }
```

퇴장 시 현재 실행 중인 타이머가 해당 프리셋이면 타이머 화면으로 이동하여 정지 처리한다.

### 3. 알림 메시지에 프리셋 이름 포함

Swift `GeofencePlugin`에 `presetNames` 딕셔너리를 추가하고, `addRegion` 호출 시 프리셋 이름도 함께 전달한다.

```swift
// Before
content.body = "\(placeName)에 도착했습니다. 타이머를 시작하시겠습니까?"

// After
content.body = "\(presetName) 타이머가 시작되었습니다 (\(placeName))"
```

퇴장 알림도 동일한 포맷:
```
Study 타이머가 종료되었습니다 (도서관)
```

### 4. addRegion 인터페이스 확장

`GeofenceService.addRegion()`에 `presetName` 파라미터를 추가했다. Dart → Swift 전달 경로:

```
GeofenceManager._syncRegions()
  → 프리셋 목록 조회, trigger.id로 매칭
  → geofenceService.addRegion(presetName: preset.name)
    → MethodChannel → Swift addRegion
      → presetNames[id] = presetName
```

## 참고

- [Apple: Monitoring the User's Proximity to Geographic Regions](https://developer.apple.com/documentation/corelocation/monitoring-the-user-s-proximity-to-geographic-regions)
- [Apple: UNNotificationContent](https://developer.apple.com/documentation/usernotifications/unnotificationcontent)
