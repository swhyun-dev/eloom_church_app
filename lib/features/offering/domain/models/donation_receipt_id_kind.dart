/// 기부금 영수증 번호 종류. 백엔드 DonationReceiptIdKind enum과 1:1.
enum DonationReceiptIdKind {
  resident,
  business;

  String get apiValue {
    switch (this) {
      case DonationReceiptIdKind.resident:
        return 'RESIDENT';
      case DonationReceiptIdKind.business:
        return 'BUSINESS';
    }
  }

  String get label {
    switch (this) {
      case DonationReceiptIdKind.resident:
        return '주민등록번호';
      case DonationReceiptIdKind.business:
        return '사업자등록번호';
    }
  }

  static DonationReceiptIdKind fromApiValue(String value) {
    return value == 'BUSINESS'
        ? DonationReceiptIdKind.business
        : DonationReceiptIdKind.resident;
  }
}
