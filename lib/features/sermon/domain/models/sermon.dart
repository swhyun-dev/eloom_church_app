import 'sermon_category.dart';

class Sermon {
  final int id;
  final SermonCategory category;
  final String title;
  final String? speaker;
  final String? bibleText;
  final DateTime preachedAt;
  final String? youtubeId;
  final String? thumbnailUrl;

  const Sermon({
    required this.id,
    required this.category,
    required this.title,
    required this.preachedAt,
    this.speaker,
    this.bibleText,
    this.youtubeId,
    this.thumbnailUrl,
  });
}
