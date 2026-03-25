# [BUG] 로컬 DB 스키마 변경 후 Supabase 동기화 실패: 마이그레이션 불일치

> 2026-03-25 | Taptime 동기화 트러블슈팅

## 증상

프리셋 보관(archive) 기능을 추가한 후, 실기기에서 동기화가 실패했다. 프리셋을 수정하거나 보관해도 클라우드에 반영되지 않았다.

## 원인

로컬 DB(Drift/SQLite)와 원격 DB(Supabase/PostgreSQL)의 스키마가 불일치했다.

| | 로컬 (Drift) | 원격 (Supabase) |
|---|---|---|
| `archived_at` 컬럼 | ✓ 추가됨 (v4 마이그레이션) | ✗ 없음 |

Drift 쪽에서는:
1. `tables.dart`에 `archivedAt` 컬럼 추가
2. `app_database.dart`에서 `schemaVersion` 3 → 4, `onUpgrade`에 `m.addColumn()` 추가
3. `supabase_mappers.dart`에서 `archived_at` 필드를 JSON에 포함

하지만 Supabase 테이블에는 `archived_at` 컬럼이 없었다. 매퍼가 `'archived_at': row.archivedAt?.toUtc().toIso8601String()`를 포함한 JSON을 push하면, Supabase가 알 수 없는 컬럼이라며 거부한 것이다.

## 수정

Supabase SQL 마이그레이션 파일을 추가했다:

```sql
-- supabase/migrations/003_preset_archived_at.sql
ALTER TABLE presets ADD COLUMN archived_at TIMESTAMPTZ;
```

적용 방법:
```bash
supabase db push
```

또는 Supabase 대시보드 > SQL Editor에서 직접 실행.

## 교훈: 2개의 DB를 동시에 마이그레이션하라

로컬-first + 클라우드 동기화 아키텍처에서는 **스키마 변경이 항상 두 곳에서 발생**한다:

```
1. Drift (로컬 SQLite)
   - tables.dart → 컬럼 정의
   - app_database.dart → schemaVersion + onUpgrade
   - build_runner → 코드 재생성

2. Supabase (원격 PostgreSQL)
   - supabase/migrations/ → ALTER TABLE SQL
   - supabase db push → 적용
```

하나만 하고 다른 하나를 빠뜨리면, 동기화가 조용히 실패한다. Supabase의 upsert는 알 수 없는 컬럼이 포함되면 에러를 반환하지만, 앱에서는 `syncNow()`가 fire-and-forget으로 호출되므로 사용자에게 에러가 노출되지 않는다.

### 체크리스트

스키마를 변경할 때마다 확인:

- [ ] `tables.dart`에 컬럼 추가
- [ ] `app_database.dart` schemaVersion 올리기 + onUpgrade 블록
- [ ] `build_runner` 실행
- [ ] `supabase_mappers.dart` 매퍼에 새 필드 추가
- [ ] `supabase/migrations/` SQL 파일 작성
- [ ] `supabase db push` 실행

## 참고

- [Drift: Schema Migrations](https://drift.simonbinder.eu/migrations/)
- [Supabase: Database Migrations](https://supabase.com/docs/guides/cli/managing-environments#creating-a-new-migration)
- [PostgreSQL: ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)
