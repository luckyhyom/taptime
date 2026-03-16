<!-- translated from: docs/tips/claude-code-plugins.md @ commit c197f75 (2026-03-17) -->

# Claude Code 플러그인 가이드

> Claude Code 프로젝트에 유용한 플러그인 및 선택 추천.

## 추천 플러그인

### Context7 — ★★★★★ (필수)

MCP 서버를 통해 최신 공식 문서를 컨텍스트에 주입.

- **용도:** 버전별 API 문서를 동적으로 가져와 환각 방지
- **장점:** docs-researcher 서브에이전트 사용, 메인 컨텍스트 윈도우 절약
- **설치:** `/plugin marketplace add upstash/context7` → `/plugin install context7-plugin@context7-marketplace`
- **사용:** 라이브러리/API 쿼리 시 자동 트리거, 또는 `/context7:docs [query]`

### Language-Specific LSP — ★★★★★ (타입 언어 필수)

Language Server Protocol을 통한 코드 인텔리전스 (정의 이동, 참조 찾기, 타입 에러 체크).

- **장점:** 정확한 타입 정보로 토큰 절감 + 분석 정확도 향상
- **설치 (TypeScript):** `/plugin install vtsls@claude-code-lsps`
- **설치 (Dart):** Dart SDK 설치 필요

### Feature-Dev — ★★★☆☆ (대규모 기능)

7단계로 전체 기능 개발 라이프사이클을 조율.

- **에이전트:** code-explorer (코드베이스 분석), code-architect (아키텍처 설계), code-reviewer (이슈 식별)
- **사용:** `/feature-dev`가 탐색 → 설계 → 구현 → 리뷰를 안내

### Superpowers — ★★★☆☆ (방법론)

구조화된 소프트웨어 개발 방법론 (TDD, 브레인스토밍, 코드 리뷰).

- **설치:** `/plugin install superpowers@claude-plugins-official`
- **명령:** `/brainstorming`, `/execute-plan`
- **참고:** Claude Code 내장 워크플로우와 일부 겹침

### Claude-MD-Management — ★★☆☆☆ (선택)

CLAUDE.md 품질 감사 및 세션 학습 캡처.

- **사용:** "audit my CLAUDE.md files" 또는 `/revise-claude-md`
- **참고:** 기본 auto-memory 시스템으로 충분할 수 있음

## 개념

### OpenSpec (Spec-Driven Development)

코드 작성 전에 "무엇"과 "어떻게"를 정의하는 프레임워크.

- 변경 건마다 폴더 생성 (제안, 스펙, 설계, 태스크)
- `@/openspec/AGENTS.md`를 단일 진실 출처로
- **사용:** `/opsx:propose "your idea"`
- **적합:** 복잡한 사양 관리가 필요한 팀 프로젝트

### MEMORY.md (Auto-Memory 시스템)

Claude Code의 내장 세션 간 지식 영속화.

- **위치:** `~/.claude/projects/<project>/memory/MEMORY.md`
- **한도:** 200줄 (초과 내용은 로드 안 됨)
- **베스트 프랙티스:** MEMORY.md는 간결한 인덱스로, 세부 내용은 별도 파일
- **명령:** `/memory`

## 선택 가이드

| 시나리오 | 추천 |
|---------|------|
| 1인 개발 (실용적) | Context7 + Language LSP |
| 기능 중심 개발 | Context7 + LSP + Feature-Dev |
| 팀 / 복잡한 프로젝트 | Context7 + LSP + OpenSpec |

## 겹침 주의

- **Superpowers ↔ Feature-Dev:** 둘 다 구조화된 개발 워크플로우 제공. 하나만 선택.
- **Claude-MD-Management ↔ Auto-Memory:** 부분적 겹침. 내장 메모리로 충분한 경우 많음.
