enum AppErrorType {
  noInternet,
  timeout,
  invalidResponse,
  libraryLoad,
  librarySearch,
  generic,
}

class AppException implements Exception {
  const AppException(
    this.type, {
    this.cause,
    this.stackTrace,
  });

  final AppErrorType type;
  final Object? cause;
  final StackTrace? stackTrace;
}
