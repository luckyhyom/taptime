# Development Environment Setup

> Guide for setting up the Taptime development environment from scratch.
> **Platform:** macOS (Apple Silicon / Intel)

## Prerequisites

- macOS 14+ (Sonoma or later recommended)
- [Homebrew](https://brew.sh/) installed
- Apple ID (for Xcode)

## 1. Install Flutter SDK

```bash
brew install --cask flutter
```

Verify installation:

```bash
flutter --version
# Expected: Flutter 3.41.x (stable channel)
```

## 2. iOS Development Setup

### 2.1 Install Xcode

1. Open **App Store** → search "Xcode" → Install
2. After installation, run:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

3. Accept the license:

```bash
sudo xcodebuild -license accept
```

### 2.2 Install CocoaPods

```bash
brew install cocoapods
```

### 2.3 Set up iOS Simulator

```bash
# Open Simulator
open -a Simulator
```

Or from Xcode: **Xcode → Settings → Platforms → iOS → Download** a simulator runtime if needed.

## 3. Android Development Setup (Optional)

> Android setup can be deferred. iOS simulator is sufficient for initial development.

### 3.1 Install Android Studio

```bash
brew install --cask android-studio
```

### 3.2 Install Required SDK Components

1. Open Android Studio → **Settings → SDK Manager**
2. Install:
   - **Android SDK 36** (API level 36)
   - **Android SDK Build-Tools 28.0.3**
   - **Android SDK Command-line Tools**

### 3.3 Accept Licenses

```bash
flutter doctor --android-licenses
```

### 3.4 Set up Android Emulator

1. Android Studio → **Device Manager → Create Virtual Device**
2. Select a device (e.g., Pixel 8) and download a system image

## 4. Verify Environment

```bash
flutter doctor
```

All items should show `[✓]`. Example output:

```
[✓] Flutter (Channel stable, 3.41.x)
[✓] Android toolchain
[✓] Xcode
[✓] Chrome - develop for the web
[✓] Connected device
[✓] Network resources
```

## 5. Clone and Run

```bash
git clone https://github.com/luckyhyom/taptime.git
cd taptime
flutter pub get
```

### Run on iOS Simulator (recommended for development)

No Apple Developer account or code signing required.

```bash
# 1. Boot a simulator
xcrun simctl list devices available | grep iPhone   # list available simulators
xcrun simctl boot "iPhone 17"                       # boot by name
open -a Simulator                                   # open Simulator app

# 2. Run the app
flutter run -d "iPhone 17"        # by name
# or
flutter run                       # auto-selects the booted simulator
```

### Run on Physical iOS Device

Requires an Apple Developer account with code signing configured.

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities** → set **Team**
3. Ensure a valid **Bundle ID** is set
4. Trust the certificate on device: **Settings → General → Device Management**
5. Run:

```bash
flutter run -d "iPhone"           # auto-selects connected device
```

### Run on Other Platforms

```bash
# Android Emulator
flutter run -d android

# Chrome (web)
flutter run -d chrome

# macOS (desktop)
flutter run -d macos
```

### Useful Run Commands

```bash
flutter devices                   # list all connected devices
flutter run --release             # release mode (no debug banner)
flutter run --hot                 # hot reload enabled (default in debug)
```

## Troubleshooting

### Physical device: "No valid code signing certificates"

You need to set up code signing in Xcode. See [Run on Physical iOS Device](#run-on-physical-ios-device) above.

### CocoaPods issues

```bash
# If pod install fails
cd ios
pod repo update
pod install
cd ..
```

### Flutter cache issues

```bash
flutter clean
flutter pub get
```

### Xcode signing errors

Open `ios/Runner.xcworkspace` in Xcode → **Runner → Signing & Capabilities** → select your development team.
