import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../errors/api_error_handler.dart';
import '../errors/app_exception.dart';
import '../session/session_manager.dart';
import 'api_constants.dart';
import 'api_logger.dart';
import 'network_info.dart';

class ApiClient {
  ApiClient({
    required NetworkInfo networkInfo,
    required SessionManager sessionManager,
    HttpClient? httpClient,
  })  : _networkInfo = networkInfo,
        _sessionManager = sessionManager,
        _httpClient = httpClient ?? HttpClient();

  final NetworkInfo _networkInfo;
  final SessionManager _sessionManager;
  final HttpClient _httpClient;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, Object?> query = const {},
    bool authenticated = true,
  }) =>
      _send('GET', path, query: query, authenticated: authenticated);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, Object?> body = const {},
    bool authenticated = true,
    Set<String> acceptedErrorCodes = const {},
  }) =>
      _send(
        'POST',
        path,
        body: body,
        authenticated: authenticated,
        acceptedErrorCodes: acceptedErrorCodes,
      );

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?> query = const {},
    Map<String, Object?> body = const {},
    required bool authenticated,
    Set<String> acceptedErrorCodes = const {},
  }) async {
    if (!await _networkInfo.isConnected) {
      throw const AppException(AppErrorType.noInternet);
    }

    final session = _sessionManager.current;
    final effectiveQuery = <String, Object?>{...query};
    final effectiveBody = <String, Object?>{...body};

    if (authenticated) {
      if (session == null) throw const AppException(AppErrorType.unauthorized);
      if (method == 'GET') {
        effectiveQuery.putIfAbsent('student_id', () => session.studentId);
      } else {
        effectiveBody.putIfAbsent('student_id', () => session.studentId);
      }
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
      queryParameters: effectiveQuery.isEmpty
          ? null
          : effectiveQuery.map((key, value) => MapEntry(key, '$value')),
    );

    ApiLogger.request(
      method: method,
      uri: uri,
      body: effectiveBody.isEmpty ? null : effectiveBody,
    );

    try {
      final request = method == 'GET'
          ? await _httpClient.getUrl(uri)
          : await _httpClient.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      if (authenticated) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer ${session!.accessToken}',
        );
      }
      if (method != 'GET') request.write(jsonEncode(effectiveBody));

      final response = await request.close().timeout(ApiConstants.requestTimeout);
      final raw = await utf8.decoder.bind(response).join();
      ApiLogger.response(
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: raw,
      );

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const AppException(AppErrorType.invalidResponse);
      }

      final status = decoded['status'];
      if (status != true) {
        final code = decoded['error_code']?.toString();
        if (code != null && acceptedErrorCodes.contains(code)) {
          return decoded;
        }
        final exception = AppException(
          _mapError(code, response.statusCode),
          errorCode: code,
        );
        if (_isTokenError(code, response.statusCode)) {
          await _sessionManager.clear();
        }
        throw exception;
      }
      return decoded;
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(error, stackTrace: stackTrace);
    }
  }

  bool _isTokenError(String? code, int statusCode) =>
      statusCode == HttpStatus.unauthorized &&
      (code == 'TOKEN_MISSING' || code == 'TOKEN_INVALID');

  AppErrorType _mapError(String? code, int statusCode) {
    return switch (code) {
      'INVALID_CREDENTIALS' => AppErrorType.invalidCredentials,
      'ACCOUNT_INACTIVE' => AppErrorType.accountInactive,
      'TOKEN_MISSING' || 'TOKEN_INVALID' => AppErrorType.unauthorized,
      'STUDENT_ID_MISMATCH' => AppErrorType.forbidden,
      'VALIDATION_ERROR' => AppErrorType.validation,
      'COURSE_NOT_ASSIGNED' => AppErrorType.courseNotAssigned,
      'COURSE_NOT_FOUND' => AppErrorType.courseNotFound,
      'CHAPTER_NOT_FOUND' => AppErrorType.chapterNotFound,
      'QUIZ_NOT_AVAILABLE' => AppErrorType.quizNotAvailable,
      'INCOMPLETE_ANSWERS' => AppErrorType.incompleteQuizAnswers,
      'QUIZ_ALREADY_SUBMITTED' => AppErrorType.quizAlreadySubmitted,
      _ when statusCode >= 500 => AppErrorType.server,
      _ => AppErrorType.generic,
    };
  }
}
