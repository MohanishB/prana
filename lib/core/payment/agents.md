# core/payment

Razorpay checkout for the app.

- `payment_models.dart`: `PaymentRequest` (what the server gives to open Razorpay), `PaymentOutcome` (succeeded / cancelled / failed), `OrderStart<T>` (order finished, or payment needed).
- `payment_gateway.dart`: `PaymentGateway` interface and `RazorpayPaymentGateway` (the only file that imports `razorpay_flutter`). One payment at a time. Cubits depend on the interface, so tests can fake it.

Rules
- The app never decides that an order is paid. It sends Razorpay's order id, payment id and signature to the server, which verifies them.
- Amounts are in paise (INR) or cents (USD) and come from the server; the app never calculates them.
- Test keys start with `rzp_test_`; they live only on the server (`config/payment.php`), the app receives the public key id with each order.
