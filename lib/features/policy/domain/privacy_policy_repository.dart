import 'models/privacy_policy.dart';

abstract class PrivacyPolicyRepository {
  Future<PrivacyPolicy?> fetch();
}
