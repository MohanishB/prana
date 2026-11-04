import '../models/json_readers.dart';

/// What the server returns when a purchase needs a Razorpay payment: everything the
/// Razorpay checkout needs to open. The amount is in the currency's smallest unit
/// (paise for INR, cents for USD).
class PaymentRequest {
  const PaymentRequest({
    required this.bookingId,
    required this.keyId,
    required this.orderId,
    required this.amountMinor,
    required this.currency,
    required this.name,
    required this.email,
    required this.contact,
    required this.description,
  });

  final int bookingId;
  final String keyId;
  final String orderId;
  final int amountMinor;
  final String currency;
  final String name;
  final String email;
  final String contact;

  /// Shown on Razorpay's screen (what the customer is paying for).
  final String description;

  factory PaymentRequest.fromJson(
    Map<String, dynamic> json, {
    required int bookingId,
    required String description,
  }) =>
      PaymentRequest(
        bookingId: bookingId,
        keyId: jsonString(json['key_id']),
        orderId: jsonString(json['razorpay_order_id']),
        amountMinor: jsonInt(json['amount']),
        currency: jsonString(json['razorpay_currency']),
        name: jsonString(json['name']),
        email: jsonString(json['email']),
        contact: jsonString(json['contact']),
        description: description,
      );
}

/// How Razorpay's checkout ended.
sealed class PaymentOutcome {
  const PaymentOutcome();
}

/// The customer paid. The three values are Razorpay's proof, which the server checks.
final class PaymentSucceeded extends PaymentOutcome {
  const PaymentSucceeded({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;
}

/// The customer closed Razorpay's screen without paying.
final class PaymentCancelled extends PaymentOutcome {
  const PaymentCancelled();
}

/// Razorpay reported a failure (card declined, network, ...).
final class PaymentFailed extends PaymentOutcome {
  const PaymentFailed(this.message);

  final String message;
}

/// The server's answer to "Buy now": either the order is already complete (free order or
/// test mode) or a payment must be made first.
class OrderStart<T> {
  const OrderStart.paid(T this.result) : payment = null;
  const OrderStart.payment(PaymentRequest this.payment) : result = null;

  final T? result;
  final PaymentRequest? payment;
}
