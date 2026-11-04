import '../../../core/checkout/checkout_models.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/payment/payment_models.dart';
import '../../../core/session/session_manager.dart';
import 'consult_checkout_models.dart';

/// Price check, "Book now" and the student's booked consultations. A guest sends
/// no token; a student sends the token so the student's own email is used.
abstract interface class ConsultationCheckoutRepository {
  Future<ConsultationQuote> quote({
    required int consultationId,
    required String email,
    required String couponCode,
  });

  /// Saves the booking. The answer is either a finished booking (free / test mode)
  /// or a payment the app must make first.
  Future<OrderStart<ConsultationOrderResult>> placeOrder({
    required int consultationId,
    required CheckoutDetails details,
    required String couponCode,
  });

  /// After Razorpay reports success: the server verifies it and completes the booking.
  Future<ConsultationOrderResult> confirmPayment(PaymentSucceeded payment);

  Future<List<ConsultationBooking>> getMyBookings();
}

final class ApiConsultationCheckoutRepository
    implements ConsultationCheckoutRepository {
  ApiConsultationCheckoutRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  bool get _loggedIn => _sessionManager.current != null;

  @override
  Future<ConsultationQuote> quote({
    required int consultationId,
    required String email,
    required String couponCode,
  }) async {
    final data = await postData(
      _api,
      ApiConstants.consultationQuote,
      authenticated: _loggedIn,
      body: {
        'consultation_id': consultationId,
        'email': email,
        'coupon_code': couponCode,
      },
    );
    return parseData(() => ConsultationQuote.fromJson(data));
  }

  @override
  Future<OrderStart<ConsultationOrderResult>> placeOrder({
    required int consultationId,
    required CheckoutDetails details,
    required String couponCode,
  }) async {
    final data = await postData(
      _api,
      ApiConstants.consultationCreateOrder,
      authenticated: _loggedIn,
      body: {
        'consultation_id': consultationId,
        'name': details.name,
        'email': details.email,
        'country_id': details.countryId,
        'phone': details.phone,
        'coupon_code': couponCode,
      },
    );
    return parseData(() {
      if (data['status'] == 'payment_required') {
        return OrderStart<ConsultationOrderResult>.payment(
          PaymentRequest.fromJson(
            data,
            bookingId: jsonInt(data['consultation_booking_id']),
            description: jsonString(data['consultation']),
          ),
        );
      }
      return OrderStart<ConsultationOrderResult>.paid(
        ConsultationOrderResult.fromJson(data),
      );
    });
  }

  @override
  Future<ConsultationOrderResult> confirmPayment(
    PaymentSucceeded payment,
  ) async {
    final data = await postData(
      _api,
      ApiConstants.consultationConfirmPayment,
      authenticated: _loggedIn,
      body: {
        'razorpay_order_id': payment.orderId,
        'razorpay_payment_id': payment.paymentId,
        'razorpay_signature': payment.signature,
      },
    );
    return parseData(() => ConsultationOrderResult.fromJson(data));
  }

  @override
  Future<List<ConsultationBooking>> getMyBookings() async {
    final data = await fetchData(
      _api,
      ApiConstants.myConsultations,
      authenticated: true,
    );
    return parseData(
      () => jsonList(data['bookings'], ConsultationBooking.fromJson),
    );
  }
}
