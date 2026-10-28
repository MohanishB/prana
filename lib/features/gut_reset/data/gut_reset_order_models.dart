import '../../../core/models/json_readers.dart';
import '../../../core/models/money.dart';

/// What "Book now" returns for a Gut Reset.
class GutResetOrderResult {
  const GutResetOrderResult({
    required this.workshopBookingId,
    required this.type,
    required this.title,
    required this.days,
    required this.paid,
    required this.startsOn,
    required this.startsWhenOpened,
    required this.simulated,
    required this.newStudent,
    required this.defaultPassword,
    required this.email,
  });

  final int workshopBookingId;

  /// '3DAY' or '7DAY'.
  final String type;
  final String title;
  final int days;
  final Money paid;

  /// 3-day: the Friday it starts on. Null for a 7-day.
  final DateTime? startsOn;

  /// 7-day: the student taps "Start Day 1" when ready.
  final bool startsWhenOpened;

  /// True while payment is switched off (test mode).
  final bool simulated;
  final bool newStudent;

  /// Only for a new student: the password they sign in with first.
  final String? defaultPassword;
  final String email;

  factory GutResetOrderResult.fromJson(Map<String, dynamic> json) =>
      GutResetOrderResult(
        workshopBookingId: jsonInt(json['gut_reset_workshop_booking_id']),
        type: jsonString(json['type']),
        title: jsonString(json['title']),
        days: jsonInt(json['days']),
        paid: Money.fromJson(json['paid']),
        startsOn: DateTime.tryParse(jsonString(json['starts_on'])),
        startsWhenOpened: json['starts_when_opened'] == true,
        simulated: json['simulated'] == true,
        newStudent: json['new_student'] == true,
        defaultPassword: jsonNullableString(json['default_password']),
        email: jsonString(json['email']),
      );
}
