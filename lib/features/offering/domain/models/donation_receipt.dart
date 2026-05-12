import 'donation_receipt_id_kind.dart';
import 'donation_receipt_status.dart';

/// 기부금 영수증 신청 (사용자 본인 조회용 — 응답에 idNumberEnc는 포함되지 않음).
class DonationReceipt {
  final int id;
  final String applicantName;
  final String applicantPhone;
  final String donorName;
  final DonationReceiptIdKind idKind;
  final String? donorAddress;
  final String? donorContact;
  final String? donorEmail;
  final String? affiliation;
  final int periodYear;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? dependents;
  final String? memo;
  final DonationReceiptStatus status;
  final String? reviewNote;
  final DateTime? reviewedAt;
  final DateTime? issuedAt;
  final DateTime createdAt;

  const DonationReceipt({
    required this.id,
    required this.applicantName,
    required this.applicantPhone,
    required this.donorName,
    required this.idKind,
    required this.periodYear,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.createdAt,
    this.donorAddress,
    this.donorContact,
    this.donorEmail,
    this.affiliation,
    this.dependents,
    this.memo,
    this.reviewNote,
    this.reviewedAt,
    this.issuedAt,
  });
}
