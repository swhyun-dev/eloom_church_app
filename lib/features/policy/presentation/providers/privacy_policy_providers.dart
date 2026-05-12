import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/privacy_policy_api.dart';
import '../../data/privacy_policy_repository_impl.dart';
import '../../domain/models/privacy_policy.dart';
import '../../domain/privacy_policy_repository.dart';

final privacyPolicyRepositoryProvider =
    Provider<PrivacyPolicyRepository>((ref) {
  return PrivacyPolicyRepositoryImpl(api: PrivacyPolicyApi());
});

final privacyPolicyProvider = FutureProvider<PrivacyPolicy?>((ref) async {
  return ref.watch(privacyPolicyRepositoryProvider).fetch();
});
