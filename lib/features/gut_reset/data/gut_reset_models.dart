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
    this.headline = '',
    this.description = '',
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

  /// One line under the title (admin: "App headline").
  final String headline;

  /// Two-line text under the headline (admin: "App description").
  final String description;
  final String? imageUrl;
  final String scheduleText;
  final Money price;
  final String bookingUrl;
  final bool canBook;

  /// Text for list cards: the app description, or the schedule line.
  String get cardText => description.isNotEmpty ? description : scheduleText;

  factory GutResetOffer.fromJson(Map<String, dynamic> json) => GutResetOffer(
        type: jsonString(json['type']),
        days: jsonInt(json['days']),
        title: htmlToSingleLine(jsonString(json['title'])),
        subTitle: htmlToSingleLine(jsonString(json['sub_title'])),
        headline: htmlToSingleLine(jsonString(json['headline'])),
        description: htmlToSingleLine(jsonString(json['description'])),
        imageUrl: jsonNullableString(json['image_url']),
        scheduleText: htmlToSingleLine(jsonString(json['schedule_text'])),
        price: Money.fromJson(json['price']),
        bookingUrl: jsonString(json['booking_url']),
        canBook: json['can_book'] != false,
      );
}
