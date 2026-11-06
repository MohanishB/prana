import '../../../core/models/json_readers.dart';
import '../../../core/text/html_plain_text.dart';

/// A certificate that has already been generated for the signed-in student.
class StudentCertificate {
  const StudentCertificate({
    required this.courseId,
    required this.title,
    required this.generatedOn,
    required this.downloadUrl,
    this.imageUrl,
  });

  final int courseId;

  /// The masterclass name.
  final String title;

  /// "2026-08-31 21:35:08" as sent by the server, or null when unknown.
  final String? generatedOn;
  final String downloadUrl;

  /// The masterclass picture; null when the masterclass has none.
  final String? imageUrl;

  factory StudentCertificate.fromJson(Map<String, dynamic> json) =>
      StudentCertificate(
        courseId: jsonInt(json['course_id']),
        title: htmlToSingleLine(jsonString(json['title'])),
        generatedOn: jsonNullableString(json['generated_on']),
        downloadUrl: jsonString(json['download_url']),
        imageUrl: jsonNullableString(json['image_url']),
      );
}
