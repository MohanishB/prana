import '../../../core/models/json_readers.dart';
import '../../../core/models/money.dart';
import '../../../core/text/html_plain_text.dart';

class ConsultationOffer {
  const ConsultationOffer({
    required this.consultationId,
    required this.title,
    required this.shortDescription,
    required this.imageUrl,
    required this.price,
  });

  final int consultationId;
  final String title;
  final String shortDescription;
  final String? imageUrl;
  final Money price;

  factory ConsultationOffer.fromJson(Map<String, dynamic> json) =>
      ConsultationOffer(
        consultationId: jsonInt(json['consultation_id']),
        title: htmlToSingleLine(jsonString(json['title'])),
        shortDescription: htmlToSingleLine(jsonString(json['short_desc'])),
        imageUrl: jsonNullableString(json['image_url']),
        price: Money.fromJson(json['price']),
      );
}

class ConsultationOfferDetail {
  const ConsultationOfferDetail({
    required this.offer,
    required this.descriptionHtml,
    required this.note,
    required this.aboutTitle,
    required this.aboutHtml,
    required this.termsTitle,
    required this.termsHtml,
    required this.alreadyBooked,
    required this.canBook,
  });

  final ConsultationOffer offer;
  final String descriptionHtml;
  final String note;
  final String aboutTitle;
  final String aboutHtml;
  final String termsTitle;
  final String termsHtml;
  final bool alreadyBooked;
  final bool canBook;

  factory ConsultationOfferDetail.fromJson(Map<String, dynamic> json) =>
      ConsultationOfferDetail(
        offer: ConsultationOffer.fromJson(json),
        descriptionHtml: jsonString(json['description_html']),
        note: htmlToSingleLine(jsonString(json['note'])),
        aboutTitle: htmlToSingleLine(jsonString(json['about_us_title'])),
        aboutHtml: jsonString(json['about_us_html']),
        termsTitle: htmlToSingleLine(jsonString(json['terms_title'])),
        termsHtml: jsonString(json['terms_html']),
        alreadyBooked: json['already_booked'] == true,
        canBook: json['can_book'] == true,
      );
}
