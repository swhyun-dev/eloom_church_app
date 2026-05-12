import 'models/donation_receipt.dart';
import 'models/donation_receipt_id_kind.dart';

/// 영수증 신청 페이로드. idNumber는 평문으로 서버에 도달하고,
/// 서버에서 AES-256-GCM 암호화 후 저장된다. 클라이언트가 다시 받지 않는다.
class DonationReceiptSubmission {
  final String applicantName;
  final String applicantPhone;
  final String donorName;
  final DonationReceiptIdKind idKind;
  final String idNumber;
  final String? donorAddress;
  final String? donorContact;
  final String? donorEmail;
  final String? affiliation;
  final int periodYear;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? dependents;
  final String? memo;
  final String? password;
  final bool agreedPrivacy;
  final bool agreedUniqueId;

  const DonationReceiptSubmission({
    required this.applicantName,
    required this.applicantPhone,
    required this.donorName,
    required this.idKind,
    required this.idNumber,
    required this.periodYear,
    required this.periodStart,
    required this.periodEnd,
    required this.agreedPrivacy,
    required this.agreedUniqueId,
    this.donorAddress,
    this.donorContact,
    this.donorEmail,
    this.affiliation,
    this.dependents,
    this.memo,
    this.password,
  });
}

abstract class DonationReceiptRepository {
  /// POST /api/v1/donation-receipts — 영수증 신청.
  /// 응답에 id/status/periodYear/createdAt만 들어있으므로 가벼운 ack 모델.
  Future<int> submit(DonationReceiptSubmission payload);

  /// GET /api/v1/donation-receipts/me — 내 신청 내역.
  Future<List<DonationReceipt>> fetchMine();

  /// PATCH /:id/cancel — 본인 PENDING 상태일 때만 취소.
  Future<void> cancel(int id);
}
