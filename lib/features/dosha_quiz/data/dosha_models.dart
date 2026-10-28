import '../../../core/models/json_readers.dart';

class DoshaQuestion {
  const DoshaQuestion({required this.question, required this.options});

  final String question;

  /// Three answers: the first points to Vata, the second to Pitta, the third to Kapha.
  final List<String> options;

  factory DoshaQuestion.fromJson(Map<String, dynamic> json) => DoshaQuestion(
        question: jsonString(json['question']),
        options: _strings(json['options']),
      );
}

/// A logged-in student's saved details, used to fill in the last screen.
class DoshaProfile {
  const DoshaProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.countryId,
  });

  final String name;
  final String email;
  final String phone;
  final int countryId;

  factory DoshaProfile.fromJson(Map<String, dynamic> json) => DoshaProfile(
        name: jsonString(json['name']),
        email: jsonString(json['email']),
        phone: jsonString(json['phone']),
        countryId: jsonInt(json['country_id']),
      );
}

class DoshaQuiz {
  const DoshaQuiz({required this.questions, required this.profile});

  final List<DoshaQuestion> questions;

  /// Null for a guest.
  final DoshaProfile? profile;

  factory DoshaQuiz.fromJson(Map<String, dynamic> json) => DoshaQuiz(
        questions: jsonList(json['questions'], DoshaQuestion.fromJson),
        profile: json['profile'] is Map<String, dynamic>
            ? DoshaProfile.fromJson(json['profile'] as Map<String, dynamic>)
            : null,
      );
}

class DoshaSection {
  const DoshaSection({required this.heading, required this.paragraphs});

  final String? heading;
  final List<String> paragraphs;

  factory DoshaSection.fromJson(Map<String, dynamic> json) => DoshaSection(
        heading: jsonNullableString(json['heading']),
        paragraphs: _strings(json['paragraphs']),
      );
}

class DoshaResult {
  const DoshaResult({
    required this.studentName,
    required this.dosha,
    required this.title,
    required this.sections,
    required this.adviceHeading,
    required this.adviceNote,
    required this.adviceEmail,
    required this.advicePhone,
  });

  final String studentName;

  /// Vata, Pitta or Kapha.
  final String dosha;

  /// VATA, PITTA or KAPHA.
  final String title;
  final List<DoshaSection> sections;
  final String adviceHeading;
  final String adviceNote;
  final String adviceEmail;
  final String advicePhone;

  factory DoshaResult.fromJson(Map<String, dynamic> json) {
    final advice = jsonMap(json['consult_advice']);
    return DoshaResult(
      studentName: jsonString(json['student_name']),
      dosha: jsonString(json['dosha']),
      title: jsonString(json['title']),
      sections: jsonList(json['sections'], DoshaSection.fromJson),
      adviceHeading: jsonString(advice['heading']),
      adviceNote: jsonString(advice['note']),
      adviceEmail: jsonString(advice['email']),
      advicePhone: jsonString(advice['phone']),
    );
  }
}

List<String> _strings(Object? value) =>
    value is List ? value.map(jsonString).toList() : const [];
