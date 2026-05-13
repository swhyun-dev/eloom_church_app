import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/http/app_dio.dart';
import 'features/bible/domain/models/bible_memo.dart';
import 'features/core/di/service_locator.dart';
import 'state/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ko_KR 날짜/요일 포맷 데이터 로드 — TableCalendar 한글 표시에 필요
  await initializeDateFormatting('ko_KR', null);

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

  // Firebase 초기화 + FCM 토큰 등록 (실패해도 앱 자체는 진행)
  try {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final fcmToken = await messaging.getToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      AuthNotifier.cachedFcmToken = fcmToken;
      // 로그인 상태일 때만 실제 등록됨 (registerDeviceToken 내부 check)
      await container.read(authProvider.notifier).registerDeviceToken(fcmToken);
    }
    messaging.onTokenRefresh.listen((newToken) {
      AuthNotifier.cachedFcmToken = newToken;
      container.read(authProvider.notifier).registerDeviceToken(newToken);
    });
  } catch (_) {
    // Firebase 미설정 환경(예: 개발 디바이스)에서는 무시하고 앱 계속 실행
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
