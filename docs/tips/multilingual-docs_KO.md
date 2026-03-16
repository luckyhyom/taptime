<!-- translated from: docs/tips/multilingual-docs.md @ commit c197f75 (2026-03-17) -->

# 다국어 문서 관리

> 영어 문서의 한국어 번역 관리 베스트 프랙티스.

## 접근 방식

- **방법:** 원본과 같은 디렉터리에 파일 접미사 (`*_KO.md`)
- **정식 출처:** 영어 원본 (에이전트가 읽는 것)
- **한국어 파일:** 사람이 읽기 위한 것 (GitHub, 팀원)
- **에이전트:** `*_KO.md` 파일 무시 — 명시적 요청 없으면 읽거나 수정하지 않을 것

## 번역 추적

각 `_KO.md` 파일 상단에 주석:

```markdown
<!-- translated from: PRD.md @ commit abc1234 (2026-03-15) -->
```

번역이 오래되었는지 확인:

```bash
git log --format="%h %as" -1 -- docs/planning/PRD.md
# PRD_KO.md 헤더의 해시와 비교
```

## 번역 시점

- 번역은 **사용자 요청 시에만** 수행 (일괄 업데이트)
- `/translate-docs` 스킬로 오래된 번역을 일괄 업데이트
- 커밋마다 자동 번역하지 않음 — 토큰 낭비

## 번역 대상

| 번역함 (_KO) | 번역 안 함 |
|---|---|
| README.md | .claude/rules/* |
| CLAUDE.md | .claude/skills/* |
| PLAN.md, PROGRESS.md | .claude/settings.json |
| docs/planning/* | docs/references/* |
| docs/adr/* | docs/issues/* |
| docs/guides/* | docs/conversations/* |
| docs/INDEX.md | |
| docs/tips/* | |

## 조사 근거

주요 오픈소스 프로젝트의 번역 처리 방식 기반:

| 프로젝트 | 방법 |
|---------|------|
| standard.js, node-best-practices | 파일 접미사 (같은 폴더) — 소~중 규모 프로젝트에 적합 |
| Kubernetes | 언어별 하위 폴더 (content/ko/) — 대규모 문서에 적합 |
| React, Vue | 언어별 별도 레포 — 대규모 문서에 적합 |

Taptime은 번역 대상 문서가 20개 미만이므로 파일 접미사 방식 선택.
