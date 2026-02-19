import '../domain/bible_service.dart';
import '../domain/models/bible_chapter.dart';
import 'providers/bible_api_com_provider.dart';
import 'mappers/bible_api_com_mapper.dart';
import 'cache/bible_cache.dart';

class BibleRepositoryImpl implements BibleService {
  final BibleApiComProvider provider;
  final BibleCache cache;

  BibleRepositoryImpl({
    required this.provider,
    required this.cache,
  });

  String _cacheKey(String book, int chapter, String tr) => '$book/$chapter/$tr';

  @override
  Future<BibleChapter> getChapter({
    required String book,
    required int chapter,
    required String translationId,
  }) async {
    final key = _cacheKey(book, chapter, translationId);
    final cached = cache.get(key);
    if (cached != null) return cached;

    final dto = await provider.fetch('$book $chapter', translationId: translationId);
    final chapterModel = BibleApiComMapper.toChapter(dto: dto, book: book, chapter: chapter);

    cache.set(key, chapterModel);
    return chapterModel;
  }

  @override
  Future<BibleChapter> getVerseRange({
    required String book,
    required int chapter,
    required int startVerse,
    required int endVerse,
    required String translationId,
  }) async {
    // bible-api.com은 범위도 지원 (ex: John 3:16-18)
    final dto = await provider.fetch(
      '$book $chapter:$startVerse-$endVerse',
      translationId: translationId,
    );
    return BibleApiComMapper.toChapter(dto: dto, book: book, chapter: chapter);
  }
}
