import '../../domain/models/donation_receipt.dart';
import '../../domain/models/donation_receipt_id_kind.dart';
import '../../domain/models/donation_receipt_status.dart';
import '../dto/donation_receipt_dto.dart';

class DonationReceiptMapper {
  DonationReceiptMapper._();

  static DonationReceipt toDomain(DonationReceiptDto dto) => DonationReceipt(
        id: dto.id,
        applicantName: dto.applicantName,
        applicantPhone: dto.applicantPhone,
        donorName: dto.donorName,
        idKind: DonationReceiptIdKind.fromApiValue(dto.idKind),
        donorAddress: dto.donorAddress,
        donorContact: dto.donorContact,
        donorEmail: dto.donorEmail,
        affiliation: dto.affiliation,
        periodYear: dto.periodYear,
        periodStart: DateTime.parse(dto.periodStart),
        periodEnd: DateTime.parse(dto.periodEnd),
        dependents: dto.dependents,
        memo: dto.memo,
        status: DonationReceiptStatus.fromApiValue(dto.status),
        reviewNote: dto.reviewNote,
        reviewedAt: dto.reviewedAt != null
            ? DateTime.tryParse(dto.reviewedAt!)
            : null,
        issuedAt:
            dto.issuedAt != null ? DateTime.tryParse(dto.issuedAt!) : null,
        createdAt: DateTime.parse(dto.createdAt),
      );
}
