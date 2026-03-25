# [BUG] SQLCipher 마이그레이션 삽질기: sqlcipher_export → NativeDatabase → rekey

> 2026-03-25 | Taptime 로컬 DB 암호화

## 배경

로컬 SQLite DB에 위치 데이터, 세션 기록 등 개인정보가 저장되어 있어 SQLCipher 암호화를 적용하기로 했다. 문제는 이미 사용 중인 비암호화 DB를 암호화 DB로 변환하는 마이그레이션이었다.

## 시도 1: sqlcipher_export — 실패

SQLCipher 공식 문서의 권장 방식이다:

```dart
final plainDb = raw.sqlite3.open(plainFile.path);
plainDb.execute("ATTACH DATABASE '${encFile.path}' AS encrypted KEY '$passphrase';");
plainDb.execute("SELECT sqlcipher_export('encrypted');");
```

**에러:**
```
SqliteException(1): no such function: sqlcipher_export
```

**원인:** iOS에서 `sqlite3` Dart 패키지의 `raw.sqlite3.open()`은 **시스템 sqlite3 라이브러리**를 사용한다. `sqlcipher_flutter_libs`가 제공하는 SQLCipher는 Flutter 플러그인 시스템을 통해 로드되지만, Dart FFI로 직접 여는 `raw.sqlite3`에는 적용되지 않는다.

`flutter pub deps | grep sqlite3_flutter_libs`로 충돌을 확인해도 아무것도 없었다. 충돌이 아니라 **로딩 경로가 다른 것**이 문제였다.

## 시도 2: NativeDatabase setup 콜백 — 실패

Drift의 `NativeDatabase`는 SQLCipher가 로드된 상태로 setup 콜백을 실행하므로, 여기서 마이그레이션하면 되지 않을까?

```dart
final migrationDb = NativeDatabase(
  plainFile,
  setup: (db) {
    db.execute("ATTACH DATABASE '${encFile.path}' AS encrypted KEY '$passphrase';");
    db.execute("SELECT sqlcipher_export('encrypted');");
    db.execute('DETACH DATABASE encrypted;');
  },
);
await migrationDb.runCustom('SELECT 1');
```

**에러:**
```
Unhandled Exception: Null check operator used on a null value
#0 Sqlite3Delegate.database
```

**원인:** `NativeDatabase`의 setup 콜백은 연결 초기화 중에 실행되지만, `runCustom()`은 Drift의 `Sqlite3Delegate.database`가 완전히 초기화된 후에만 사용 가능하다. setup 콜백 안에서 ATTACH를 실행해도, `runCustom('SELECT 1')`으로 DB를 "열려고" 할 때 내부 상태가 아직 null이어서 크래시한다.

## 시도 3: 파일 복사 + PRAGMA rekey — 성공

발상을 전환했다. DB 간 데이터를 복사하는 대신, **파일 자체를 복사한 후 암호화를 적용**한다.

```dart
// 1. 비암호화 파일을 새 이름으로 복사
await plainFile.copy(encFile.path);
await plainFile.delete();

// 2. 비암호화 상태로 열고 rekey로 암호화
return NativeDatabase.createInBackground(
  encFile,
  setup: (db) {
    db.execute("PRAGMA key = '';");        // 빈 키 = 비암호화로 열기
    db.execute("PRAGMA rekey = '$passphrase';");  // 암호화 적용
  },
);
```

`PRAGMA rekey`는 SQLCipher의 기능으로, 열린 DB의 암호화 키를 변경한다. 빈 키(비암호화)에서 실제 키로 변경하면 **in-place 암호화**가 된다.

이 방식이 동작하는 이유:
- `NativeDatabase.createInBackground`는 Flutter 플러그인이 제공하는 SQLCipher를 사용
- setup 콜백에서 PRAGMA만 실행하고, DB 열기는 Drift가 처리
- 파일 복사는 OS 레벨이라 sqlite3 라이브러리와 무관

## 교훈

### 1. 같은 "sqlite3"가 아니다

iOS에서 sqlite3는 최소 세 가지 경로로 로드될 수 있다:

| 경로 | 라이브러리 | SQLCipher 함수 |
|------|-----------|---------------|
| `import 'package:sqlite3/sqlite3.dart'` | 시스템 sqlite3 | ✗ 없음 |
| `NativeDatabase` (Drift) | sqlcipher_flutter_libs | ✓ 있음 |
| `DynamicLibrary.open('libsqlcipher.so')` | Android 전용 | ✓ 있음 |

공식 문서의 `raw.sqlite3.open()` 예제는 SQLCipher가 시스템 기본 sqlite3를 교체하는 환경을 가정한다. Flutter iOS에서는 그렇지 않다.

### 2. PRAGMA rekey가 가장 단순하다

`sqlcipher_export`는 두 DB 간 데이터를 복사하는 방식이고, `rekey`는 현재 DB를 in-place로 암호화한다. 파일 복사 + rekey가 가장 적은 의존성으로 동작한다.

### 3. 마이그레이션은 반드시 실기기에서 테스트하라

인메모리 테스트에서는 암호화 마이그레이션을 검증할 수 없다. 파일 시스템, 네이티브 라이브러리 로딩, 플랫폼별 차이가 모두 관여하기 때문이다.

## 참고

- [Drift: Encryption](https://drift.simonbinder.eu/platforms/encryption/)
- [SQLCipher: PRAGMA rekey](https://www.zetetic.net/sqlcipher/sqlcipher-api/#rekey)
- [SQLCipher: Migrating from unencrypted DB](https://www.zetetic.net/sqlcipher/sqlcipher-api/#sqlcipher_export)
- [sqlcipher_flutter_libs incompatibilities](https://github.com/simolus3/sqlite3.dart/tree/master/sqlcipher_flutter_libs#incompatibilities-with-sqlite3-on-ios-and-macos)
