<!-- translated from: PLAN.md @ commit a99674a (2026-03-19) -->

# Taptime - 계획

> **해야 할 일.** 마일스톤, 태스크, 우선순위.
> 에이전트: 어떤 작업이 있고 다음에 무엇을 해야 하는지 파악하기 위해 이 파일을 먼저 읽으세요.

## Phase 0: 기획 & 디자인

- [x] 제품 컨셉 및 기능 브레인스토밍
- [x] 경쟁 분석
- [x] 기술 스택 선정
- [x] PRD (`docs/PRD.md`)
- [x] MVP 범위 정의 (`docs/MVP_SPEC.md`)
- [x] 아키텍처 설계
- [x] 디자인 시스템 조사
- [x] 참고 자료 정리
- [x] 시스템 설계 논의 및 확정
- [x] 스킬 및 훅 설정 (`.claude/skills/`, `.claude/settings.json`)

## Phase 1: 기반 구축

- [x] Flutter 프로젝트 초기화 (`flutter create`)
- [x] 폴더 구조 설정 (기능 우선)
- [x] 테마 설정 (라이트/다크, 컬러 팔레트, 타이포그래피)
- [x] GoRouter 라우팅 설정 (홈, 타이머, 프리셋 폼, 히스토리, 통계, 설정)
- [x] Drift DB 스키마 정의 (Preset, Session, UserSettings, ActiveTimers)
- [x] Repository 인터페이스 (shared layer)
- [x] 로컬 Repository 구현체 (data layer)
- [x] Auth/Calendar 서비스 인터페이스 + no-op 구현체
- [x] 데이터 레이어 설계 리뷰 — 8개 격차 수정 (`docs/issues/FEAT-001_data-layer-review.md`)
- [x] Riverpod 프로바이더 설정
- [x] 설계 완성도 리뷰 — 안전한 enum 파싱, 모델 validation, error hierarchy, toMap/fromMap serialization, migration scaffold, architecture rules, ADR-0008 notifier pattern, model + repository tests

## Phase 2: 프리셋

- [ ] 홈 화면 프리셋 그리드 (2열)
- [ ] 프리셋 카드 위젯 (아이콘, 이름, 시간, 일일 진행률)
- [ ] 첫 실행 시 기본 프리셋 (공부, 운동, 독서)
- [ ] 프리셋 생성 화면 (이름, 시간, 아이콘, 색상, 일일 목표)
- [ ] 프리셋 수정 화면
- [ ] 프리셋 삭제 (확인 대화상자 포함)
- [ ] 프리셋 재정렬 (드래그 앤 드롭)

## Phase 3: 타이머

- [ ] 타이머 화면 UI (카운트다운, 진행 링, 컨트롤)
- [ ] 카운트다운 타이머 로직 (시작, 일시정지, 재개, 정지)
- [ ] 백그라운드 타이머 지원
- [ ] 타이머 상태 영속화 (충돌 복구)
- [ ] 완료 시 세션 자동 저장
- [ ] 수동 정지 시 세션 저장 (확인 대화상자 포함)
- [ ] 완료 시 알림음 + 진동

## Phase 4: 히스토리

- [ ] 세션 기록 화면 (날짜별 그룹)
- [ ] 세션 리스트 타일 (아이콘, 이름, 시간 범위, 소요 시간, 상태)
- [ ] 세션 메모 편집
- [ ] 세션 삭제

## Phase 5: 통계

- [ ] 통계 화면 탭 레이아웃 (오늘 / 주간)
- [ ] 오늘: 총 시간, 프리셋별 막대 차트, 목표 진행률 바
- [ ] 주간: 일별 총 시간 막대 차트, 카테고리 도넛 차트
- [ ] 날짜 네비게이션 (이전/다음)

## Phase 6: 설정

- [ ] 설정 화면
- [ ] 테마 토글 (라이트/다크/시스템)
- [ ] 사운드 온/오프
- [ ] 진동 온/오프
- [ ] 모든 데이터 초기화 (확인 대화상자 포함)
- [ ] 앱 버전 표시

## Phase 7: 마무리

- [ ] 예외 케이스 처리 (빈 상태, 에러 상태)
- [ ] 성능 최적화
- [ ] iOS + Android 에뮬레이터 테스트
- [ ] 버그 수정

---

> MVP 이후 기능 → [BACKLOG.md](BACKLOG.md)
