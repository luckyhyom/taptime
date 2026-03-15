# CocoaPods

iOS/macOS native library dependency manager.

## What it does

Flutter plugins that use native features (camera, notifications, vibration, etc.) require Swift/Objective-C libraries under the hood. CocoaPods automatically downloads and links these libraries.

```
Flutter plugin (Dart)
    ↓
CocoaPods links
    ↓
iOS native library (Swift/ObjC)
```

## In Taptime

Plugins like `flutter_local_notifications`, `vibration`, `audioplayers` use CocoaPods to connect to native iOS code during build.

## Usage

Rarely manual. Runs automatically during `flutter run` or `flutter build ios`. If issues arise:

```bash
cd ios
pod repo update
pod install
cd ..
```
