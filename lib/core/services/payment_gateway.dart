abstract interface class PaymentGateway {
  Future<Uri> createCheckout({
    required String productId,
    required String userId,
  });
}

/// Development implementation only.
/// Replace with an API call that creates a provider checkout session server-side.
class MockPaymentGateway implements PaymentGateway {
  @override
  Future<Uri> createCheckout({
    required String productId,
    required String userId,
  }) async {
    return Uri.parse('https://example.com/checkout?product=$productId');
  }
}
