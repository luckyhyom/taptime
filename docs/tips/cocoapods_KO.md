<!-- translated from: docs/tips/cocoapods.md @ commit c197f75 (2026-03-17) -->

# CocoaPods

iOS/macOS 네이티브 라이브러리 의존성 관리자.

## 하는 일

네이티브 기능 (카메라, 알림, 진동 등)을 사용하는 Flutter 플러그인은 내부적으로 Swift/Objective-C 라이브러리가 필요합니다. CocoaPods가 이러한 라이브러리를 자동으로 다운로드하고 연결합니다.

```
Flutter 플러그인 (Dart)
    ↓
CocoaPods 연결
    ↓
iOS 네이티브 라이브러리 (Swift/ObjC)
```

## Taptime에서

`flutter_local_notifications`, `vibration`, `audioplayers` 같은 플러그인이 빌드 시 CocoaPods를 사용하여 네이티브 iOS 코드에 연결합니다.

## 사용법

수동으로 사용할 일이 거의 없음. `flutter run` 또는 `flutter build ios` 시 자동 실행됩니다. 문제가 발생하면:

```bash
cd ios
pod repo update
pod install
cd ..
```
