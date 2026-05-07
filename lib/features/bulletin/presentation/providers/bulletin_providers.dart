import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bulletin_api.dart';
import '../../data/bulletin_repository_impl.dart';
import '../../domain/models/bulletin.dart';
import '../../domain/bulletin_repository.dart';

final bulletinRepositoryProvider = Provider<BulletinRepository>((ref) {
  return BulletinRepositoryImpl(api: BulletinApi());
});

/// 주보 목록 — 모든 화면이 공유하는 단일 소스.
final bulletinListProvider = FutureProvider<List<Bulletin>>((ref) async {
  return ref.watch(bulletinRepositoryProvider).fetchAll();
});

/// 단건 조회 (별도 API 없이 list에서 firstWhere — 캐시 활용).
final bulletinByIdProvider = FutureProvider.family<Bulletin?, int>((ref, id) async {
  final list = await ref.watch(bulletinListProvider.future);
  try {
    return list.firstWhere((b) => b.id == id);
  } catch (_) {
    return null;
  }
});
