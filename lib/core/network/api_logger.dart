import 'dart:convert';

import 'package:flutter/foundation.dart';

abstract final class ApiLogger {
  static const _sensitiveKeys = {
    'password',
    'current_password',
    'new_password',
    'confirm_password',
    'access_token',
    'token',
    'authorization',
    'device_token',
  };

  static void request({
    required String method,
    required Uri uri,
    Map<String, Object?>? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('┌─ API REQUEST ─────────────────────────');
    debugPrint('│ $method $uri');
    if (body != null) {
      debugPrint('│ ${jsonEncode(_redact(body))}');
    }
    debugPrint('└───────────────────────────────────────');
  }

  static void response({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    if (!kDebugMode) return;

    debugPrint('┌─ API RESPONSE ────────────────────────');
    debugPrint('│ $method $uri [$statusCode]');
    try {
      final decoded = jsonDecode(body);
      debugPrint('│ ${jsonEncode(_redactValue(decoded))}');
    } on Object {
      debugPrint('│ $body');
    }
    debugPrint('└───────────────────────────────────────');
  }

  static Map<String, Object?> _redact(Map<String, Object?> value) => {
        for (final entry in value.entries)
          entry.key: _sensitiveKeys.contains(entry.key.toLowerCase())
              ? '***'
              : _redactValue(entry.value),
      };

  static Object? _redactValue(Object? value) {
    if (value is Map) {
      return _redact(value.map((key, value) => MapEntry('$key', value)));
    }
    if (value is List) return value.map(_redactValue).toList();
    return value;
  }
}
