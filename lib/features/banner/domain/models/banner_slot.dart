/// 홈 배너 슬롯 도메인 엔티티.
class BannerSlot {
  final int slot;
  final String imageUrl;
  final String? linkUrl;

  const BannerSlot({
    required this.slot,
    required this.imageUrl,
    this.linkUrl,
  });
}
