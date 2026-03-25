# [BUG] Xcode 26 베타에서 시뮬레이터 빌드가 안 될 때: SUPPORTED_PLATFORMS 디버깅기

> 2026-03-25 | Taptime 개발 환경 트러블슈팅

## 배경

어제까지 정상 동작하던 `flutter run`이 갑자기 실패했다. 에러 메시지:

```
Unable to find a destination matching the provided destination specifier:
    { id:D14349A6-8CB0-4D97-8052-2402F4CBD031 }

Available destinations for the "Runner" scheme:
    { platform:macOS, arch:arm64, variant:Designed for [iPad,iPhone], ... }
    { platform:iOS, arch:arm64, id:..., name:iPhone (64) }
    { platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder, ... }
```

Available destinations에 시뮬레이터가 하나도 없다. 실기기와 Mac만 표시된다.

환경: macOS 26.2 (Tahoe 베타) + Xcode 26.3 베타 + Flutter 3.41.5

## 잘못된 방향으로 간 시간들

처음에는 Xcode 베타 자체의 버그라고 판단했다. 그래서 시도한 것들:

1. `flutter clean && flutter pub get` → 실패
2. `flutter pub cache clean` → 실패
3. `cd ios && pod deintegrate && pod install --repo-update` → 실패
4. `rm -rf ~/Library/Developer/Xcode/DerivedData` → 실패
5. 시뮬레이터 리셋 (`simctl erase`) → 실패
6. Flutter 업그레이드 (3.41.4 → 3.41.5) → 실패
7. Xcode GUI에서 직접 빌드 → `Module 'app_links' not found`

특히 `pod deintegrate`와 `flutter pub cache clean`은 상태를 더 꼬이게 만들었다. Xcode에서 "update to recommended settings"를 클릭한 것도 상황을 악화시켰다. 결과적으로 원래 문제 위에 새로운 문제가 겹쳐졌다.

**교훈: 원인을 모르는 상태에서 캐시를 무작정 지우는 건 위험하다.** 상태를 초기화하는 게 아니라 꼬이게 만들 수 있다.

## 전환점: 에러 메시지를 다시 읽다

한 발 물러서서 에러 메시지를 다시 봤다. 핵심은 **"Available destinations에 시뮬레이터가 없다"**는 것이다.

그런데 `xcodebuild -showdestinations`로 확인하면 시뮬레이터가 12개나 보인다:

```
{ platform:iOS Simulator, arch:arm64, id:D14349A6-..., OS:26.3.1, name:iPhone 17 Pro }
```

보이는데 못 쓴다? 그렇다면 **프로젝트 설정이 시뮬레이터를 허용하지 않는 것**이다.

## 근본 원인

`project.pbxproj`를 확인했다:

```
SUPPORTED_PLATFORMS = iphoneos;
```

`iphoneos`만 있고 `iphonesimulator`가 없다. Xcode는 이 설정을 보고 시뮬레이터를 유효한 destination에서 제외한 것이다.

### 왜 어제는 됐을까?

이 설정은 프로젝트 생성(`flutter create`) 시점부터 `iphoneos`만 들어있었다. 그런데 어제까지는 동작했다.

추정: Xcode의 DerivedData 캐시에 이전 빌드 결과가 남아있어서, `SUPPORTED_PLATFORMS`를 엄격하게 체크하지 않았을 수 있다. 디스크 정리로 캐시가 삭제되면서 Xcode가 프로젝트 설정을 처음부터 다시 읽었고, 이때 시뮬레이터가 빠진 설정이 적용된 것이다.

Xcode 26 베타가 이전 버전보다 `SUPPORTED_PLATFORMS`를 더 엄격하게 적용할 가능성도 있다.

## 수정

`project.pbxproj`에서 `SUPPORTED_PLATFORMS`에 `iphonesimulator`를 추가했다. 이 설정은 Release(486행)와 Profile(667행) 두 곳에 있다:

```diff
- SUPPORTED_PLATFORMS = iphoneos;
+ SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
```

수정 후 즉시 빌드 성공:

```
✓ Built build/ios/iphonesimulator/Runner.app
```

## Module 'app_links' not found의 정체

디버깅 중 Xcode GUI에서 빌드를 시도했을 때 `Module 'app_links' not found` 에러가 나왔다. 이것은 별개의 문제가 아니라 **같은 원인의 결과**였다.

`xcodebuild`가 시뮬레이터를 destination으로 인정하지 않으니 빌드 자체가 시작되지 않았고, CocoaPods 모듈의 빌드 산출물(`.framework`, `.modulemap`)이 생성되지 않았다. Xcode는 이를 "모듈을 찾을 수 없다"고 보고한 것이다.

즉, 에러의 인과관계:

```
SUPPORTED_PLATFORMS에 iphonesimulator 누락
  → xcodebuild가 시뮬레이터 destination 거부
    → Pods 모듈 빌드 스킵
      → Module 'app_links' not found
```

## 얻은 교훈

### 1. 캐시 삭제는 최후의 수단

`flutter clean`, `pod deintegrate`, `pub cache clean`은 문제를 해결할 수도 있지만, 상태를 더 꼬이게 만들 수도 있다. 특히 여러 캐시를 한꺼번에 지우면 원래 문제와 새 문제를 구분하기 어려워진다.

### 2. Xcode의 "update to recommended settings"는 신중하게

Xcode가 권장 설정 업데이트를 제안할 때, 특히 CocoaPods의 Pods 프로젝트에 대해서는 함부로 적용하지 말 것. CocoaPods가 관리하는 설정을 Xcode가 덮어쓰면 빌드가 깨질 수 있다.

### 3. 에러 메시지의 계층을 파악하라

`Module not found`는 표면적 에러였고, 진짜 문제는 destination 매칭 실패였다. 에러가 여러 개일 때 가장 먼저 발생하는 에러(root cause)를 찾아야 한다.

### 4. "어제는 됐는데"는 강력한 단서

환경이 바뀐 시점을 특정하는 게 디버깅의 핵심이다. 이번 경우 디스크 정리가 트리거였고, 그로 인해 DerivedData 캐시가 삭제되면서 숨겨져 있던 설정 문제가 드러났다.
