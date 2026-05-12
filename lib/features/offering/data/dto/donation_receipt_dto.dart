class DonationReceiptDto {
  final int id;
  final String applicantName;
  final String applicantPhone;
  final String donorName;
  final String idKind;
  final String? donorAddress;
  final String? donorContact;
  final String? donorEmail;
  final String? affiliation;
  final int periodYear;
  final String periodStart;
  final String periodEnd;
  final String? dependents;
  final String? memo;
  final String status;
  final String? reviewNote;
  final String? reviewedAt;
  final String? issuedAt;
  final String createdAt;

  const DonationReceiptDto({
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

  factory DonationReceiptDto.fromJson(Map<String, dynamic> j) =>
      DonationReceiptDto(
        id: j['id'] as int,
        applicantName: j['applicantName'] as String? ?? '',
        applicantPhone: j['applicantPhone'] as String? ?? '',
        donorName: j['donorName'] as String? ?? '',
        idKind: j['idKind'] as String? ?? 'RESIDENT',
        donorAddress: j['donorAddress'] as String?,
        donorContact: j['donorContact'] as String?,
        donorEmail: j['donorEmail'] as String?,
        affiliation: j['affiliation'] as String?,
        periodYear: j['periodYear'] as int? ?? DateTime.now().year,
        periodStart: j['periodStart'] as String,
        periodEnd: j['periodEnd'] as String,
        dependents: j['dependents'] as String?,
        memo: j['memo'] as String?,
        status: j['status'] as String? ?? 'PENDING',
        reviewNote: j['reviewNote'] as String?,
        reviewedAt: j['reviewedAt'] as String?,
        issuedAt: j['issuedAt'] as String?,
        createdAt: j['createdAt'] as String,
      );
}
