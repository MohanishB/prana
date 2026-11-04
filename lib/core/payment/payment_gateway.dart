import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'payment_models.dart';

/// Opens the payment screen and reports how it ended. The cubits depend on this
/// interface, so they can be tested without Razorpay.
abstract interface class PaymentGateway {
  Future<PaymentOutcome> pay(PaymentRequest request);
}

/// Razorpay's native checkout (razorpay_flutter). One payment at a time.
final class RazorpayPaymentGateway implements PaymentGateway {
  const RazorpayPaymentGateway();

  static const _title = 'Prana by Dimple';

  @override
  Future<PaymentOutcome> pay(PaymentRequest request) {
    final completer = Completer<PaymentOutcome>();
    final razorpay = Razorpay();

    void finish(PaymentOutcome outcome) {
      if (completer.isCompleted) return;
      razorpay.clear();
      completer.complete(outcome);
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (Object? data) {
      if (data is PaymentSuccessResponse) {
        final paymentId = data.paymentId ?? '';
        final signature = data.signature ?? '';
        if (paymentId.isEmpty || signature.isEmpty) {
          finish(const PaymentFailed('Payment could not be verified.'));
          return;
        }
        finish(PaymentSucceeded(
          orderId: data.orderId ?? request.orderId,
          paymentId: paymentId,
          signature: signature,
        ));
      } else {
        finish(const PaymentFailed('Payment could not be verified.'));
      }
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (Object? data) {
      if (data is PaymentFailureResponse) {
        final message = (data.message ?? '').trim();
        final cancelled = data.code == Razorpay.PAYMENT_CANCELLED ||
            message.toLowerCase().contains('cancel');
        finish(cancelled
            ? const PaymentCancelled()
            : PaymentFailed(message.isEmpty ? 'Payment failed.' : message));
      } else {
        finish(const PaymentFailed('Payment failed.'));
      }
    });
    // A wallet app takes over; Razorpay then reports success or error as usual.
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (Object? data) {});

    try {
      razorpay.open({
        'key': request.keyId,
        'order_id': request.orderId,
        'amount': request.amountMinor,
        'currency': request.currency,
        'name': _title,
        'description': request.description,
        'prefill': {
          'name': request.name,
          'email': request.email,
          'contact': request.contact,
        },
      });
    } on Object {
      finish(const PaymentFailed('The payment screen could not be opened.'));
    }
    return completer.future;
  }
}
