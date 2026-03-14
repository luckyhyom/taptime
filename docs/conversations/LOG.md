# Conversation Log

> Chronological record of discussions and decisions made during development.

---

## [2026-03-14] System Design Kickoff

### User Request (Original)

> 프로젝트를 시작하기에 앞서 시스템 설계를 같이 해봅시다.
> 아래의 내용들을 하나씩 진행합시다. 간단하게 적어놓은 것이기 때문에 대화를 통해 실제 작업을 구체화/보완하며 진행하도록 합시다.
>
> 1. 프로젝트 셋업
>     1. 작업 진행 시 유의미한 최소한의 단위로 커밋을 해야합니다. 커밋 단위와 커밋메시지 룰등 베스트 프랙티스를 찾아 알려주세요.
>     2. 이슈 발생 시 이슈를 기록하고 제가 스터디할 수 있으면 좋겠습니다.
>     3. 코딩 룰이나 린트에 대한 많이 쓰이는 스타일을 적용해주세요.
>     4. 폴더 구조에 대하여 베스트 프렉티스를 적용해주세요. 백엔드는 DDD 아키텍처였으면 좋겠습니다.
>     5. 이외에 필요한 셋업이 있다면 알려주세요.
>     6. 기술적 선택/변경 사항이 있을 때 그 배경과 선택 이유를 기록합시다.
> 2. 작업을 위해 필요한 agent, command, skill, 구조를 조사한 후, 그에 따라 정확한 포맷을 지켜 .claude 하위에 제안한 것들을 만들어주세요.
> 3. 백엔드는 nestjs + sql, 프론트엔드는 flutter 구조입니다. docker를 활용해 어느 기기에서든 실행에 어려움이 없으면 좋겠습니다. 이외에 더 논의할 것이 있으면 알려주세요.

### Discussion

**Architecture decision: No backend server**

- Discussed whether NestJS + SQL backend is needed
- Concluded: over-engineering for personal app. Local DB (Isar) handles the data scale easily
- Backend adds complexity (dual storage, sync, conflict resolution) without proportional value
- Security review: no sensitive data requiring server-side protection. Google Calendar OAuth tokens can be stored securely on-device via `flutter_secure_storage` (Keychain/Keystore)
- Cloud backup: Supabase when needed (post-MVP), not a custom backend
- User accounts: not needed now. Social login (Google/Apple) for backup-only in v2.0

**Scope changes:**

- Removed: team features, rankings, multi-device sync, NestJS, Docker
- Added: heatmap, streaks, data export/import (JSON)
- Final stack: Flutter + Isar (local-only), Supabase later if needed
