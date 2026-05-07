/// 게시판 카테고리. 백엔드 enum 값과 1:1.
/// 라우트 파라미터(`type`)와의 매핑은 `fromRouteType` / `routeType` 사용.
enum BoardCategory {
  churchNews,
  meetingNotice,
  eduNotice,
  memberNews;

  /// 백엔드 API에서 사용하는 문자열.
  String get apiValue {
    switch (this) {
      case BoardCategory.churchNews:
        return 'CHURCH_NEWS';
      case BoardCategory.meetingNotice:
        return 'MEETING_NOTICE';
      case BoardCategory.eduNotice:
        return 'EDU_NOTICE';
      case BoardCategory.memberNews:
        return 'MEMBER_NEWS';
    }
  }

  /// 라우트의 `type` 파라미터(`/boards/:type`).
  String get routeType {
    switch (this) {
      case BoardCategory.churchNews:
        return 'news';
      case BoardCategory.meetingNotice:
        return 'notice';
      case BoardCategory.eduNotice:
        return 'edu';
      case BoardCategory.memberNews:
        return 'fellow';
    }
  }

  /// 화면 타이틀.
  String get title {
    switch (this) {
      case BoardCategory.churchNews:
        return '교회소식';
      case BoardCategory.meetingNotice:
        return '모임공지';
      case BoardCategory.eduNotice:
        return '교육일정';
      case BoardCategory.memberNews:
        return '교우동정';
    }
  }

  static BoardCategory fromRouteType(String type) {
    switch (type) {
      case 'notice':
        return BoardCategory.meetingNotice;
      case 'edu':
        return BoardCategory.eduNotice;
      case 'fellow':
        return BoardCategory.memberNews;
      case 'news':
      default:
        return BoardCategory.churchNews;
    }
  }

  static BoardCategory fromApiValue(String value) {
    switch (value) {
      case 'MEETING_NOTICE':
        return BoardCategory.meetingNotice;
      case 'EDU_NOTICE':
        return BoardCategory.eduNotice;
      case 'MEMBER_NEWS':
        return BoardCategory.memberNews;
      case 'CHURCH_NEWS':
      default:
        return BoardCategory.churchNews;
    }
  }
}
