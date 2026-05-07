import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/http/app_dio.dart';
import 'features/bible/domain/models/bible_memo.dart';
import 'features/core/di/service_locator.dart';
import 'state/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // Adapter 등록 (build_runner로 생성된 BibleMemoAdapter 필요)
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(BibleMemoAdapter());
  }

  // Box 오픈
  final memoBox = await Hive.openBox<BibleMemo>('bible_memos');

  // get_it 등록 (memoBox 주입)
  setupServiceLocator(memoBox: memoBox);

  // SharedPreferences에서 로그인 상태 복원
  final container = ProviderContainer();
  await container.read(authProvider.notifier).init();

  // 401 응답 시 자동 로그아웃 (TokenStorage.clear는 인터셉터에서 처리)
  AppDio.onUnauthorized = () =>
      container.read(authProvider.notifier).logout();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
