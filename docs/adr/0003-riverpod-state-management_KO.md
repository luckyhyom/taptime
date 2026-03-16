<!-- translated from: docs/adr/0003-riverpod-state-management.md @ commit c197f75 (2026-03-17) -->

# ADR-0003: 상태 관리에 Riverpod

- **상태:** 승인됨
- **날짜:** 2026-03-14

## 맥락

Flutter는 여러 상태 관리 솔루션을 제공합니다. 소~중 규모 앱을 만드는 1인 개발자에게 맞는 것을 선택해야 했습니다.

## 검토한 옵션

| 옵션 | 장점 | 단점 |
|------|------|------|
| Riverpod | 타입 안전, 컴파일 타임 체크, BuildContext 의존 없음, 우수한 테스팅, 적은 보일러플레이트 | 초기 학습 곡선이 가파름 |
| BLoC/Cubit | 성숙, 예측 가능, 엄격한 패턴 | 보일러플레이트 과다 (기능당 Event + State + BLoC), 이 규모에 과잉 |
| Provider | 단순, Flutter 공식 권장 | 타입 안전성 부족, context 의존적, Riverpod에 의해 대체되는 중 |
| GetX | 최소 보일러플레이트 | 테스트 가능성 낮음, 암묵적 매직, 커뮤니티 비추천 |

## 결정

Riverpod (최신 안정 버전).

## 근거

- 1인 개발자에게 BLoC보다 적은 보일러플레이트
- 타입 안전 프로바이더가 컴파일 타임에 에러 포착
- BuildContext 의존 없음 — 위젯 트리 없이 로직 테스트 가능
- 의존성 주입에 자연스러운 적합 (repository 인터페이스 → 구현체)
- Riverpod 3.0 (2025년 9월)으로 활발한 개발 중

## 결과

- Riverpod의 프로바이더 모델 학습 필요 (Provider, StateNotifier, AsyncValue)
- 보일러플레이트 감소를 위해 `riverpod_generator` 코드 생성 권장
- 모든 기능에서 일관된 상태 관리
