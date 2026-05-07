import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../../features/bible/data/cache/bible_cache.dart';
import '../../../features/bible/data/providers/bible_api_com_provider.dart';
import '../../../features/bible/data/bible_repository_impl.dart';
import '../../../features/bible/domain/bible_service.dart';

import '../../../features/bible/domain/models/bible_memo.dart';
import '../../../features/bible/domain/memo/memo_repository.dart';
import '../../../features/bible/domain/memo/hive_memo_repository.dart';

final sl = GetIt.instance;

void setupServiceLocator({required Box<BibleMemo> memoBox}) {
  // bible API
  sl.registerLazySingleton<BibleCache>(() => BibleCache());
  sl.registerLazySingleton<BibleApiComProvider>(() => BibleApiComProvider());
  sl.registerLazySingleton<BibleService>(() => BibleRepositoryImpl(
    provider: sl<BibleApiComProvider>(),
    cache: sl<BibleCache>(),
  ));

  // memo
  sl.registerLazySingleton<MemoRepository>(() => HiveMemoRepository(memoBox));
}
