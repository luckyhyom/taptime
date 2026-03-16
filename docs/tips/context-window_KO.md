<!-- translated from: docs/tips/context-window.md @ commit c197f75 (2026-03-17) -->

# /context 해석 가이드

> Claude Code에서 `/context` 명령어로 보이는 정보 해석법

## 실제 출력 예시

```
❯ /context
  ⎿  Context Usage
     ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛁ ⛀ ⛀ ⛁   claude-opus-4-6 · 22k/200k tokens (11%)
     ⛁ ⛁ ⛁ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   Estimated usage by category
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ System prompt: 5.4k tokens (2.7%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ System tools: 8.8k tokens (4.4%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Memory files: 60 tokens (0.0%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Skills: 237 tokens (0.1%)
     ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶ ⛶   ⛁ Messages: 7.6k tokens (3.8%)
     ⛶ ⛶ ⛶ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝   ⛶ Free space: 145k (72.4%)
     ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝ ⛝   ⛝ Autocompact buffer: 33k tokens (16.5%)

     Memory files · /memory
     └ ~/.claude/projects/-Users-hyomin-workspace/memory/MEMORY.md: 60 tokens

     Skills · /skills
```

### 아이콘 범례

- `⛁` (채워진) = 사용 중인 토큰 (System prompt, tools, memory, skills, messages)
- `⛀` (반쯤 채워진) = 부분 사용
- `⛶` (빈) = Free space (사용 가능한 여유 공간)
- `⛝` (빗금) = Autocompact buffer (시스템 예약, 직접 사용 불가)

## 항목별 해석

| 항목 | 예시 값 | 설명 |
|------|--------|------|
| **모델/총 사용량** | `claude-opus-4-6 · 22k/200k (11%)` | 현재 사용 중인 모델과 컨텍스트 윈도우 사용률. 200k가 최대 한도 |
| **System prompt** | 5.4k (2.7%) | Claude Code가 동작하기 위한 기본 지침. 변경 불가. CLAUDE.md, .claude/rules/ 내용도 여기 포함 |
| **System tools** | 8.8k (4.4%) | Read, Write, Edit, Bash 등 사용 가능한 도구 정의. 변경 불가 |
| **Memory files** | 60 (0.0%) | `~/.claude/` 아래 MEMORY.md 등 개인 메모리 파일 |
| **Skills** | 237 (0.1%) | 등록된 스킬(slash command) 정의 |
| **Messages** | 7.6k (3.8%) | **현재까지의 대화 내용.** 대화가 길어질수록 커짐 |
| **Free space** | 145k (72.4%) | 남은 사용 가능 공간. 여기까지가 실제 사용 가능 범위 |
| **Autocompact buffer** | 33k (16.5%) | 자동 압축을 위해 시스템이 예약한 공간. 직접 사용 불가 |

## 알아두면 좋은 것

### 매 요청마다 소비되는 input
```
System prompt + System tools + Memory + Skills + Messages = 총 컨텍스트 (22k)
```
대화가 길어질수록 Messages가 커지고, 총 컨텍스트가 증가한다.

### Messages가 예상보다 작을 때
자동 압축(autocompact)이 이미 발생한 것. 긴 대화를 했는데 Messages가 작다면 초반 대화가 요약되어 줄어든 상태이다. 압축 시 세부 내용이 손실될 수 있다.

### Autocompact buffer
컨텍스트가 가득 차기 전에 이전 메시지를 자동 압축하기 위한 여유 공간. Free space가 부족해지면 이 버퍼를 사용해 오래된 메시지를 압축한다.

### CLAUDE.md와 .claude/rules/가 별도로 안 보이는 이유
System prompt 안에 포함되어 있다. 별도 카테고리로 표시되지 않으므로, rules 파일이 많아지면 System prompt가 커진다는 점을 유의.

## 관련 명령어

| 명령어 | 설명 |
|--------|------|
| `/context` | 현재 컨텍스트 사용량 확인 |
| `/cost` | 현재 세션 총 토큰 사용량과 예상 비용 확인 |
