import '../../../core/models/json_readers.dart';

/// One answer. The id is opaque: the app never knows which dosha it points to.
class PrakritiOption {
  const PrakritiOption({required this.id, required this.text});

  final int id;
  final String text;

  factory PrakritiOption.fromJson(Map<String, dynamic> json) => PrakritiOption(
        id: jsonInt(json['id']),
        text: jsonString(json['text']),
      );
}

class PrakritiQuestion {
  const PrakritiQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.partNo,
    required this.partTitle,
    required this.partIntro,
    required this.indexInPart,
    required this.firstInPart,
  });

  final int id;
  final String text;
  final List<PrakritiOption> options;
  final int partNo;
  final String partTitle;
  final String partIntro;

  /// 1-based position inside its part.
  final int indexInPart;
  final bool firstInPart;
}

class PrakritiProfile {
  const PrakritiProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.countryId,
  });

  final String name;
  final String email;
  final String phone;
  final int countryId;

  factory PrakritiProfile.fromJson(Map<String, dynamic> json) =>
      PrakritiProfile(
        name: jsonString(json['name']),
        email: jsonString(json['email']),
        phone: jsonString(json['phone']),
        countryId: jsonInt(json['country_id']),
      );
}

/// The live quiz, flattened into one list of questions in the order asked.
class PrakritiQuiz {
  const PrakritiQuiz({
    required this.versionId,
    required this.versionName,
    required this.introText,
    required this.finalScreenText,
    required this.disclaimerText,
    required this.notSureTip,
    required this.questions,
    required this.partCount,
    required this.profile,
  });

  final int versionId;
  final String versionName;
  final String introText;
  final String finalScreenText;
  final String disclaimerText;
  final String notSureTip;
  final List<PrakritiQuestion> questions;
  final int partCount;

  /// Null for a guest.
  final PrakritiProfile? profile;

  factory PrakritiQuiz.fromJson(Map<String, dynamic> json) {
    final version = jsonMap(json['version']);
    final questions = <PrakritiQuestion>[];
    final parts = (json['parts'] as List?) ?? const [];
    for (final rawPart in parts.whereType<Map>()) {
      final part = Map<String, dynamic>.from(rawPart);
      final list = (part['questions'] as List?) ?? const [];
      var n = 0;
      for (final rawQuestion in list.whereType<Map>()) {
        final q = Map<String, dynamic>.from(rawQuestion);
        n++;
        questions.add(PrakritiQuestion(
          id: jsonInt(q['id']),
          text: jsonString(q['text']),
          options: jsonList(q['options'], PrakritiOption.fromJson),
          partNo: jsonInt(part['part_no']),
          partTitle: jsonString(part['title']),
          partIntro: jsonString(part['intro']),
          indexInPart: n,
          firstInPart: n == 1,
        ));
      }
    }
    return PrakritiQuiz(
      versionId: jsonInt(version['id']),
      versionName: jsonString(version['name']),
      introText: jsonString(version['intro_text']),
      finalScreenText: jsonString(version['final_screen_text']),
      disclaimerText: jsonString(version['disclaimer_text']),
      notSureTip: jsonString(version['not_sure_tip']),
      questions: questions,
      partCount: parts.length,
      profile: json['profile'] is Map<String, dynamic>
          ? PrakritiProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PrakritiResult {
  const PrakritiResult({
    required this.attemptId,
    required this.takenAt,
    required this.typeCode,
    required this.displayName,
    required this.title,
    required this.elements,
    required this.summary,
    required this.strengths,
    required this.watchOuts,
    required this.food,
    required this.routine,
    required this.movementMind,
    required this.pranaPlan,
    required this.vata,
    required this.pitta,
    required this.kapha,
    required this.doshasText,
    required this.footerText,
    required this.disclaimerText,
    required this.signedIn,
    required this.adviceHeading,
    required this.adviceNote,
    required this.adviceEmail,
    required this.advicePhone,
  });

  final int attemptId;
  final String takenAt;
  final String typeCode;
  final String displayName;
  final String title;
  final String elements;
  final String summary;
  final String strengths;
  final String watchOuts;
  final String food;
  final String routine;
  final String movementMind;
  final String pranaPlan;
  final int vata;
  final int pitta;
  final int kapha;
  final String doshasText;
  final String footerText;
  final String disclaimerText;
  final bool signedIn;
  final String adviceHeading;
  final String adviceNote;
  final String adviceEmail;
  final String advicePhone;

  factory PrakritiResult.fromJson(Map<String, dynamic> json) {
    final percent = jsonMap(json['percent']);
    final advice = jsonMap(json['consult_advice']);
    return PrakritiResult(
      attemptId: jsonInt(json['attempt_id']),
      takenAt: jsonString(json['taken_at']),
      typeCode: jsonString(json['type_code']),
      displayName: jsonString(json['display_name']),
      title: jsonString(json['title']),
      elements: jsonString(json['elements']),
      summary: jsonString(json['summary']),
      strengths: jsonString(json['strengths']),
      watchOuts: jsonString(json['watch_outs']),
      food: jsonString(json['food']),
      routine: jsonString(json['routine']),
      movementMind: jsonString(json['movement_mind']),
      pranaPlan: jsonString(json['prana_plan']),
      vata: jsonInt(percent['vata']),
      pitta: jsonInt(percent['pitta']),
      kapha: jsonInt(percent['kapha']),
      doshasText: jsonString(json['doshas_text']),
      footerText: jsonString(json['footer_text']),
      disclaimerText: jsonString(json['disclaimer_text']),
      signedIn: json['signed_in'] == true,
      adviceHeading: jsonString(advice['heading']),
      adviceNote: jsonString(advice['note']),
      adviceEmail: jsonString(advice['email']),
      advicePhone: jsonString(advice['phone']),
    );
  }
}

/// Answers given so far, kept on the phone so the quiz can be resumed.
class PrakritiProgress {
  const PrakritiProgress({
    required this.versionId,
    required this.answers,
    required this.index,
  });

  final int versionId;

  /// question id -> option id
  final Map<int, int> answers;
  final int index;
}
