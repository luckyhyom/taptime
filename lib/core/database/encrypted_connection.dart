import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

/// SQLCipher 암호화가 적용된 Drift DB 연결을 생성한다.
///
/// 1. flutter_secure_storage에서 암호화 키를 읽거나, 없으면 새로 생성
/// 2. 기존 비암호화 DB가 있으면 암호화 DB로 마이그레이션
/// 3. NativeDatabase.createInBackground로 백그라운드 isolate에서 실행
QueryExecutor openEncryptedDatabase() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final plainFile = File('${dbFolder.path}/taptime.sqlite');
    final encFile = File('${dbFolder.path}/taptime_enc.db');

    final passphrase = await _getOrCreatePassphrase();

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    }

    // 기존 비암호화 DB → 암호화 DB 마이그레이션
    if (plainFile.existsSync()) {
      if (encFile.existsSync()) {
        await encFile.delete();
      }
      await _migrateToEncrypted(plainFile, encFile, passphrase);
    }

    return NativeDatabase.createInBackground(
      encFile,
      isolateSetup: () async {
        if (Platform.isAndroid) {
          await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
        }
      },
      setup: (db) {
        db.execute("PRAGMA key = '$passphrase';");
      },
    );
  });
}

// ── 키 관리 ───────────────────────────────────────────────────

const _storageKey = 'taptime_db_passphrase';
const _storage = FlutterSecureStorage();

Future<String> _getOrCreatePassphrase() async {
  var passphrase = await _storage.read(key: _storageKey);
  if (passphrase == null) {
    passphrase = _generatePassphrase(32);
    await _storage.write(key: _storageKey, value: passphrase);
  }
  return passphrase;
}

String _generatePassphrase(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

// ── 마이그레이션 ──────────────────────────────────────────────

/// 기존 비암호화 DB를 암호화 DB로 변환한다.
///
/// iOS에서는 raw sqlite3가 시스템 라이브러리를 사용하므로
/// sqlcipher_export()를 쓸 수 없다.
/// 대신 NativeDatabase의 setup 콜백에서 SQLCipher를 통해
/// ATTACH + sqlcipher_export를 실행한다.
Future<void> _migrateToEncrypted(File plainFile, File encFile, String passphrase) async {
  try {
    // NativeDatabase의 setup에서 SQLCipher가 로드된 상태로 마이그레이션한다
    final migrationDb = NativeDatabase(
      plainFile,
      setup: (db) {
        // 비암호화 DB이므로 key 없이 연다
        // 새 암호화 DB를 attach하고 데이터를 복사한다
        db.execute("ATTACH DATABASE '${encFile.path}' AS encrypted KEY '$passphrase';");
        db.execute("SELECT sqlcipher_export('encrypted');");
        db.execute('DETACH DATABASE encrypted;');
      },
    );

    // setup 콜백이 실행되도록 DB를 열어야 한다
    // ensureOpen()을 위해 간단한 쿼리 실행
    await migrationDb.runCustom('SELECT 1');
    await migrationDb.close();

    // 원본 삭제
    await plainFile.delete();
    debugPrint('[EncryptedDB] 비암호화 DB → 암호화 DB 마이그레이션 완료');
  } on Exception catch (e) {
    debugPrint('[EncryptedDB] 마이그레이션 실패: $e');
    if (encFile.existsSync()) {
      await encFile.delete();
    }
    // 마이그레이션 실패 시 원본을 유지하고 비암호화로 폴백
    rethrow;
  }
}
