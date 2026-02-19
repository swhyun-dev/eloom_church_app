enum MinistryDept {
  worship('예배부'),
  praise('찬양사역부'),
  vehicle('차량관리부'),
  media('미디어사역부'),
  education('교육부'),
  service('봉사부'),
  evangelism('전도부');

  final String label;
  const MinistryDept(this.label);
}

enum MinistryStatus {
  pending('대기'),
  approved('승인'),
  rejected('반려'),
  cancelled('취소');

  final String label;
  const MinistryStatus(this.label);
}

class MinistryApplyItem {
  final String id;
  final MinistryDept dept;
  final String role; // ex) "카페봉사"
  final DateTime createdAt;
  final MinistryStatus status;

  const MinistryApplyItem({
    required this.id,
    required this.dept,
    required this.role,
    required this.createdAt,
    required this.status,
  });

  MinistryApplyItem copyWith({MinistryStatus? status}) {
    return MinistryApplyItem(
      id: id,
      dept: dept,
      role: role,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
