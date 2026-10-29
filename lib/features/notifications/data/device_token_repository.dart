import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';

/// Tells the server which phone the signed-in student uses, so pushes can reach it.
abstract interface class DeviceTokenRepository {
  /// [oldToken] is the token this one replaces (switched off on the server).
  Future<void> register({
    required String token,
    required int deviceType,
    String? oldToken,
  });
}

final class ApiDeviceTokenRepository implements DeviceTokenRepository {
  ApiDeviceTokenRepository(this._api);

  final ApiClient _api;

  @override
  Future<void> register({
    required String token,
    required int deviceType,
    String? oldToken,
  }) async {
    await postData(
      _api,
      ApiConstants.devicesRegister,
      authenticated: true,
      body: {
        'device_token': token,
        'device_type': deviceType,
        if (oldToken != null && oldToken.isNotEmpty) 'old_token': oldToken,
      },
    );
  }
}
