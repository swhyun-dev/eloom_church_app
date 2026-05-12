import '../domain/models/privacy_policy.dart';
import '../domain/privacy_policy_repository.dart';
import 'privacy_policy_api.dart';

class PrivacyPolicyRepositoryImpl implements PrivacyPolicyRepository {
  final PrivacyPolicyApi api;
  PrivacyPolicyRepositoryImpl({required this.api});

  @override
  Future<PrivacyPolicy?> fetch() => api.fetch();
}
