class MasterclassCourse {
  const MasterclassCourse({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.thumbnailUrl,
    required this.bannerUrl,
    required this.totalChapters,
    required this.completedChapters,
    required this.progressPercent,
    required this.certificateGenerated,
    required this.certificateDownloadUrl,
    required this.certificateGeneratedOn,
  });
  final int id;
  final String title;
  final String shortDescription;
  final String thumbnailUrl;
  final String bannerUrl;
  final int totalChapters;
  final int completedChapters;
  final int progressPercent;
  final bool certificateGenerated;
  final String certificateDownloadUrl;
  final String certificateGeneratedOn;

  factory MasterclassCourse.fromJson(Map<String, dynamic> json) {
    final certificate = json['certificate'];
    return MasterclassCourse(
      id: (json['course_id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      bannerUrl: json['banner_url']?.toString() ?? '',
      totalChapters: (json['total_chapters'] as num?)?.toInt() ?? 0,
      completedChapters: (json['completed_chapters'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progress_pct'] as num?)?.toInt() ?? 0,
      certificateGenerated:
          certificate is Map && certificate['generated'] == true,
      certificateDownloadUrl: certificate is Map
          ? certificate['download_url']?.toString() ?? ''
          : '',
      certificateGeneratedOn: certificate is Map
          ? certificate['generated_on']?.toString() ?? ''
          : '',
    );
  }
}

class CourseDetail {
  const CourseDetail({
    required this.courseId,
    required this.title,
    required this.intro,
    required this.chapters,
    required this.certificate,
  });

  final int courseId;
  final String title;
  final CourseIntro intro;
  final List<CourseChapter> chapters;
  final CourseCertificate certificate;

  factory CourseDetail.fromJson(Map<String, dynamic> json) => CourseDetail(
        courseId: (json['course_id'] as num).toInt(),
        title: json['course_title']?.toString() ?? '',
        intro: CourseIntro.fromJson(
          (json['course_intro'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        chapters: ((json['chapters'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CourseChapter.fromJson(e.cast<String, dynamic>()))
            .toList(growable: false),
        certificate: CourseCertificate.fromJson(
          (json['certificate'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
}

class CourseCertificate {
  const CourseCertificate({
    required this.generated,
    required this.generatedOn,
    required this.downloadUrl,
  });

  final bool generated;
  final String generatedOn;
  final String downloadUrl;

  bool get canDownload => generated && downloadUrl.trim().isNotEmpty;

  factory CourseCertificate.fromJson(Map<String, dynamic> json) =>
      CourseCertificate(
        generated: json['generated'] == true,
        generatedOn: json['generated_on']?.toString() ?? '',
        downloadUrl: json['download_url']?.toString() ?? '',
      );
}

class CourseIntro {
  const CourseIntro({
    required this.tabTitle,
    required this.imageUrl,
    required this.descriptionHtml,
  });
  final String tabTitle;
  final String imageUrl;
  final String descriptionHtml;

  factory CourseIntro.fromJson(Map<String, dynamic> json) => CourseIntro(
        tabTitle: json['tab_title']?.toString() ?? '',
        imageUrl: json['image_url']?.toString() ?? '',
        descriptionHtml: json['description']?.toString() ?? '',
      );
}

class CourseChapter {
  const CourseChapter({
    required this.id,
    required this.title,
    required this.introDescription,
    required this.fullDescription,
    required this.position,
    required this.videos,
    required this.quiz,
    required this.notes,
  });
  final int id;
  final String title;
  final String introDescription;
  final String fullDescription;
  final int position;
  final List<CourseVideo> videos;
  final CourseQuiz quiz;
  final List<CourseNote> notes;

  factory CourseChapter.fromJson(Map<String, dynamic> json) => CourseChapter(
        id: (json['chapter_id'] as num).toInt(),
        title: json['title']?.toString() ?? '',
        introDescription: json['intro_desc']?.toString() ?? '',
        fullDescription: json['full_desc']?.toString() ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
        videos: ((json['videos'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CourseVideo.fromJson(e.cast<String, dynamic>()))
            .toList(growable: false),
        quiz: CourseQuiz.fromJson(
          (json['quiz'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        notes: ((json['notes'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CourseNote.fromJson(e.cast<String, dynamic>()))
            .toList(growable: false),
      );
}


class CourseVideo {
  const CourseVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.vimeoVideoUrl,
    required this.mainVideoUrl,
    required this.thumbnailUrl,
    required this.position,
  });

  final int id;
  final String title;

  /// Legacy/self-hosted URL retained by the backend during migration.
  final String videoUrl;

  /// Vimeo-specific URL supplied by the backend.
  final String vimeoVideoUrl;

  /// Source of truth for playback.
  final String mainVideoUrl;

  final String thumbnailUrl;
  final int position;

  bool get canPlay => mainVideoUrl.trim().isNotEmpty;

  factory CourseVideo.fromJson(Map<String, dynamic> json) => CourseVideo(
        id: (json['video_id'] as num).toInt(),
        title: json['title']?.toString() ?? '',
        videoUrl: json['video_url']?.toString() ?? '',
        vimeoVideoUrl: json['vimeo_video_url']?.toString() ?? '',
        mainVideoUrl: json['main_video_url']?.toString() ?? '',
        thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
      );
}


class CourseQuiz {
  const CourseQuiz({
    required this.available,
    required this.completed,
    required this.questionCount,
    required this.correct,
    required this.total,
    required this.questions,
  });

  final bool available;
  final bool completed;
  final int questionCount;
  final int correct;
  final int total;
  final List<CourseQuizQuestion> questions;

  factory CourseQuiz.fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as Map?)?.cast<String, dynamic>() ?? const {};
    return CourseQuiz(
      available: json['available'] == true,
      completed: json['completed'] == true,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      correct: (score['correct'] as num?)?.toInt() ?? 0,
      total: (score['total'] as num?)?.toInt() ?? 0,
      questions: ((json['questions'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CourseQuizQuestion.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

class CourseQuizQuestion {
  const CourseQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.position,
    required this.studentAnswer,
    required this.isCorrect,
  });

  final int id;
  final String question;
  final List<CourseQuizOption> options;
  final int position;
  final CourseQuizOption? studentAnswer;
  final bool? isCorrect;

  factory CourseQuizQuestion.fromJson(Map<String, dynamic> json) {
    final answer = json['student_answer'];
    return CourseQuizQuestion(
      id: (json['quiz_id'] as num).toInt(),
      question: json['question']?.toString() ?? '',
      options: ((json['options'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => CourseQuizOption.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false),
      position: (json['position'] as num?)?.toInt() ?? 0,
      studentAnswer: answer is Map
          ? CourseQuizOption.fromJson(answer.cast<String, dynamic>())
          : null,
      isCorrect: json['is_correct'] as bool?,
    );
  }
}

class CourseQuizOption {
  const CourseQuizOption({required this.optionNo, required this.text});

  final int optionNo;
  final String text;

  factory CourseQuizOption.fromJson(Map<String, dynamic> json) =>
      CourseQuizOption(
        optionNo: (json['option_no'] as num?)?.toInt() ?? 0,
        text: json['text']?.toString() ?? '',
      );
}

class CourseNote {
  const CourseNote({
    required this.id,
    required this.title,
    required this.url,
    required this.position,
  });

  final int id;
  final String title;
  final String url;
  final int position;

  factory CourseNote.fromJson(Map<String, dynamic> json) => CourseNote(
        id: (json['notes_id'] as num).toInt(),
        title: json['title']?.toString() ?? '',
        url: json['file_url']?.toString() ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
      );
}
