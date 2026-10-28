import '../../../core/checkout/checkout_models.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/models/money.dart';
import '../../../core/text/html_plain_text.dart';

/// The price of one consultation for this customer (nothing is saved).
class ConsultationQuote {
  const ConsultationQuote({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.payable,
    required this.isFree,
    required this.email,
    required this.coupon,
    required this.canPay,
    required this.simulated,
  });

  final String title;
  final String? imageUrl;
  final Money price;
  final Money discount;
  final Money payable;
  final bool isFree;
  final CheckoutEmailInfo email;
  final CheckoutCoupon? coupon;
  final bool canPay;

  /// Payment is in test mode: the booking is recorded as paid, no money is taken.
  final bool simulated;

  bool get hasDiscount => discount.amount > 0;

  factory ConsultationQuote.fromJson(Map<String, dynamic> json) {
    final consultation = jsonMap(json['consultation']);
    final coupon = json['coupon'];
    return ConsultationQuote(
      title: htmlToSingleLine(jsonString(consultation['title'])),
      imageUrl: jsonNullableString(consultation['image_url']),
      price: Money.fromJson(json['price']),
      discount: Money.fromJson(json['discount']),
      payable: Money.fromJson(json['payable']),
      isFree: json['is_free'] == true,
      email: CheckoutEmailInfo.fromJson(jsonMap(json['email'])),
      coupon:
          coupon is Map<String, dynamic> ? CheckoutCoupon.fromJson(coupon) : null,
      canPay: json['can_pay'] == true,
      simulated: json['simulated'] == true,
    );
  }
}

class ConsultationOrderResult {
  const ConsultationOrderResult({
    required this.bookingId,
    required this.title,
    required this.simulated,
    required this.emailSent,
    required this.email,
    required this.paid,
    required this.scheduleUrl,
  });

  final int bookingId;
  final String title;
  final bool simulated;
  final bool emailSent;
  final String email;
  final Money paid;

  /// The calendar page to choose the date and time (null when not set up).
  final String? scheduleUrl;

  factory ConsultationOrderResult.fromJson(Map<String, dynamic> json) =>
      ConsultationOrderResult(
        bookingId: jsonInt(json['consultation_booking_id']),
        title: htmlToSingleLine(jsonString(json['consultation'])),
        simulated: json['simulated'] == true,
        emailSent: json['email_sent'] == true,
        email: jsonString(json['email']),
        paid: Money.fromJson(json['paid']),
        scheduleUrl: jsonNullableString(json['schedule_url']),
      );
}

/// A consultation the student has booked and paid for.
class ConsultationBooking {
  const ConsultationBooking({
    required this.bookingId,
    required this.consultationId,
    required this.title,
    required this.imageUrl,
    required this.bookedOn,
    required this.paid,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.scheduleUrl,
  });

  final int bookingId;
  final int consultationId;
  final String title;
  final String? imageUrl;

  /// "2026-10-27 16:31:18" as saved (IST).
  final String bookedOn;
  final Money paid;

  /// Set by the team once the consultation is scheduled.
  final String? scheduledDate;
  final String? scheduledTime;
  final String? scheduleUrl;

  bool get isScheduled => scheduledDate != null;

  /// The booking day ("2026-10-27"), without the time.
  String get bookedDay =>
      bookedOn.length >= 10 ? bookedOn.substring(0, 10) : bookedOn;

  factory ConsultationBooking.fromJson(Map<String, dynamic> json) =>
      ConsultationBooking(
        bookingId: jsonInt(json['consultation_booking_id']),
        consultationId: jsonInt(json['consultation_id']),
        title: htmlToSingleLine(jsonString(json['title'])),
        imageUrl: jsonNullableString(json['image_url']),
        bookedOn: jsonString(json['booked_on']),
        paid: Money.fromJson(json['paid']),
        scheduledDate: jsonNullableString(json['scheduled_date']),
        scheduledTime: jsonNullableString(json['scheduled_time']),
        scheduleUrl: jsonNullableString(json['schedule_url']),
      );
}
