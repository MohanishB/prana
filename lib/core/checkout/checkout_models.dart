import '../models/json_readers.dart';

class CheckoutEmailInfo {
  const CheckoutEmailInfo({
    required this.state,
    required this.message,
    required this.blocked,
  });

  /// none | new | existing
  final String state;
  final String message;

  /// This email cannot buy (for example it already owns the course).
  final bool blocked;

  factory CheckoutEmailInfo.fromJson(Map<String, dynamic> json) =>
      CheckoutEmailInfo(
        state: jsonString(json['state']),
        message: jsonString(json['message']),
        blocked: json['blocked'] == true,
      );
}

class CheckoutCoupon {
  const CheckoutCoupon({
    required this.code,
    required this.valid,
    required this.message,
    required this.description,
  });

  final String code;
  final bool valid;
  final String message;
  final String description;

  factory CheckoutCoupon.fromJson(Map<String, dynamic> json) => CheckoutCoupon(
        code: jsonString(json['code']),
        valid: json['valid'] == true,
        message: jsonString(json['message']),
        description: jsonString(json['description']),
      );
}

/// What the customer typed on the checkout form.
class CheckoutDetails {
  const CheckoutDetails({
    required this.name,
    required this.email,
    required this.countryId,
    required this.phone,
  });

  final String name;
  final String email;
  final int countryId;
  final String phone;
}
