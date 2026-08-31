import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'user_session.dart';

abstract interface class SessionStore {
  Future<UserSession?> read();
  Future<void> save(UserSession session);
  Future<void> clear();
}

final class SecureSessionStore implements SessionStore {
  SecureSessionStore(this._storage);
  final FlutterSecureStorage _storage;

  static const _prefix = 'prana_session_';

  @override
  Future<UserSession?> read() async {
    final all = await _storage.readAll();
    final values = <String, String>{};
    for (final entry in all.entries) {
      if (entry.key.startsWith(_prefix)) {
        values[entry.key.substring(_prefix.length)] = entry.value;
      }
    }
    if (values['student_id'] == null || values['access_token'] == null) {
      return null;
    }
    try {
      return UserSession.fromMap(values);
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(UserSession session) async {
    await clear();
    for (final entry in session.toMap().entries) {
      await _storage.write(key: '$_prefix${entry.key}', value: entry.value);
    }
  }

  @override
  Future<void> clear() async {
    final all = await _storage.readAll();
    for (final key in all.keys.where((key) => key.startsWith(_prefix))) {
      await _storage.delete(key: key);
    }
  }
}
