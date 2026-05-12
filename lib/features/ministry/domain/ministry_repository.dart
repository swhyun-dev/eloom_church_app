import 'models/ministry_application.dart';
import 'models/ministry_dept.dart';

abstract class MinistryRepository {
  /// 내 사역신청 내역 조회.
  Future<List<MinistryApplication>> fetchMyApplications();

  /// 새 사역신청 제출.
  Future<MinistryApplication> submit({
    required MinistryDept department,
    required String motivation,
    String? experience,
  });

  /// 본인이 PENDING 상태일 때만 취소.
  Future<MinistryApplication> cancel(int id);
}
