import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'features/settings/settings_provider.dart'; // ✅ 추가

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: '이룸교회',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,

      // ✅ 전역 폰트 크기 반영 + SharedPreferences 로드 후 값 반영
      builder: (context, child) {
        final mq = MediaQuery.of(context);

        // hydrated 전에는 기본 1.0을 쓰되, 빌드 안전하게 처리
        final scale = settings.hydrated ? settings.fontScale : 1.0;

        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(scale),
            // Flutter 구버전이면 아래로 교체:
            // textScaleFactor: scale,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
