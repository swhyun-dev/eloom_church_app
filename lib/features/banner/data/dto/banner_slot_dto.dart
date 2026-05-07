class BannerSlotDto {
  final int slot;
  final String imageUrl;
  final String? linkUrl;

  const BannerSlotDto({
    required this.slot,
    required this.imageUrl,
    this.linkUrl,
  });

  factory BannerSlotDto.fromJson(Map<String, dynamic> j) => BannerSlotDto(
        slot: j['slot'] as int,
        imageUrl: j['imageUrl'] as String,
        linkUrl: j['linkUrl'] as String?,
      );
}
