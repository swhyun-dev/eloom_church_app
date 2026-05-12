import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ministry_api.dart';
import '../../data/ministry_repository_impl.dart';
import '../../domain/ministry_repository.dart';
import '../../domain/models/ministry_application.dart';
import '../../domain/models/ministry_dept.dart';

final ministryRepositoryProvider = Provider<MinistryRepository>((ref) {
  return MinistryRepositoryImpl(api: MinistryApi());
});

/// 내 사역신청 내역 — 새 신청/취소 후 invalidate 되어야 갱신.
final myMinistryApplicationsProvider =
    FutureProvider<List<MinistryApplication>>((ref) async {
  return ref.watch(ministryRepositoryProvider).fetchMyApplications();
});

/// 신청 제출 액션. 호출 후 myMinistryApplicationsProvider invalidate 권장.
final submitMinistryProvider = Provider<
    Future<MinistryApplication> Function({
      required MinistryDept department,
      required String motivation,
      String? experience,
    })>((ref) {
  final repo = ref.watch(ministryRepositoryProvider);
  return ({
    required MinistryDept department,
    required String motivation,
    String? experience,
  }) {
    return repo.submit(
      department: department,
      motivation: motivation,
      experience: experience,
    );
  };
});

/// 본인 PENDING 신청 취소 액션.
final cancelMinistryProvider =
    Provider<Future<MinistryApplication> Function(int)>((ref) {
  final repo = ref.watch(ministryRepositoryProvider);
  return (int id) => repo.cancel(id);
});
