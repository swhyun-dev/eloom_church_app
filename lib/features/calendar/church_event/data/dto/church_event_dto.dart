class ChurchEventDto {
  final int id;
  final String category;
  final String title;
  final String? description;
  final String startAt;
  final String endAt;
  final String? location;

  const ChurchEventDto({
    required this.id,
    required this.category,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.description,
    this.location,
  });

  factory ChurchEventDto.fromJson(Map<String, dynamic> j) => ChurchEventDto(
        id: j['id'] as int,
        category: j['category'] as String? ?? 'WORSHIP',
        title: j['title'] as String? ?? '',
        description: j['description'] as String?,
        startAt: j['startAt'] as String,
        endAt: j['endAt'] as String,
        location: j['location'] as String?,
      );
}
