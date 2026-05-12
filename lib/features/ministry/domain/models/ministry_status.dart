/// 사역신청 상태. 백엔드 MinistryStatus enum과 1:1.
enum MinistryStatus {
  pending,
  approved,
  rejected,
  canceled;

  String get apiValue {
    switch (this) {
      case MinistryStatus.pending:
        return 'PENDING';
      case MinistryStatus.approved:
        return 'APPROVED';
      case MinistryStatus.rejected:
        return 'REJECTED';
      case MinistryStatus.canceled:
        return 'CANCELED';
    }
  }

  String get label {
    switch (this) {
      case MinistryStatus.pending:
        return '대기';
      case MinistryStatus.approved:
        return '승인';
      case MinistryStatus.rejected:
        return '반려';
      case MinistryStatus.canceled:
        return '취소';
    }
  }

  static MinistryStatus fromApiValue(String value) {
    switch (value) {
      case 'APPROVED':
        return MinistryStatus.approved;
      case 'REJECTED':
        return MinistryStatus.rejected;
      case 'CANCELED':
        return MinistryStatus.canceled;
      case 'PENDING':
      default:
        return MinistryStatus.pending;
    }
  }
}
