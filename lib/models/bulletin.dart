class Bulletin {
  final int id;
  final String title;
  final DateTime date;
  final String thumbUrl; // 이미지 URL(더미)
  final List<String> imageUrls;
  final String? pdfUrl;

  Bulletin({
    required this.id,
    required this.title,
    required this.date,
    required this.thumbUrl,
    required this.imageUrls,
    this.pdfUrl,
  });
}
