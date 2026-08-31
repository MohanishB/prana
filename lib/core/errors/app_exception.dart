enum AppErrorType {
  noInternet,
  timeout,
  invalidResponse,
  invalidCredentials,
  accountInactive,
  unauthorized,
  forbidden,
  courseNotAssigned,
  courseNotFound,
  validation,
  server,
  libraryLoad,
  librarySearch,
  downloadFailed,
  fileOpenFailed,
  fileNotDownloaded,
  videoPlayback,
  videoProviderUnsupported,
  generic,
}

class AppException implements Exception {
  const AppException(
    this.type, {
    this.cause,
    this.stackTrace,
    this.errorCode,
  });

  final AppErrorType type;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? errorCode;
}
