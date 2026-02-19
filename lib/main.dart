import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/bible/domain/models/bible_memo.dart';
import 'features/core/di/service_locator.dart';

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

  runApp(const ProviderScope(child: App()));
}
