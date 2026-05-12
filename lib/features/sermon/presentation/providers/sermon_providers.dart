import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sermon_api.dart';
import '../../data/sermon_repository_impl.dart';
import '../../domain/models/sermon.dart';
import '../../domain/models/sermon_category.dart';
import '../../domain/sermon_repository.dart';

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  return SermonRepositoryImpl(api: SermonApi());
});

/// 카테고리별 설교 목록 (null = 전체).
final sermonsByCategoryProvider =
    FutureProvider.family<List<Sermon>, SermonCategory?>((ref, category) async {
  return ref
      .watch(sermonRepositoryProvider)
      .fetchSermons(category: category);
});

/// 단건 조회.
final sermonByIdProvider = FutureProvider.family<Sermon?, int>((ref, id) async {
  return ref.watch(sermonRepositoryProvider).fetchById(id);
});
