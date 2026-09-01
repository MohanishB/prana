import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../errors/api_error_handler.dart';
import '../errors/app_exception.dart';
import '../session/session_manager.dart';
import '../session/user_session.dart';
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
      _send(
        'GET',
        path,
        query: query,
        authenticated: authenticated,
      );

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

  Future<UserSession> refreshSession([UserSession? session]) async {
    final current = session ?? _sessionManager.current;
    if (current == null) {
      throw const AppException(AppErrorType.unauthorized);
    }

    if (!current.isWithinRefreshWindow && current.isExpired) {
      await _sessionManager.clear();
      throw const AppException(
        AppErrorType.refreshWindowExpired,
        errorCode: 'REFRESH_WINDOW_EXPIRED',
      );
    }

    try {
      final json = await _send(
        'POST',
        ApiConstants.refreshToken,
        body: {
          'student_id': current.studentId,
          'token': current.accessToken,
        },
        authenticated: false,
        allowRefreshRetry: false,
        clearSessionOnTokenError: false,
      );

      final data = json['data'];
      if (data is! Map<String, dynamic>) {
        throw const AppException(AppErrorType.invalidResponse);
      }

      final token = data['access_token']?.toString().trim() ?? '';
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 0;
      if (token.isEmpty || expiresIn <= 0) {
        throw const AppException(AppErrorType.invalidResponse);
      }

      final refreshed = current.copyWith(
        accessToken: token,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      );
      await _sessionManager.setSession(refreshed);
      return refreshed;
    } on AppException catch (error) {
      if (_isTerminalRefreshError(error)) {
        await _sessionManager.clear();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, File> files = const {},
    bool authenticated = true,
  }) =>
      _postMultipart(
        path,
        fields: fields,
        files: files,
        authenticated: authenticated,
        allowRefreshRetry: true,
      );

  Future<Map<String, dynamic>> _postMultipart(
    String path, {
    required Map<String, String> fields,
    required Map<String, File> files,
    required bool authenticated,
    required bool allowRefreshRetry,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw const AppException(AppErrorType.noInternet);
    }

    var session = _sessionManager.current;
    if (authenticated) {
      if (session == null) {
        throw const AppException(AppErrorType.unauthorized);
      }
      if (session.isExpired) {
        session = await refreshSession(session);
      }
    }

    final effectiveFields = <String, String>{...fields};
    if (authenticated) {
      effectiveFields.putIfAbsent('student_id', () => '${session!.studentId}');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final logBody = <String, Object?>{
      ...effectiveFields,
      for (final entry in files.entries) entry.key: '<file>',
    };
    ApiLogger.request(method: 'POST', uri: uri, body: logBody);

    try {
      final boundary =
          '----prana${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';
      final request = await _httpClient.postUrl(uri);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      if (authenticated) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer ${session!.accessToken}',
        );
      }

      for (final entry in effectiveFields.entries) {
        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n',
        );
        request.write(entry.value);
        request.write('\r\n');
      }

      for (final entry in files.entries) {
        final file = entry.value;
        final fileName = file.uri.pathSegments.isEmpty
            ? 'upload'
            : file.uri.pathSegments.last;
        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; name="${entry.key}"; '
          'filename="$fileName"\r\n',
        );
        request.write(
          'Content-Type: ${_contentTypeForPath(file.path)}\r\n\r\n',
        );
        await request.addStream(file.openRead());
        request.write('\r\n');
      }
      request.write('--$boundary--\r\n');

      final response =
          await request.close().timeout(ApiConstants.requestTimeout);
      final raw = await utf8.decoder.bind(response).join();
      ApiLogger.response(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        body: raw,
      );

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const AppException(AppErrorType.invalidResponse);
      }

      if (decoded['status'] != true) {
        final code = decoded['error_code']?.toString();
        if (authenticated &&
            allowRefreshRetry &&
            _isTokenError(code, response.statusCode)) {
          await refreshSession(session);
          return _postMultipart(
            path,
            fields: fields,
            files: files,
            authenticated: authenticated,
            allowRefreshRetry: false,
          );
        }

        final exception = AppException(
          _mapError(code, response.statusCode),
          errorCode: code,
        );
        if (authenticated && _isTokenError(code, response.statusCode)) {
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

  String _contentTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, Object?> query = const {},
    Map<String, Object?> body = const {},
    required bool authenticated,
    Set<String> acceptedErrorCodes = const {},
    bool allowRefreshRetry = true,
    bool clearSessionOnTokenError = true,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw const AppException(AppErrorType.noInternet);
    }

    var session = _sessionManager.current;
    if (authenticated) {
      if (session == null) {
        throw const AppException(AppErrorType.unauthorized);
      }
      if (session.isExpired) {
        session = await refreshSession(session);
      }
    }

    final effectiveQuery = <String, Object?>{...query};
    final effectiveBody = <String, Object?>{...body};

    if (authenticated) {
      if (method == 'GET') {
        effectiveQuery.putIfAbsent('student_id', () => session!.studentId);
      } else {
        effectiveBody.putIfAbsent('student_id', () => session!.studentId);
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
      if (method != 'GET') {
        request.write(jsonEncode(effectiveBody));
      }

      final response =
          await request.close().timeout(ApiConstants.requestTimeout);
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

        if (authenticated &&
            allowRefreshRetry &&
            _isTokenError(code, response.statusCode)) {
          await refreshSession(session);
          return _send(
            method,
            path,
            query: query,
            body: body,
            authenticated: authenticated,
            acceptedErrorCodes: acceptedErrorCodes,
            allowRefreshRetry: false,
          );
        }

        if (code != null && acceptedErrorCodes.contains(code)) {
          return decoded;
        }

        final exception = AppException(
          _mapError(code, response.statusCode),
          errorCode: code,
        );
        if (clearSessionOnTokenError &&
            authenticated &&
            _isTokenError(code, response.statusCode)) {
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

  bool _isTerminalRefreshError(AppException error) =>
      error.type == AppErrorType.unauthorized ||
      error.type == AppErrorType.accountInactive ||
      error.type == AppErrorType.refreshWindowExpired ||
      error.errorCode == 'STUDENT_NOT_FOUND' ||
      error.errorCode == 'REFRESH_WINDOW_EXPIRED';

  AppErrorType _mapError(String? code, int statusCode) {
    return switch (code) {
      'INVALID_CREDENTIALS' => AppErrorType.invalidCredentials,
      'ACCOUNT_INACTIVE' => AppErrorType.accountInactive,
      'REFRESH_WINDOW_EXPIRED' => AppErrorType.refreshWindowExpired,
      'TOKEN_MISSING' || 'TOKEN_INVALID' => AppErrorType.unauthorized,
      'STUDENT_ID_MISMATCH' => AppErrorType.forbidden,
      'VALIDATION_ERROR' => AppErrorType.validation,
      'COURSE_NOT_ASSIGNED' => AppErrorType.courseNotAssigned,
      'COURSE_NOT_FOUND' => AppErrorType.courseNotFound,
      'CHAPTER_NOT_FOUND' => AppErrorType.chapterNotFound,
      'QUIZ_NOT_AVAILABLE' => AppErrorType.quizNotAvailable,
      'INCOMPLETE_ANSWERS' => AppErrorType.incompleteQuizAnswers,
      'QUIZ_ALREADY_SUBMITTED' => AppErrorType.quizAlreadySubmitted,
      'PROFILE_NOT_FOUND' => AppErrorType.profileNotFound,
      'CURRENT_PASSWORD_INCORRECT' => AppErrorType.currentPasswordIncorrect,
      'PHOTO_UPLOAD_ERROR' => AppErrorType.photoUpload,
      _ when statusCode >= 500 => AppErrorType.server,
      _ => AppErrorType.generic,
    };
  }
}
