import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/banner_api.dart';
import '../../data/banner_repository_impl.dart';
import '../../domain/banner_repository.dart';
import '../../domain/models/banner_slot.dart';

final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepositoryImpl(api: BannerApi());
});

/// 활성 배너 슬롯 목록 — slot 오름차순.
final activeBannersProvider = FutureProvider<List<BannerSlot>>((ref) async {
  return ref.watch(bannerRepositoryProvider).fetchActive();
});
