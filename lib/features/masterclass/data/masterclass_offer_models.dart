import '../../../core/models/json_readers.dart';
import '../../../core/models/money.dart';
import '../../../core/text/html_plain_text.dart';

/// A masterclass the visitor can buy (card on Home / Masterclass tab).
class MasterclassOffer {
  const MasterclassOffer({
    required this.courseId,
    required this.title,
    required this.heading,
    required this.shortDescription,
    required this.thumbnailUrl,
    required this.price,
    required this.includesMasterclass,
    required this.priceNote,
  });

  final int courseId;
  final String title;
  final String heading;
  final String shortDescription;
  final String? thumbnailUrl;
  final Money price;

  /// True when Level 1 is added to the order (the price already includes it).
  final bool includesMasterclass;
  final String priceNote;

  factory MasterclassOffer.fromJson(Map<String, dynamic> json) =>
      MasterclassOffer(
        courseId: jsonInt(json['course_id']),
        title: htmlToSingleLine(jsonString(json['title'])),
        heading: htmlToSingleLine(jsonString(json['heading'])),
        shortDescription: htmlToSingleLine(jsonString(json['short_desc'])),
        thumbnailUrl: jsonNullableString(json['thumbnail_url']),
        price: Money.fromJson(json['price']),
        includesMasterclass: json['includes_masterclass'] == true,
        priceNote: htmlToSingleLine(jsonString(json['price_note'])),
      );
}

class MasterclassOfferDetail {
  const MasterclassOfferDetail({
    required this.offer,
    required this.descriptionHtml,
    required this.note,
    required this.bannerUrl,
    required this.aboutTitle,
    required this.aboutHtml,
    required this.termsTitle,
    required this.termsHtml,
    required this.alreadyBooked,
    required this.canBook,
  });

  final MasterclassOffer offer;
  final String descriptionHtml;
  final String note;
  final String? bannerUrl;
  final String aboutTitle;
  final String aboutHtml;
  final String termsTitle;
  final String termsHtml;
  final bool alreadyBooked;
  final bool canBook;

  factory MasterclassOfferDetail.fromJson(Map<String, dynamic> json) =>
      MasterclassOfferDetail(
        offer: MasterclassOffer.fromJson(json),
        descriptionHtml: jsonString(json['description_html']),
        note: htmlToSingleLine(jsonString(json['note'])),
        bannerUrl: jsonNullableString(json['banner_image_url']),
        aboutTitle: htmlToSingleLine(jsonString(json['about_us_title'])),
        aboutHtml: jsonString(json['about_us_html']),
        termsTitle: htmlToSingleLine(jsonString(json['terms_title'])),
        termsHtml: jsonString(json['terms_html']),
        alreadyBooked: json['already_booked'] == true,
        canBook: json['can_book'] == true,
      );
}
