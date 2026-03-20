<!-- translated from: docs/guides/SETUP.md @ commit 79a4a15 (2026-03-19) -->

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
```

### iOS 시뮬레이터에서 실행 (개발 권장)

Apple Developer 계정이나 코드 서명 없이 실행할 수 있습니다.

```bash
# 1. 시뮬레이터 부팅
xcrun simctl list devices available | grep iPhone   # 사용 가능한 시뮬레이터 목록
xcrun simctl boot "iPhone 17"                       # 이름으로 부팅
open -a Simulator                                   # Simulator 앱 열기

# 2. 앱 실행
flutter run -d "iPhone 17"        # 이름으로 지정
# 또는
flutter run                       # 부팅된 시뮬레이터 자동 선택
```

### 실제 iOS 기기에서 실행

Apple Developer 계정과 코드 서명 설정이 필요합니다.

1. Xcode에서 `ios/Runner.xcworkspace` 열기
2. **Runner** 타깃 → **Signing & Capabilities** → **Team** 설정
3. 유효한 **Bundle ID** 확인
4. 기기에서 인증서 신뢰: **Settings → General → Device Management**
5. 실행:

```bash
flutter run -d "iPhone"           # 연결된 기기를 자동 선택
```

### 다른 플랫폼에서 실행

```bash
# Android 에뮬레이터
flutter run -d android

# Chrome (웹)
flutter run -d chrome

# macOS (데스크톱)
flutter run -d macos
```

### 유용한 실행 명령

```bash
flutter devices                   # 연결된 모든 기기 목록
flutter run --release             # release 모드 (debug banner 없음)
flutter run --hot                 # hot reload 활성화 (debug 기본값)
```

## 문제 해결

### 실제 기기: "No valid code signing certificates"

Xcode에서 코드 서명을 설정해야 합니다. 위의 [실제 iOS 기기에서 실행](#실제-ios-기기에서-실행) 섹션을 참고하세요.

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

`ios/Runner.xcworkspace`를 Xcode에서 열고 **Runner → Signing & Capabilities**에서 개발 팀을 선택하세요.
