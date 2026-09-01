import '../../../core/device/device_info.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/session/user_session.dart';
import 'auth_models.dart';

abstract interface class AuthRepository {
  Future<UserSession?> restoreSession();
  Future<void> login({required String email, required String password});
  Future<void> logout();
}

final class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

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
      deviceToken: ApiConstants.staticDeviceToken,
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

  @override
  Future<void> logout() => _sessionManager.clear();

  bool _isTransientRefreshError(AppException error) =>
      error.type == AppErrorType.noInternet ||
      error.type == AppErrorType.timeout ||
      error.type == AppErrorType.server;
}
