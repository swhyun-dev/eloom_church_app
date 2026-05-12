/// 기부금 영수증 처리 상태. 백엔드 DonationReceiptStatus enum과 1:1.
enum DonationReceiptStatus {
  pending,
  processing,
  issued,
  rejected;

  String get apiValue {
    switch (this) {
      case DonationReceiptStatus.pending:
        return 'PENDING';
      case DonationReceiptStatus.processing:
        return 'PROCESSING';
      case DonationReceiptStatus.issued:
        return 'ISSUED';
      case DonationReceiptStatus.rejected:
        return 'REJECTED';
    }
  }

  String get label {
    switch (this) {
      case DonationReceiptStatus.pending:
        return '신청 접수';
      case DonationReceiptStatus.processing:
        return '처리중';
      case DonationReceiptStatus.issued:
        return '발급 완료';
      case DonationReceiptStatus.rejected:
        return '반려';
    }
  }

  static DonationReceiptStatus fromApiValue(String value) {
    switch (value) {
      case 'PROCESSING':
        return DonationReceiptStatus.processing;
      case 'ISSUED':
        return DonationReceiptStatus.issued;
      case 'REJECTED':
        return DonationReceiptStatus.rejected;
      case 'PENDING':
      default:
        return DonationReceiptStatus.pending;
    }
  }
}
