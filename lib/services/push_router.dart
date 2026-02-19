import 'package:go_router/go_router.dart';
import 'push_payload.dart';

class PushRouter {
  static void handle({
    required GoRouter router,
    required Map<String, dynamic> data,
  }) {
    final payload = PushPayload.fromMap(data);
    router.go(payload.route);
  }
}
