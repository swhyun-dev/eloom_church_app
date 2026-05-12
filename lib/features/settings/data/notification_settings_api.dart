import '../../../services/api_service.dart';

class NotificationSettingsApi {
  NotificationSettingsApi();

  final ApiService _api = ApiService();

  /// GET /api/v1/notification-settings/me
  Future<Map<String, bool>> fetchMine() async {
    final data = await _api.get('/api/v1/notification-settings/me');
    final settings = data['settings'] as Map<String, dynamic>? ?? const {};
    return settings.map((k, v) => MapEntry(k, v == true));
  }

  /// PATCH /api/v1/notification-settings/me
  Future<Map<String, bool>> update(Map<String, bool> patch) async {
    final data = await _api.patch('/api/v1/notification-settings/me', patch);
    final settings = data['settings'] as Map<String, dynamic>? ?? const {};
    return settings.map((k, v) => MapEntry(k, v == true));
  }
}
