import 'package:hive/hive.dart';
import '../../domain/memo/memo_repository.dart';
import '../../domain/models/bible_memo.dart';

class HiveMemoRepository implements MemoRepository {
  final Box<BibleMemo> box;
  HiveMemoRepository(this.box);

  @override
  Future<void> add(BibleMemo memo) async {
    await box.put(memo.id, memo);
  }

  @override
  Future<List<BibleMemo>> getAll() async {
    final list = box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
