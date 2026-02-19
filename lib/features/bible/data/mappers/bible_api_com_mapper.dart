import '../../domain/models/bible_chapter.dart';
import '../../domain/models/bible_ref.dart';
import '../../domain/models/bible_verse.dart';
import '../dto/bible_api_com_dto.dart';

class BibleApiComMapper {
  static BibleChapter toChapter({
    required BibleApiComResponseDto dto,
    required String book,
    required int chapter,
  }) {
    return BibleChapter(
      ref: BibleRef(book: book, chapter: chapter),
      translationId: dto.translationId,
      translationName: dto.translationName,
      verses: dto.verses
          .map((v) => BibleVerse(verse: v.verse, text: v.text))
          .toList(),
    );
  }
}
