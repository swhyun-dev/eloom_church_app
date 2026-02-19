import '../../domain/models/bible_chapter.dart';

class BibleCache {
  final _map = <String, BibleChapter>{};

  BibleChapter? get(String key) => _map[key];
  void set(String key, BibleChapter value) => _map[key] = value;

  void clear() => _map.clear();
}
