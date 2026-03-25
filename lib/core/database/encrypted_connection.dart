import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

/// SQLCipher 암호화가 적용된 Drift DB 연결을 생성한다.
///
/// 1. flutter_secure_storage에서 암호화 키를 읽거나, 없으면 새로 생성
/// 2. 기존 비암호화 DB가 있으면 암호화 DB로 마이그레이션
/// 3. NativeDatabase.createInBackground로 백그라운드 isolate에서 실행
QueryExecutor openEncryptedDatabase() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final plainFile = File('${dbFolder.path}/taptime.db');
    final encFile = File('${dbFolder.path}/taptime_enc.db');

    final passphrase = await _getOrCreatePassphrase();

    // Android: 백그라운드 isolate에서 SQLCipher 라이브러리 로딩에 필요
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    }

    // 기존 비암호화 DB → 암호화 DB 마이그레이션
    if (plainFile.existsSync() && !encFile.existsSync()) {
      await _migrateToEncrypted(plainFile, encFile, passphrase);
    }

    // 암호화 DB가 없고 비암호화 DB도 없으면 새 파일로 시작
    final dbFile = encFile.existsSync() ? encFile : encFile;

    return NativeDatabase.createInBackground(
      dbFile,
      isolateSetup: () async {
        // 백그라운드 isolate에서도 SQLCipher 라이브러리 로딩 필요
        if (Platform.isAndroid) {
          await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
        }
      },
      setup: (db) {
        // SQLCipher가 정상 로드되었는지 검증
        assert(_debugCheckHasCipher(db), 'SQLCipher를 사용할 수 없습니다. sqlite3_flutter_libs 충돌을 확인하세요.');

        // PRAGMA key는 반드시 연결 후 첫 번째 명령이어야 한다
        db.execute("PRAGMA key = '$passphrase';");
      },
    );
  });
}

// ── 키 관리 ───────────────────────────────────────────────────

const _storageKey = 'taptime_db_passphrase';
const _storage = FlutterSecureStorage();

/// Keychain(iOS) / Keystore(Android)에서 암호화 키를 읽거나 새로 생성한다.
Future<String> _getOrCreatePassphrase() async {
  var passphrase = await _storage.read(key: _storageKey);
  if (passphrase == null) {
    passphrase = _generatePassphrase(32);
    await _storage.write(key: _storageKey, value: passphrase);
  }
  return passphrase;
}

/// 암호학적으로 안전한 랜덤 패스프레이즈를 생성한다.
String _generatePassphrase(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

// ── 마이그레이션 ──────────────────────────────────────────────

/// 기존 비암호화 DB를 암호화 DB로 변환한다.
///
/// SQLCipher의 sqlcipher_export()를 사용하여 데이터를 복사한다.
/// 완료 후 원본 파일을 삭제한다.
Future<void> _migrateToEncrypted(File plainFile, File encFile, String passphrase) async {
  try {
    raw.sqlite3.open(plainFile.path)
      ..execute("ATTACH DATABASE '${encFile.path}' AS encrypted KEY '$passphrase';")
      ..execute("SELECT sqlcipher_export('encrypted');")
      ..execute('DETACH DATABASE encrypted;')
      ..close();

    // 비암호화 원본 삭제
    await plainFile.delete();
    debugPrint('[EncryptedDB] 비암호화 DB → 암호화 DB 마이그레이션 완료');
  } on Exception catch (e) {
    debugPrint('[EncryptedDB] 마이그레이션 실패: $e');
    // 마이그레이션 실패 시 불완전한 암호화 파일 제거
    if (encFile.existsSync()) {
      await encFile.delete();
    }
    rethrow;
  }
}

// ── 검증 ──────────────────────────────────────────────────────

/// SQLCipher가 정상 로드되었는지 확인한다.
/// cipher_version PRAGMA는 SQLCipher 빌드에만 존재한다.
bool _debugCheckHasCipher(raw.Database db) {
  final result = db.select('PRAGMA cipher_version;');
  return result.isNotEmpty;
}
