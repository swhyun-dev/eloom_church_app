// lib/dummy/dummy.data.dart
import '../models/board_post.dart';
import '../models/edu_event.dart';
import '../models/bulletin.dart';
import '../models/church_registry_person.dart';

class DummyData {
  /// =========================================
  /// ✅ 현재 로그인 사용자(더미)
  /// =========================================
  static const String currentUserName = '홍길동';

  /// 개인 기도제목 "공개 상태" (내 설정 더미)
  static const bool currentUserPrayerPublic = true;

  /// =========================================
  /// ✅ 교적(구역 배정) 더미
  /// =========================================
  static final churchPersons = <ChurchRegistryPerson>[
    ChurchRegistryPerson(
      name: '홍길동',
      phone: '01012345678',
      position: '집사',
      parish: '1교구',
      district: '3구역',
      isDistrictLeader: true,
    ),
    ChurchRegistryPerson(
      name: '김영희',
      phone: '01022223333',
      position: '권사',
      parish: '1교구',
      district: '3구역',
      isDistrictLeader: false,
    ),
    ChurchRegistryPerson(
      name: '박철수',
      phone: '01099998888',
      position: '성도',
      parish: '1교구',
      district: '3구역',
      isDistrictLeader: false,
    ),
  ];

  /// =========================================
  /// ✅ Cell(구역모임) helper (UI/권한 판단용)
  /// =========================================
  static ChurchRegistryPerson? get me {
    for (final p in churchPersons) {
      if (p.name == currentUserName) return p;
    }
    return null;
  }

  static bool get isAssigned => me != null;
  static bool get isLeader => me?.isDistrictLeader == true;

  /// cellKey = '1교구|3구역'
  static String? get cellKey {
    final m = me;
    if (m == null) return null;
    return '${m.parish}|${m.district}';
  }

  static ChurchRegistryPerson? get cellLeader {
    final m = me;
    if (m == null) return null;
    for (final p in churchPersons) {
      if (p.parish == m.parish && p.district == m.district && p.isDistrictLeader == true) {
        return p;
      }
    }
    return null;
  }

  /// =========================================
  /// ✅ 구역 공지 더미
  /// =========================================
  static final cellNoticesByCellKey = <String, List<CellNoticeDummy>>{
    '1교구|3구역': [
      CellNoticeDummy(
        id: 'n1',
        date: DateTime(2026, 1, 27),
        title: '구역 모임 장소 변경 공지',
        content: '이번 주 구역 모임 장소가 변경되었습니다.\n\n장소: 2층 소그룹실 B\n시간: 오후 7시 30분\n\n착오 없으시길 바랍니다.',
      ),
      CellNoticeDummy(
        id: 'n2',
        date: DateTime(2026, 1, 22),
        title: '2026년도 공과책 구입 안내',
        content: '2026년도 구역 모임 공과책 구매를 희망하시는 성도님들께서는\n아래 계좌로 5,000원을 입금해주시기 바랍니다.\n\n카카오뱅크 3333-04-4704663 홍길동',
      ),
      CellNoticeDummy(
        id: 'n3',
        date: DateTime(2025, 12, 27),
        title: '동계 방학 공지',
        content: '동계 방학 기간 동안 구역 모임은 쉬어갑니다.\n\n기간: 12/30 ~ 1/10\n재개: 1/13(화)부터',
      ),
    ],
  };

  /// =========================================
  /// ✅ 구역원 기도제목 더미
  /// - 규칙: 공개(isPublic) && 같은 구역일 때만 공개
  /// =========================================
  static final cellPrayersByCellKey = <String, List<CellPrayerDummy>>{
    '1교구|3구역': [
      CellPrayerDummy(
        id: 'p1',
        userName: '홍길동',
        date: DateTime(2026, 1, 27),
        title: '가족의 건강을 위한 기도',
        content:
        '우리 가족이 육신의 연약함을 버리고 영과 육이 강건하게 해주세요.\n\n1. ○○○ 자녀의 입시를 낙심하지 않게 해주세요.\n2. ○○○의 병원에 정상으로 돌아오도록 치유해주시고,\n   주님이 주신 육체를 잘 관리하게 해주세요.',
        isPublic: true,
      ),
      CellPrayerDummy(
        id: 'p2',
        userName: '김영희',
        date: DateTime(2026, 1, 17),
        title: '직장/진로를 위한 기도',
        content: '새로운 프로젝트 가운데 지혜를 주시고,\n건강을 지켜주세요.',
        isPublic: true,
      ),
      CellPrayerDummy(
        id: 'p3',
        userName: '박철수',
        date: DateTime(2026, 1, 10),
        title: '부모님의 건강',
        content: '부모님의 관절 통증이 줄어들고,\n평안한 일상이 회복되게 해주세요.',
        isPublic: false, // 비공개 -> 구역원에게 노출 X
      ),
    ],
  };

