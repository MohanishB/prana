import '../errors/api_error_handler.dart';
import '../errors/app_exception.dart';
import 'api_client.dart';

/// Calls an endpoint and returns the `data` object of the standard envelope.
/// [authenticated] false = no token (public endpoints); true = student endpoints.
Future<Map<String, dynamic>> fetchData(
  ApiClient api,
  String path, {
  bool authenticated = false,
  Map<String, Object?> query = const {},
}) async {
  try {
    final response = await api.get(
      path,
      query: query,
      authenticated: authenticated,
    );
    return _dataOf(response);
  } on Object catch (error, stackTrace) {
    throw ApiErrorHandler.normalize(
      error,
      stackTrace: stackTrace,
      fallback: AppErrorType.invalidResponse,
    );
  }
}

/// POST version of [fetchData].
Future<Map<String, dynamic>> postData(
  ApiClient api,
  String path, {
  bool authenticated = false,
  Map<String, Object?> body = const {},
}) async {
  try {
    final response = await api.post(
      path,
      body: body,
      authenticated: authenticated,
    );
    return _dataOf(response);
  } on Object catch (error, stackTrace) {
    throw ApiErrorHandler.normalize(
      error,
      stackTrace: stackTrace,
      fallback: AppErrorType.invalidResponse,
    );
  }
}

Map<String, dynamic> _dataOf(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is! Map<String, dynamic>) throw const FormatException();
  return data;
}

/// Runs [build] and reports a malformed response as an invalid-response error.
T parseData<T>(T Function() build) {
  try {
    return build();
  } on Object catch (error, stackTrace) {
    throw ApiErrorHandler.normalize(
      error,
      stackTrace: stackTrace,
      fallback: AppErrorType.invalidResponse,
    );
  }
}
