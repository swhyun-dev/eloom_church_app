import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ministry_models.dart';

final ministryProvider =
StateNotifierProvider<MinistryNotifier, List<MinistryApplyItem>>(
      (ref) => MinistryNotifier(),
);

class MinistryNotifier extends StateNotifier<List<MinistryApplyItem>> {
  MinistryNotifier() : super(const []);

  void submit({
    required MinistryDept dept,
    required String role,
  }) {
    final now = DateTime.now();
    final item = MinistryApplyItem(
      id: '${now.millisecondsSinceEpoch}',
      dept: dept,
      role: role,
      createdAt: now,
      status: MinistryStatus.pending,
    );
    state = [item, ...state];
  }

  void cancel(String id) {
    state = [
      for (final x in state)
        if (x.id == id) x.copyWith(status: MinistryStatus.cancelled) else x
    ];
  }

  // 데모용: 승인/반려 처리(관리자 기능 붙기 전까지 테스트용)
  void markApproved(String id) {
    state = [
      for (final x in state)
        if (x.id == id) x.copyWith(status: MinistryStatus.approved) else x
    ];
  }

  void markRejected(String id) {
    state = [
      for (final x in state)
        if (x.id == id) x.copyWith(status: MinistryStatus.rejected) else x
    ];
  }
}
