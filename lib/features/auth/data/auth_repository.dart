import '../../../core/device/device_info.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/push/push_token_service.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/session/user_session.dart';
import 'auth_models.dart';

abstract interface class AuthRepository {
  Future<UserSession?> restoreSession();
  Future<void> login({required String email, required String password});
  Future<void> logout();
}

final class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._sessionManager, this._pushTokens);

  final ApiClient _api;
  final SessionManager _sessionManager;
  final PushTokenService _pushTokens;

  @override
  Future<UserSession?> restoreSession() async {
    final stored = await _sessionManager.restore();
    if (stored == null) return null;

    try {
      return await _api.refreshSession(stored);
    } on AppException catch (error) {
      if (_isTransientRefreshError(error)) {
        return stored;
      }
      return null;
    }
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(
      email: email.trim(),
      password: password,
      deviceToken: await _pushTokens.tokenForLogin(),
      deviceType: AppDeviceInfo.type,
    );
    final json = await _api.post(
      ApiConstants.login,
      body: request.toJson(),
      authenticated: false,
    );
    final response = LoginResponse.fromJson(json);
    await _sessionManager.setSession(response.session);
  }

  /// Signs out: tells the server to stop sending pushes to this phone, forgets the push
  /// token, then clears the session. Nothing here can stop the sign-out.
  @override
  Future<void> logout() async {
    final session = _sessionManager.current;
    if (session != null) {
      try {
        final token = await _pushTokens.currentToken();
        await _api
            .post(
              ApiConstants.logout,
              body: {
                'student_id': session.studentId,
                if (token != null) 'device_token': token,
              },
            )
            .timeout(const Duration(seconds: 6));
      } on Object {
        // Signing out must work offline too.
      }
    }
    // Session first: when the token is replaced below, nothing may register the new one.
    await _sessionManager.clear();
    await _pushTokens.forget();
  }

  bool _isTransientRefreshError(AppException error) =>
      error.type == AppErrorType.noInternet ||
      error.type == AppErrorType.timeout ||
      error.type == AppErrorType.server;
}
