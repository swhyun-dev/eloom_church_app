import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/zone_post_api.dart';
import '../../data/zone_post_repository_impl.dart';
import '../../domain/models/zone_post.dart';
import '../../domain/zone_post_repository.dart';

final zonePostRepositoryProvider = Provider<ZonePostRepository>((ref) {
  return ZonePostRepositoryImpl(api: ZonePostApi());
});

/// 구역 게시글 목록 — 본인 zone 한정 (백엔드 필터).
final zonePostListProvider = FutureProvider<List<ZonePost>>((ref) async {
  return ref.watch(zonePostRepositoryProvider).fetchAll();
});

/// 단건 — list 캐시에서 firstWhere.
final zonePostByIdProvider =
    FutureProvider.family<ZonePost?, int>((ref, id) async {
  final list = await ref.watch(zonePostListProvider.future);
  try {
    return list.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
