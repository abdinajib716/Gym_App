class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  const ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiErrorType.unknown,
  });

  @override
  String toString() => message;
}

enum ApiErrorType {
  network,
  timeout,
  authentication,
  authorization,
  notFound,
  validation,
  server,
  unexpectedResponse,
  unknown,
}
