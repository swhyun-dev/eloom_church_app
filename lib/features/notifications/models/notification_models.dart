enum NoticeType {
  ministry('사역알림'),
  worship('예배알림'),
  cell('구역알림'),
  cafe('카페알림'),
  general('알림');

  final String label;
  const NoticeType(this.label);
}

class NoticeItem {
  final String id;
  final NoticeType type;
  final String message;
  final DateTime createdAt;

  /// 눌렀을 때 이동할 라우트 (go_router)
  final String route;

  /// 해당 화면이 로그인 필요한 경우
  final bool requiresLogin;

  const NoticeItem({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.route,
    required this.requiresLogin,
  });
}
