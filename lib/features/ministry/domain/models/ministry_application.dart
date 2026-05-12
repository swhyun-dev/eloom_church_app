import 'ministry_dept.dart';
import 'ministry_status.dart';

class MinistryApplication {
  final int id;
  final MinistryDept department;

  /// 자유 텍스트 — Flutter UI에서는 부서별 세부 역할(예: "찬양팀(1부예배)")이
  /// 들어가고, 관리자 화면에서는 일반 지원 동기로 표시될 수 있다.
  final String motivation;

  /// 관련 경험 (선택).
  final String? experience;

  final MinistryStatus status;

  /// 관리자가 승인/반려 시 남기는 메모.
  final String? reviewNote;
  final DateTime? reviewedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const MinistryApplication({
    required this.id,
    required this.department,
    required this.motivation,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.experience,
    this.reviewNote,
    this.reviewedAt,
  });

  MinistryApplication copyWith({MinistryStatus? status}) {
    return MinistryApplication(
      id: id,
      department: department,
      motivation: motivation,
      experience: experience,
      status: status ?? this.status,
      reviewNote: reviewNote,
      reviewedAt: reviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
