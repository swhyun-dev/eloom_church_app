import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/donation_receipt_api.dart';
import '../../data/donation_receipt_repository_impl.dart';
import '../../domain/donation_receipt_repository.dart';
import '../../domain/models/donation_receipt.dart';

final donationReceiptRepositoryProvider =
    Provider<DonationReceiptRepository>((ref) {
  return DonationReceiptRepositoryImpl(api: DonationReceiptApi());
});

/// 내 영수증 신청 내역.
final myDonationReceiptsProvider =
    FutureProvider<List<DonationReceipt>>((ref) async {
  return ref.watch(donationReceiptRepositoryProvider).fetchMine();
});

/// 영수증 신청 액션. 호출 후 myDonationReceiptsProvider invalidate 권장.
final submitDonationReceiptProvider =
    Provider<Future<int> Function(DonationReceiptSubmission)>((ref) {
  final repo = ref.watch(donationReceiptRepositoryProvider);
  return repo.submit;
});

/// 본인 PENDING 영수증 신청 취소.
final cancelDonationReceiptProvider =
    Provider<Future<void> Function(int)>((ref) {
  final repo = ref.watch(donationReceiptRepositoryProvider);
  return repo.cancel;
});
