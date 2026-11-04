import '../../../core/checkout/checkout_models.dart';
import '../../../core/device/device_info.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/payment/payment_models.dart';
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

  /// Saves the booking. The answer is either a finished order (free / test mode)
  /// or a payment the app must make first.
  Future<OrderStart<MasterclassOrderResult>> placeOrder({
    required List<int> courseIds,
    required CheckoutMode mode,
    required CheckoutDetails details,
    required String couponCode,
  });

  /// After Razorpay reports success: the server verifies it and completes the order.
  Future<MasterclassOrderResult> confirmPayment(PaymentSucceeded payment);
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
  Future<OrderStart<MasterclassOrderResult>> placeOrder({
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
    return parseData(() {
      if (data['status'] == 'payment_required') {
        return OrderStart<MasterclassOrderResult>.payment(
          PaymentRequest.fromJson(
            data,
            bookingId: jsonInt(data['course_booking_id']),
            description: ((data['courses'] as List?) ?? const [])
                .map(jsonString)
                .join(', '),
          ),
        );
      }
      return OrderStart<MasterclassOrderResult>.paid(
        MasterclassOrderResult.fromJson(data),
      );
    });
  }

  @override
  Future<MasterclassOrderResult> confirmPayment(
    PaymentSucceeded payment,
  ) async {
    final deviceToken = _loggedIn ? null : await _pushTokens.tokenIfAllowed();
    final data = await postData(
      _api,
      ApiConstants.masterclassConfirmPayment,
      authenticated: _loggedIn,
      body: {
        'razorpay_order_id': payment.orderId,
        'razorpay_payment_id': payment.paymentId,
        'razorpay_signature': payment.signature,
        if (deviceToken != null) ...{
          'device_token': deviceToken,
          'device_type': AppDeviceInfo.type,
        },
      },
    );
    return parseData(() => MasterclassOrderResult.fromJson(data));
  }
}
