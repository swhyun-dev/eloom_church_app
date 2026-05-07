import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board_api.dart';
import '../../data/board_repository_impl.dart';
import '../../domain/board_repository.dart';
import '../../domain/models/board_category.dart';
import '../../domain/models/board_post.dart';

final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  return BoardRepositoryImpl(api: BoardApi());
});

/// 카테고리별 게시글 목록 — 카테고리당 단일 캐시.
final boardPostsByCategoryProvider =
    FutureProvider.family<List<BoardPost>, BoardCategory>((ref, category) async {
  return ref.watch(boardRepositoryProvider).fetchByCategory(category);
});

/// (카테고리, id) 쌍으로 단건 조회 (네트워크 추가 호출 없이 list 캐시 사용).
typedef BoardPostKey = ({BoardCategory category, int id});

final boardPostByIdProvider =
    FutureProvider.family<BoardPost?, BoardPostKey>((ref, key) async {
  final list = await ref.watch(boardPostsByCategoryProvider(key.category).future);
  try {
    return list.firstWhere((p) => p.id == key.id);
  } catch (_) {
    return null;
  }
});
