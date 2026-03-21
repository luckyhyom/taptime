import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:taptime/app.dart';
import 'package:taptime/core/config/supabase_config.dart';

Future<void> main() async {
  // Flutter 엔진과 프레임워크를 연결하는 초기화 코드.
  // 플랫폼 채널(파일 시스템, DB 등)을 사용하려면
  // runApp() 전에 반드시 호출해야 한다.
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화. 설정되지 않은 경우(placeholder 값) 건너뛴다.
  // v2.0에서 Supabase 프로젝트 생성 후 SupabaseConfig의 값을 교체하면 활성화된다.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(
    // ProviderScope는 Riverpod의 최상위 위젯으로,
    // 모든 프로바이더의 상태를 관리하는 컨테이너 역할을 한다.
    const ProviderScope(child: App()),
  );
}
