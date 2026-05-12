import '../../../services/api_service.dart';
import '../domain/models/privacy_policy.dart';

class PrivacyPolicyApi {
  PrivacyPolicyApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/privacy-policy — singleton row.
  Future<PrivacyPolicy?> fetch() async {
    final data = await _api.get('/api/v1/privacy-policy');
    final policy = data['policy'] as Map<String, dynamic>?;
    if (policy == null) return null;
    final updated = policy['updatedAt'] as String?;
    return PrivacyPolicy(
      version: policy['version'] as String? ?? '',
      body: policy['body'] as String? ?? '',
      updatedAt: updated != null ? DateTime.tryParse(updated) : null,
    );
  }
}
