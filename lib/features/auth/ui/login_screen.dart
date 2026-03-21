import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taptime/core/providers/auth_providers.dart';
import 'package:taptime/core/theme/app_spacing.dart';
import 'package:taptime/shared/services/auth_service.dart';

/// 로그인 화면 — Google/Apple 소셜 로그인을 제공한다.
///
/// 로그인 성공 시 이전 화면(Settings)으로 되돌아간다.
/// 인증 서비스가 없으면 에러 메시지를 표시한다.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  /// Google/Apple 공통 로그인 로직.
  /// [action]에 실제 로그인 호출을 전달한다.
  Future<void> _signIn(Future<void> Function(AuthService) action) async {
    final authService = ref.read(authServiceProvider);
    if (authService == null) return;

    setState(() => _isLoading = true);
    try {
      await action(authService);
      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.cloud_outlined, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.padding),
            Text(
              '클라우드 동기화',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.grid),
            Text(
              '로그인하면 데이터가 자동으로 클라우드에 백업되어\n기기를 변경해도 데이터를 유지할 수 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              OutlinedButton.icon(
                onPressed: () => _signIn((s) => s.signInWithGoogle()),
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Google로 계속하기'),
                style: buttonStyle,
              ),
              const SizedBox(height: AppSpacing.grid),
              // defaultTargetPlatform은 테스트에서 오버라이드 가능하고
              // Flutter Web에서도 안전하게 동작한다 (dart:io 불필요).
              if (defaultTargetPlatform == TargetPlatform.iOS)
                OutlinedButton.icon(
                  onPressed: () => _signIn((s) => s.signInWithApple()),
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('Apple로 계속하기'),
                  style: buttonStyle,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
