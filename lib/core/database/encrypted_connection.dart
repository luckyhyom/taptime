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
/// 기존 비암호화 DB가 있으면 파일을 복사 후 PRAGMA rekey로 암호화한다.
/// 새 설치면 처음부터 암호화된 DB를 생성한다.
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
    // 비암호화 파일을 복사한 후 rekey로 암호화한다
    if (plainFile.existsSync() && !encFile.existsSync()) {
      debugPrint('[EncryptedDB] 비암호화 DB 발견, 마이그레이션 시작');
      await plainFile.copy(encFile.path);
      await plainFile.delete();
      debugPrint('[EncryptedDB] 파일 복사 완료, rekey로 암호화 예정');
      // encFile은 아직 비암호화 상태 — 아래에서 열 때 rekey를 적용한다
      return NativeDatabase.createInBackground(
        encFile,
        isolateSetup: () async {
          if (Platform.isAndroid) {
            await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
          }
        },
        setup: (db) {
          // 비암호화 DB를 열므로 빈 키로 시작
          db.execute("PRAGMA key = '';");
          // rekey로 암호화 적용
          db.execute("PRAGMA rekey = '$passphrase';");
          debugPrint('[EncryptedDB] rekey 암호화 적용 완료');
        },
      );
    }

    // 이미 암호화된 DB가 있거나 새 설치
    // (비암호화 원본이 남아있고 enc도 있으면 → 이전 마이그레이션 실패 복구)
    if (plainFile.existsSync() && encFile.existsSync()) {
      await encFile.delete();
      await plainFile.copy(encFile.path);
      await plainFile.delete();
      return NativeDatabase.createInBackground(
        encFile,
        isolateSetup: () async {
          if (Platform.isAndroid) {
            await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
          }
        },
        setup: (db) {
          db.execute("PRAGMA key = '';");
          db.execute("PRAGMA rekey = '$passphrase';");
          debugPrint('[EncryptedDB] rekey 암호화 적용 완료 (복구)');
        },
      );
    }

    // 정상 경로: 암호화 DB 열기 (또는 새로 생성)
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
