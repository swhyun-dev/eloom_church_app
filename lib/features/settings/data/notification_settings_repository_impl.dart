import '../domain/models/notification_settings.dart';
import '../domain/models/notification_topic.dart';
import '../domain/notification_settings_repository.dart';
import 'notification_settings_api.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final NotificationSettingsApi api;

  NotificationSettingsRepositoryImpl({required this.api});

  NotificationSettings _toDomain(Map<String, bool> raw) {
    final values = <NotificationTopic, bool>{};
    for (final t in NotificationTopic.values) {
      // 키가 누락되면 기본 ON
      values[t] = raw[t.apiKey] ?? true;
    }
    return NotificationSettings(values);
  }

  @override
  Future<NotificationSettings> fetchMine() async {
    final raw = await api.fetchMine();
    return _toDomain(raw);
  }

  @override
  Future<NotificationSettings> update(Map<NotificationTopic, bool> patch) async {
    final body = <String, bool>{
      for (final entry in patch.entries) entry.key.apiKey: entry.value,
    };
    final raw = await api.update(body);
    return _toDomain(raw);
  }
}
