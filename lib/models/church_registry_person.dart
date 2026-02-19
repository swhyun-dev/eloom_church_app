class ChurchRegistryPerson {
  final String name;
  final String phone; // 숫자만(01012345678)
  final String position; // 직분
  final String parish;   // 교구
  final String district; // 구역
  final bool isDistrictLeader; // 구역장 뱃지 표시용

  const ChurchRegistryPerson({
    required this.name,
    required this.phone,
    required this.position,
    required this.parish,
    required this.district,
    required this.isDistrictLeader,
  });
}
