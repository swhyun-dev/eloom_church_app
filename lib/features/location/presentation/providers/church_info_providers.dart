import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/church_info_api.dart';
import '../../data/church_info_repository_impl.dart';
import '../../domain/church_info_repository.dart';
import '../../domain/models/church_info.dart';

final churchInfoRepositoryProvider = Provider<ChurchInfoRepository>((ref) {
  return ChurchInfoRepositoryImpl(api: ChurchInfoApi());
});

final churchInfoProvider = FutureProvider<ChurchInfo?>((ref) async {
  return ref.watch(churchInfoRepositoryProvider).fetch();
});
