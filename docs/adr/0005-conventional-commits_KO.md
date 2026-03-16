<!-- translated from: docs/adr/0005-conventional-commits.md @ commit c197f75 (2026-03-17) -->

# ADR-0005: Conventional Commits 표준

- **상태:** 승인됨
- **날짜:** 2026-03-14

## 맥락

자동화 (변경 이력 생성, 시맨틱 버저닝)를 지원하고 사람과 AI 에이전트 모두가 읽을 수 있는 일관된 커밋 메시지 형식이 필요했습니다.

## 검토한 옵션

| 옵션 | 장점 | 단점 |
|------|------|------|
| Conventional Commits | 업계 표준, 기계 파싱 가능, 도구 지원 (commitlint, changelog 생성기) | 규율 필요, 약간 장황 |
| 자유 형식 메시지 | 학습 곡선 없음 | 비일관적, 자동화 불가 |
| Gitmoji | 시각적, 재미있음 | 파싱 어려움, 전문적 환경에서 널리 사용되지 않음 |

## 결정

프로젝트별 스코프가 포함된 Conventional Commits.

## 근거

- 2025-2026년 가장 널리 채택된 표준
- 자동 변경 이력 생성 및 시맨틱 버저닝 가능
- `commitlint_cli` (Dart 패키지)로 pre-commit 훅을 통한 형식 강제
- 스코프가 기능 우선 아키텍처에 매핑 (timer, preset, history, stats, settings)

## 결과

- 모든 기여자 (사람과 AI)가 형식을 따라야 함
- Pre-commit 훅이 비준수 메시지를 거부
- 커밋 히스토리가 유형/스코프별로 검색 및 필터 가능
