import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small things the push feature remembers on the phone.
abstract interface class PushPreferences {
  /// How many times the "Turn on notifications" screen was shown.
  Future<int> promptCount();
  Future<DateTime?> lastPromptAt();
  Future<void> recordPrompt(DateTime when);

  /// True once the phone's own permission question was shown.
  Future<bool> systemAsked();
  Future<void> setSystemAsked();

  /// A random id of this installation, used as a stand-in when no push token exists.
  Future<String> installId();

  /// The last token this phone told the server about.
  Future<String?> lastToken();
  Future<void> setLastToken(String? token);
}

final class SecurePushPreferences implements PushPreferences {
  SecurePushPreferences(this._storage);

  final FlutterSecureStorage _storage;

  static const _count = 'prana_push_prompt_count';
  static const _last = 'prana_push_last_prompt';
  static const _asked = 'prana_push_system_asked';
  static const _install = 'prana_push_install_id';
  static const _token = 'prana_push_last_token';

  @override
  Future<int> promptCount() async =>
      int.tryParse(await _storage.read(key: _count) ?? '') ?? 0;

  @override
  Future<DateTime?> lastPromptAt() async {
    final millis = int.tryParse(await _storage.read(key: _last) ?? '');
    return millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<void> recordPrompt(DateTime when) async {
    final count = await promptCount();
    await _storage.write(key: _count, value: '${count + 1}');
    await _storage.write(
      key: _last,
      value: '${when.millisecondsSinceEpoch}',
    );
  }

  @override
  Future<bool> systemAsked() async =>
      await _storage.read(key: _asked) == '1';

  @override
  Future<void> setSystemAsked() => _storage.write(key: _asked, value: '1');

  @override
  Future<String> installId() async {
    final existing = await _storage.read(key: _install);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _storage.write(key: _install, value: id);
    return id;
  }

  @override
  Future<String?> lastToken() => _storage.read(key: _token);

  @override
  Future<void> setLastToken(String? token) => token == null
      ? _storage.delete(key: _token)
      : _storage.write(key: _token, value: token);
}