  /// =========================================
  /// ✅ 기존 더미(그대로 유지)
  /// =========================================
  static final boardPosts = <BoardPost>[
    BoardPost(
      id: 1,
      type: 'news',
      title: '이룸교회 앱(APP)이 출시하였습니다.',
      content: '이룸교회 앱이 정식 출시되었습니다. 공지/주보/설교/성경읽기 기능을 사용해보세요.',
      createdAt: DateTime(2026, 1, 12),
      pinned: true,
    ),
    BoardPost(
      id: 2,
      type: 'news',
      title: '2026 신년 감사 특별 새벽기도회 안내',
      content: '기간: 1/15~1/21, 장소: 본당, 시간: 오전 5시 30분',
      createdAt: DateTime(2026, 1, 12),
    ),
    BoardPost(
      id: 3,
      type: 'news',
      title: '2026년도 구역모임 운영이 변경됩니다',
      content: '구역 편성 및 운영 방식이 일부 변경됩니다. 자세한 내용은 공지를 확인해주세요.',
      createdAt: DateTime(2026, 1, 10),
    ),
    BoardPost(
      id: 11,
      type: 'notice',
      title: '[모집] 주일 주차 봉사 지원 요청',
      content: '주일 오전 예배 전후 주차 봉사자를 모집합니다. 가능하신 분은 신청해주세요.',
      createdAt: DateTime(2026, 1, 13),
      pinned: true,
      important: true,
      target: '전체',
      startAt: DateTime(2026, 1, 13),
      endAt: DateTime(2026, 1, 20),
    ),
    BoardPost(
      id: 12,
      type: 'notice',
      title: '[공지] 7남전도회 월례 모임 안내',
      content: '일시: 1/18(토) 19:00, 장소: 3층 소그룹실',
      createdAt: DateTime(2026, 1, 12),
      important: true,
      target: '7남전도회',
      startAt: DateTime(2026, 1, 12),
      endAt: DateTime(2026, 1, 18),
    ),
    BoardPost(
      id: 13,
      type: 'notice',
      title: '[안내] 수요예배 찬양팀 모집',
      content: '수요예배 찬양팀(싱어/악기)을 모집합니다. 담당자에게 문의해주세요.',
      createdAt: DateTime(2026, 1, 9),
      target: '청년부',
    ),
  ];

  static final eduEvents = <EduEvent>[
    EduEvent(
      id: 101,
      title: '새가족 교육 1주차',
      description: '교회 소개/예배 안내/교회 생활 기본',
      startAt: DateTime(2026, 1, 18, 13, 0),
      endAt: DateTime(2026, 1, 18, 14, 30),
      location: '교육관 2층',
      host: '새가족부',
      applyUrl: null,
    ),
    EduEvent(
      id: 102,
      title: '제자훈련 OT',
      description: '훈련 안내 및 커리큘럼 소개',
      startAt: DateTime(2026, 1, 25, 16, 0),
      endAt: DateTime(2026, 1, 25, 17, 0),
      location: '본관 3층',
      host: '훈련부',
      applyUrl: 'https://example.com/apply',
    ),
    EduEvent(
      id: 103,
      title: '성경통독 세미나',
      description: '통독 방법/일정/도구 소개',
      startAt: DateTime(2026, 1, 20, 19, 30),
      endAt: DateTime(2026, 1, 20, 21, 0),
      location: '본당',
      host: '교육부',
    ),
  ];

  static final bulletins = <Bulletin>[
    Bulletin(
      id: 201,
      title: '2026년 1월 2주 주보',
      date: DateTime(2026, 1, 11),
      thumbUrl: 'https://picsum.photos/seed/bulletin201/800/500',
      imageUrls: [
        'https://picsum.photos/seed/bulletin201a/1200/1600',
        'https://picsum.photos/seed/bulletin201b/1200/1600',
      ],
      pdfUrl: null,
    ),
    Bulletin(
      id: 202,
      title: '2026년 1월 3주 주보',
      date: DateTime(2026, 1, 18),
      thumbUrl: 'https://picsum.photos/seed/bulletin202/800/500',
      imageUrls: [
        'https://picsum.photos/seed/bulletin202a/1200/1600',
      ],
    ),
    Bulletin(
      id: 203,
      title: '2026년 1월 4주 주보',
      date: DateTime(2026, 1, 25),
      thumbUrl: 'https://picsum.photos/seed/bulletin203/800/500',
      imageUrls: [
        'https://picsum.photos/seed/bulletin203a/1200/1600',
      ],
    ),
  ];
}

class CellNoticeDummy {
  final String id;
  final DateTime date;
  final String title;
  final String content;

  const CellNoticeDummy({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
  });
}

class CellPrayerDummy {
  final String id;
  final String userName;
  final DateTime date;
  final String title;
  final String content;
  final bool isPublic;

  const CellPrayerDummy({
    required this.id,
    required this.userName,
    required this.date,
    required this.title,
    required this.content,
    required this.isPublic,
  });
}
