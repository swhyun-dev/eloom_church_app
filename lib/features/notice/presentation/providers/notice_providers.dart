import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notice_api.dart';
import '../../data/notice_repository_impl.dart';
import '../../domain/models/notice.dart';
import '../../domain/notice_repository.dart';

/// Repository DI. 테스트 시 override 가능.
final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepositoryImpl(api: NoticeApi());
});

/// 공지 목록 — UI는 이 provider만 watch.
/// 새로고침: `ref.invalidate(noticeListProvider)`
final noticeListProvider = FutureProvider<List<Notice>>((ref) async {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.fetchAll();
});
