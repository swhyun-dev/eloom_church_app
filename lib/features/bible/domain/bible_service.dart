import 'models/bible_chapter.dart';

abstract class BibleService {
  Future<BibleChapter> getChapter({
    required String book,
    required int chapter,
    required String translationId,
  });

  Future<BibleChapter> getVerseRange({
    required String book,
    required int chapter,
    required int startVerse,
    required int endVerse,
    required String translationId,
  });
}
