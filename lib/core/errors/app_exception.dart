enum AppErrorType {
  noInternet,
  timeout,
  invalidResponse,
  invalidCredentials,
  accountInactive,
  refreshWindowExpired,
  unauthorized,
  forbidden,
  courseNotAssigned,
  courseNotFound,
  chapterNotFound,
  quizNotAvailable,
  incompleteQuizAnswers,
  quizAlreadySubmitted,
  profileNotFound,
  currentPasswordIncorrect,
  photoUpload,
  validation,
  server,
  libraryLoad,
  librarySearch,
  libraryConfiguration,
  downloadFailed,
  fileOpenFailed,
  fileNotDownloaded,
  videoPlayback,
  videoProviderUnsupported,
  /// A purchase / booking rule the server explains in its own words
  /// (already enrolled, invalid coupon, ...): shown as [AppException.serverMessage].
  checkout,
  generic,
}

class AppException implements Exception {
  const AppException(
    this.type, {
    this.cause,
    this.stackTrace,
    this.errorCode,
    this.serverMessage,
  });

  final AppErrorType type;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? errorCode;

  /// The `message` the server sent (used by [AppErrorType.checkout]).
  final String? serverMessage;
}
