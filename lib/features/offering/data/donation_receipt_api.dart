import '../../../services/api_service.dart';
import '../domain/donation_receipt_repository.dart';
import 'dto/donation_receipt_dto.dart';

class DonationReceiptApi {
  DonationReceiptApi();

  final ApiService _api = ApiService();

  /// POST /api/v1/donation-receipts — 신청
  /// 응답 item에는 id/status/periodYear/createdAt만 들어옴 (idNumber 평문은 클라이언트로 다시 안 보냄).
  Future<int> submit(DonationReceiptSubmission p) async {
    final body = <String, dynamic>{
      'applicantName': p.applicantName,
      'applicantPhone': p.applicantPhone,
      'donorName': p.donorName,
      'idKind': p.idKind.apiValue,
      'idNumber': p.idNumber,
      if (p.donorAddress != null && p.donorAddress!.isNotEmpty)
        'donorAddress': p.donorAddress,
      if (p.donorContact != null && p.donorContact!.isNotEmpty)
        'donorContact': p.donorContact,
      if (p.donorEmail != null && p.donorEmail!.isNotEmpty)
        'donorEmail': p.donorEmail,
      if (p.affiliation != null && p.affiliation!.isNotEmpty)
        'affiliation': p.affiliation,
      'periodYear': p.periodYear,
      'periodStart': p.periodStart.toIso8601String(),
      'periodEnd': p.periodEnd.toIso8601String(),
      if (p.dependents != null && p.dependents!.isNotEmpty)
        'dependents': p.dependents,
      if (p.memo != null && p.memo!.isNotEmpty) 'memo': p.memo,
      if (p.password != null && p.password!.isNotEmpty)
        'password': p.password,
      'agreedPrivacy': p.agreedPrivacy,
      'agreedUniqueId': p.agreedUniqueId,
    };
    final data = await _api.post('/api/v1/donation-receipts', body);
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) {
      throw Exception('신청 응답 형식이 올바르지 않습니다.');
    }
    return item['id'] as int;
  }

  /// GET /api/v1/donation-receipts/me
  Future<List<DonationReceiptDto>> fetchMine() async {
    final data = await _api.get('/api/v1/donation-receipts/me');
    final items = data['items'] as List? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DonationReceiptDto.fromJson)
        .toList();
  }

  /// PATCH /api/v1/donation-receipts/:id/cancel
  Future<void> cancel(int id) async {
    await _api.patch('/api/v1/donation-receipts/$id/cancel', const {});
  }
}
