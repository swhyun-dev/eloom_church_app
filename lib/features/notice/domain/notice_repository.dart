import 'models/notice.dart';

/// 공지 도메인 Repository 인터페이스.
/// 구현체는 `data/notice_repository_impl.dart` 참고.
abstract class NoticeRepository {
  Future<List<Notice>> fetchAll();
}
