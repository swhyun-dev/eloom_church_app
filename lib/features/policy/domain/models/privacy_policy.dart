class PrivacyPolicy {
  final String version;
  final String body;
  final DateTime? updatedAt;

  const PrivacyPolicy({
    required this.version,
    required this.body,
    this.updatedAt,
  });
}
