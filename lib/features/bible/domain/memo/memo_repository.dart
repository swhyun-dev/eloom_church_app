import '../models/bible_memo.dart';

abstract class MemoRepository {
  Future<void> add(BibleMemo memo);
  Future<List<BibleMemo>> getAll(); // 최신순
  Future<void> delete(String id);
}
