class SermonDto {
  final int id;
  final String category;
  final String title;
  final String? speaker;
  final String? bibleText;
  final String preachedAt;
  final String? youtubeId;
  final String? thumbnailUrl;

  const SermonDto({
    required this.id,
    required this.category,
    required this.title,
    required this.preachedAt,
    this.speaker,
    this.bibleText,
    this.youtubeId,
    this.thumbnailUrl,
  });

  factory SermonDto.fromJson(Map<String, dynamic> j) => SermonDto(
        id: j['id'] as int,
        category: j['category'] as String? ?? 'SUNDAY',
        title: j['title'] as String? ?? '',
        speaker: j['speaker'] as String?,
        bibleText: j['bibleText'] as String?,
        preachedAt: j['preachedAt'] as String,
        youtubeId: j['youtubeId'] as String?,
        thumbnailUrl: j['thumbnailUrl'] as String?,
      );
}
