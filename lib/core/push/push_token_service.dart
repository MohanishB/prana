import 'push_client.dart';
import 'push_preferences.dart';

/// Gives login, checkout and logout the push token of this phone.
class PushTokenService {
  PushTokenService(this._client, this._preferences);

  final PushClient _client;
  final PushPreferences _preferences;

  static const _wait = Duration(seconds: 5);

  /// The login request needs a device token. This is the real push token when there is
  /// one; otherwise a `local-...` stand-in that the server never sends pushes to.
  Future<String> tokenForLogin() async {
    final token = await currentToken();
    if (token != null) return token;
    return 'local-${await _preferences.installId()}';
  }

  /// For a guest purchase: the real token, but only when the student allowed notifications.
  Future<String?> tokenIfAllowed() async {
    if (!_client.isAvailable) return null;
    if (await _client.permission() != PushPermission.granted) return null;
    return currentToken();
  }

  /// This phone's token, or null (push unavailable, offline, or too slow).
  Future<String?> currentToken() async {
    if (!_client.isAvailable) return null;
    try {
      return await _client.getToken().timeout(_wait);
    } on Object {
      return null;
    }
  }

  /// After sign-out: forget the token so the next student on this phone gets a fresh one.
  Future<void> forget() async {
    await _client.deleteToken();
    await _preferences.setLastToken(null);
  }
}
