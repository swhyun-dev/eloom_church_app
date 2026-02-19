import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_models.dart';

final notificationProvider = Provider<List<NoticeItem>>((ref) {
  // ✅ 더미 데이터(예시 API 결과라고 가정)
  return [
    NoticeItem(
      id: 'n1',
      type: NoticeType.ministry,
      message: '신청하신 사역이 승인되었습니다!',
      createdAt: DateTime(2026, 1, 27, 13, 36),
      route: '/ministry?tab=1',
      requiresLogin: true,
    ),
    NoticeItem(
      id: 'n2',
      type: NoticeType.worship,
      message: '주일 저녁 예배가 시작되었습니다.',
      createdAt: DateTime(2026, 1, 25, 19, 15),
      route: '/sermon',
      requiresLogin: false,
    ),
    NoticeItem(
      id: 'n3',
      type: NoticeType.cell,
      message: '현승우 성도님의 기도가 등록되었습니다.',
      createdAt: DateTime(2026, 1, 25, 15, 48),
      route: '/cell?tab=0',
      requiresLogin: true,
    ),
    NoticeItem(
      id: 'n4',
      type: NoticeType.cell,
      message: '구역게시판에 공지가 등록되었습니다.',
      createdAt: DateTime(2026, 1, 25, 14, 24),
      route: '/cell?tab=1',
      requiresLogin: true,
    ),
    NoticeItem(
      id: 'n5',
      type: NoticeType.cafe,
      message: '주문하신 음료가 완성되었습니다!',
      createdAt: DateTime(2026, 1, 25, 12, 37),
      route: '/cafe?tab=3',
      requiresLogin: true,
    ),
    NoticeItem(
      id: 'n6',
      type: NoticeType.worship,
      message: '주일 2부 예배가 시작되었습니다.',
      createdAt: DateTime(2026, 1, 25, 10, 50),
      route: '/sermon',
      requiresLogin: false,
    ),
    NoticeItem(
      id: 'n7',
      type: NoticeType.worship,
      message: '주일 1부 예배가 시작되었습니다.',
      createdAt: DateTime(2026, 1, 25, 8, 50),
      route: '/sermon',
      requiresLogin: false,
    ),
  ];
});
