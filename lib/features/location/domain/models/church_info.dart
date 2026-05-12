class ChurchInfo {
  final String address;
  final String? addressDetail;
  final String? phone;
  final String? fax;
  final String? email;
  final String? parkingGuide;
  final String? trafficGuide;
  final double? mapLatitude;
  final double? mapLongitude;
  final String? naverMapUrl;
  final String? kakaoMapUrl;

  const ChurchInfo({
    required this.address,
    this.addressDetail,
    this.phone,
    this.fax,
    this.email,
    this.parkingGuide,
    this.trafficGuide,
    this.mapLatitude,
    this.mapLongitude,
    this.naverMapUrl,
    this.kakaoMapUrl,
  });

  String get fullAddress {
    if (addressDetail == null || addressDetail!.isEmpty) return address;
    return '$address $addressDetail';
  }
}
