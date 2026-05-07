import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prayer_api.dart';
import '../../data/prayer_repository_impl.dart';
import '../../domain/models/prayer.dart';
import '../../domain/prayer_repository.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepositoryImpl(api: PrayerApi());
});

/// 공동 기도제목 (공개, APPROVED).
final commonPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  return ref.watch(prayerRepositoryProvider).fetchCommon();
});

/// 본인 zone의 공개 기도제목 (인증 필요).
final zonePrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  return ref.watch(prayerRepositoryProvider).fetchZone();
});

/// 본인 작성 기도제목 (인증 필요).
final minePrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  return ref.watch(prayerRepositoryProvider).fetchMine();
});

/// 본인 작성 단건 — minePrayersProvider 캐시에서 firstWhere.
final minePrayerByIdProvider =
    FutureProvider.family<Prayer?, int>((ref, id) async {
  final list = await ref.watch(minePrayersProvider.future);
  try {
    return list.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
