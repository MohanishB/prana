import '../../../core/models/json_readers.dart';
import '../../../core/models/money.dart';
import '../../../core/text/html_plain_text.dart';

/// The 3-day or 7-day Gut Reset the visitor can book.
class GutResetOffer {
  const GutResetOffer({
    required this.type,
    required this.days,
    required this.title,
    required this.subTitle,
    required this.imageUrl,
    required this.scheduleText,
    required this.price,
    required this.bookingUrl,
    required this.canBook,
  });

  /// '3DAY' or '7DAY'.
  final String type;
  final int days;
  final String title;
  final String subTitle;
  final String? imageUrl;
  final String scheduleText;
  final Money price;
  final String bookingUrl;
  final bool canBook;

  factory GutResetOffer.fromJson(Map<String, dynamic> json) => GutResetOffer(
        type: jsonString(json['type']),
        days: jsonInt(json['days']),
        title: htmlToSingleLine(jsonString(json['title'])),
        subTitle: htmlToSingleLine(jsonString(json['sub_title'])),
        imageUrl: jsonNullableString(json['image_url']),
        scheduleText: htmlToSingleLine(jsonString(json['schedule_text'])),
        price: Money.fromJson(json['price']),
        bookingUrl: jsonString(json['booking_url']),
        canBook: json['can_book'] != false,
      );
}
