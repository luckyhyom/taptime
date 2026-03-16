<!-- translated from: docs/guides/SETUP.md @ commit c197f75 (2026-03-17) -->

# 개발 환경 설정

> Taptime 개발 환경을 처음부터 설정하는 가이드.
> **플랫폼:** macOS (Apple Silicon / Intel)

## 사전 요구사항

- macOS 14+ (Sonoma 이상 권장)
- [Homebrew](https://brew.sh/) 설치됨
- Apple ID (Xcode용)

## 1. Flutter SDK 설치

```bash
brew install --cask flutter
```

설치 확인:

```bash
flutter --version
# 예상: Flutter 3.41.x (stable channel)
```

## 2. iOS 개발 설정

### 2.1 Xcode 설치

1. **App Store** 열기 → "Xcode" 검색 → 설치
2. 설치 후 실행:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

3. 라이선스 동의:

```bash
sudo xcodebuild -license accept
```

### 2.2 CocoaPods 설치

```bash
brew install cocoapods
```

### 2.3 iOS 시뮬레이터 설정

```bash
# 시뮬레이터 열기
open -a Simulator
```

또는 Xcode에서: **Xcode → Settings → Platforms → iOS → Download**로 시뮬레이터 런타임을 다운로드.

## 3. Android 개발 설정 (선택사항)

> Android 설정은 후순위로 미룰 수 있습니다. 초기 개발은 iOS 시뮬레이터로 충분합니다.

### 3.1 Android Studio 설치

```bash
brew install --cask android-studio
```

### 3.2 필수 SDK 컴포넌트 설치

1. Android Studio 열기 → **Settings → SDK Manager**
2. 설치:
   - **Android SDK 36** (API level 36)
   - **Android SDK Build-Tools 28.0.3**
   - **Android SDK Command-line Tools**

### 3.3 라이선스 동의

```bash
flutter doctor --android-licenses
```

### 3.4 Android 에뮬레이터 설정

1. Android Studio → **Device Manager → Create Virtual Device**
2. 기기 선택 (예: Pixel 8) 후 시스템 이미지 다운로드

## 4. 환경 확인

```bash
flutter doctor
```

모든 항목이 `[✓]`로 표시되어야 합니다. 예시 출력:

```
[✓] Flutter (Channel stable, 3.41.x)
[✓] Android toolchain
[✓] Xcode
[✓] Chrome - develop for the web
[✓] Connected device
[✓] Network resources
```

## 5. 클론 및 실행

```bash
git clone https://github.com/luckyhyom/taptime.git
cd taptime
flutter pub get
flutter run
```

### 특정 플랫폼에서 실행

```bash
# iOS 시뮬레이터
flutter run -d iphone

# Android 에뮬레이터
flutter run -d android

# Chrome (웹)
flutter run -d chrome
```

## 문제 해결

### CocoaPods 문제

```bash
# pod install 실패 시
cd ios
pod repo update
pod install
cd ..
```

### Flutter 캐시 문제

```bash
flutter clean
flutter pub get
```

### Xcode 서명 오류

`ios/Runner.xcworkspace`를 Xcode에서 열기 → **Runner → Signing & Capabilities** → 개발 팀 선택.
