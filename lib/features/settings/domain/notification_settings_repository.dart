import 'models/notification_settings.dart';
import 'models/notification_topic.dart';

abstract class NotificationSettingsRepository {
  Future<NotificationSettings> fetchMine();

  /// 부분 갱신. 전송하지 않은 토픽은 서버 측에서 유지된다.
  Future<NotificationSettings> update(Map<NotificationTopic, bool> patch);
}
