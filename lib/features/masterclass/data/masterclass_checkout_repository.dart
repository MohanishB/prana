import '../../../core/checkout/checkout_models.dart';
import '../../../core/device/device_info.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/push/push_token_service.dart';
import '../../../core/session/session_manager.dart';
import 'masterclass_checkout_models.dart';

/// Price check and "Buy now" for masterclasses. A guest sends no token; a
/// student sends the token so their own email and owned courses are used.
abstract interface class MasterclassCheckoutRepository {
  Future<MasterclassQuote> quote({
    required List<int> courseIds,
    required CheckoutMode mode,
    required String email,
    required String couponCode,
  });

  Future<MasterclassOrderResult> placeOrder({
    required List<int> courseIds,
    required CheckoutMode mode,
    required CheckoutDetails details,
    required String couponCode,
  });
}

final class ApiMasterclassCheckoutRepository
    implements MasterclassCheckoutRepository {
  ApiMasterclassCheckoutRepository(
    this._api,
    this._sessionManager,
    this._pushTokens,
  );

  final ApiClient _api;
  final SessionManager _sessionManager;
  final PushTokenService _pushTokens;

  bool get _loggedIn => _sessionManager.current != null;

  @override
  Future<MasterclassQuote> quote({
    required List<int> courseIds,
    required CheckoutMode mode,
    required String email,
    required String couponCode,
  }) async {
    final data = await postData(
      _api,
      ApiConstants.masterclassQuote,
      authenticated: _loggedIn,
      body: {
        'course_ids': courseIds,
        'mode': mode.apiValue,
        'email': email,
        'coupon_code': couponCode,
      },
    );
    return parseData(() => MasterclassQuote.fromJson(data));
  }

  @override
  Future<MasterclassOrderResult> placeOrder({
    required List<int> courseIds,
    required CheckoutMode mode,
    required CheckoutDetails details,
    required String couponCode,
  }) async {
    // A guest's phone token lets the server send the payment-confirmation push to the
    // new account. A signed-in student's phone is already known.
    final deviceToken = _loggedIn ? null : await _pushTokens.tokenIfAllowed();
    final data = await postData(
      _api,
      ApiConstants.masterclassCreateOrder,
      authenticated: _loggedIn,
      body: {
        'name': details.name,
        'email': details.email,
        'country_id': details.countryId,
        'phone': details.phone,
        'course_ids': courseIds,
        'mode': mode.apiValue,
        'coupon_code': couponCode,
        if (deviceToken != null) ...{
          'device_token': deviceToken,
          'device_type': AppDeviceInfo.type,
        },
      },
    );
    return parseData(() => MasterclassOrderResult.fromJson(data));
  }
}
