import '../domain/donation_receipt_repository.dart';
import '../domain/models/donation_receipt.dart';
import 'donation_receipt_api.dart';
import 'mappers/donation_receipt_mapper.dart';

class DonationReceiptRepositoryImpl implements DonationReceiptRepository {
  final DonationReceiptApi api;

  DonationReceiptRepositoryImpl({required this.api});

  @override
  Future<int> submit(DonationReceiptSubmission payload) {
    return api.submit(payload);
  }

  @override
  Future<List<DonationReceipt>> fetchMine() async {
    final dtos = await api.fetchMine();
    return dtos.map(DonationReceiptMapper.toDomain).toList();
  }

  @override
  Future<void> cancel(int id) {
    return api.cancel(id);
  }
}
