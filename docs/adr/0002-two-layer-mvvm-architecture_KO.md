<!-- translated from: docs/adr/0002-two-layer-mvvm-architecture.md @ commit c197f75 (2026-03-17) -->

# ADR-0002: 2레이어 MVVM + Repository 패턴 (풀 Clean Architecture 대신)

- **상태:** 승인됨
- **날짜:** 2026-03-14

## 맥락

앱 아키텍처 수준을 결정해야 했습니다. 정형화된 아키텍처 없음부터 3레이어 풀 Clean Architecture (presentation/domain/data)까지 옵션 범위.

## 검토한 옵션

| 옵션 | 장점 | 단점 |
|------|------|------|
| 풀 Clean Architecture (3레이어) | 최대 분리, 테스트 가능, 교체 가능 | 기능당 8-12개 파일, Use Case가 대부분 패스스루, 1인 개발팀에 과잉 설계 |
| 2레이어 MVVM + Repository | Flutter 공식 권장, 보일러플레이트 적음, 충분한 분리 | 덜 엄격한 경계, 복잡성 증가 시 리팩터링 필요할 수 있음 |
| 정형화된 아키텍처 없음 | 시작이 가장 빠름 | 앱 성장 시 유지보수 불가 |

## 결정

2레이어 (UI + Data) MVVM 패턴 + Repository 인터페이스. 기능 우선 폴더 구조. 복잡성이 요구될 때만 기능별로 Domain 레이어 추가.

## 근거

- Flutter 공식 아키텍처 가이드 (2025)가 2레이어 권장
- 풀 Clean Architecture의 Use Case가 이 앱 복잡도에서는 대부분 패스스루
- 기능 우선 구조로 관련 파일을 한 곳에 모음
- Repository 패턴으로 여전히 인프라 교체 가능 (Isar → Supabase)
- DDD 개념 (Entity, Value Object)을 형식적 DDD 오버헤드 없이 선택적으로 채택

## 결과

- 더 단순한 코드베이스, 더 빠른 개발
- 기능이 복잡해지면 해당 기능 내부에만 domain 하위 레이어 추가 가능
- (필요 시) 팀 온보딩에 더 적은 아키텍처 지식 필요
