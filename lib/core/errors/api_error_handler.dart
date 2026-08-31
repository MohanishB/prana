import 'dart:async';
import 'dart:io';

import 'app_exception.dart';

abstract final class ApiErrorHandler {
  static AppException normalize(
    Object error, {
    StackTrace? stackTrace,
    AppErrorType fallback = AppErrorType.generic,
  }) {
    if (error is AppException) return error;
    if (error is SocketException || error is HandshakeException) {
      return AppException(
        AppErrorType.noInternet,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (error is TimeoutException) {
      return AppException(
        AppErrorType.timeout,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (error is FormatException) {
      return AppException(
        AppErrorType.invalidResponse,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return AppException(
      fallback,
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
