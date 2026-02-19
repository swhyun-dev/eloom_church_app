class BibleApiUserException implements Exception {
  final String message;
  final int? statusCode;
  final Object? original;

  BibleApiUserException(
      this.message, {
        this.statusCode,
        this.original,
      });

  @override
  String toString() => message;
}