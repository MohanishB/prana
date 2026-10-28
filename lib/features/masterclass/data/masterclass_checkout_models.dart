import '../../../core/checkout/checkout_models.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/models/money.dart';
import '../../../core/text/html_plain_text.dart';

/// Single course buy, or the cart.
enum CheckoutMode {
  single,
  cart;

  String get apiValue => name;
}

/// What the checkout screen is asked to buy.
class CheckoutArgs {
  const CheckoutArgs({required this.courseIds, required this.mode});

  final List<int> courseIds;
  final CheckoutMode mode;
}

/// One line of the price summary.
class CheckoutItem {
  const CheckoutItem({
    required this.courseId,
    required this.title,
    required this.thumbnailUrl,
    required this.price,
    required this.charged,
    required this.note,
  });

  final int courseId;
  final String title;
  final String? thumbnailUrl;
  final Money price;

  /// False for a course the student already owns or one that is included free.
  final bool charged;
  final String note;

  factory CheckoutItem.fromJson(Map<String, dynamic> json) => CheckoutItem(
        courseId: jsonInt(json['course_id']),
        title: htmlToSingleLine(jsonString(json['title'])),
        thumbnailUrl: jsonNullableString(json['thumbnail_url']),
        price: Money.fromJson(json['price']),
        charged: json['charged'] == true,
        note: jsonString(json['note']),
      );
}

class MasterclassQuote {
  const MasterclassQuote({
    required this.items,
    required this.level1Added,
    required this.subtotal,
    required this.discount,
    required this.payable,
    required this.isFree,
    required this.email,
    required this.coupon,
    required this.canPay,
    required this.simulated,
  });

  final List<CheckoutItem> items;
  final bool level1Added;
  final Money subtotal;
  final Money discount;
  final Money payable;
  final bool isFree;
  final CheckoutEmailInfo email;
  final CheckoutCoupon? coupon;
  final bool canPay;

  /// Payment is in test mode: the order is recorded as paid, no money is taken.
  final bool simulated;

  bool get hasDiscount => discount.amount > 0;

  factory MasterclassQuote.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'];
    return MasterclassQuote(
      items: jsonList(json['items'], CheckoutItem.fromJson),
      level1Added: json['level1_added'] == true,
      subtotal: Money.fromJson(json['subtotal']),
      discount: Money.fromJson(json['discount']),
      payable: Money.fromJson(json['payable']),
      isFree: json['is_free'] == true,
      email: CheckoutEmailInfo.fromJson(jsonMap(json['email'])),
      coupon: coupon is Map<String, dynamic> ? CheckoutCoupon.fromJson(coupon) : null,
      canPay: json['can_pay'] == true,
      simulated: json['simulated'] == true,
    );
  }
}

class MasterclassOrderResult {
  const MasterclassOrderResult({
    required this.bookingId,
    required this.simulated,
    required this.newStudent,
    required this.emailSent,
    required this.defaultPassword,
    required this.email,
    required this.paid,
    required this.courses,
  });

  final int bookingId;

  /// True while payment is switched off (test mode).
  final bool simulated;

  /// A new student account was created (default password applies).
  final bool newStudent;
  final bool emailSent;

  /// Only for a new student: the password they sign in with first.
  final String? defaultPassword;
  final String email;
  final Money paid;
  final List<String> courses;

  factory MasterclassOrderResult.fromJson(Map<String, dynamic> json) =>
      MasterclassOrderResult(
        bookingId: jsonInt(json['course_booking_id']),
        simulated: json['simulated'] == true,
        newStudent: json['new_student'] == true,
        emailSent: json['email_sent'] == true,
        defaultPassword: jsonNullableString(json['default_password']),
        email: jsonString(json['email']),
        paid: Money.fromJson(json['paid']),
        courses: ((json['courses'] as List?) ?? const [])
            .map(jsonString)
            .toList(growable: false),
      );
}
