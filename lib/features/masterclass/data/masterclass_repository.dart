import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'masterclass_models.dart';

abstract interface class MasterclassRepository {
  Future<List<MasterclassCourse>> getMyCourses();
  Future<CourseDetail> getCourseDetail(int courseId);
  Future<CourseCertificate> generateCertificate(int courseId);
  Future<CourseQuiz> submitQuiz({
    required int courseId,
    required int chapterId,
    required Map<int, int> answers,
  });
}

final class ApiMasterclassRepository implements MasterclassRepository {
  ApiMasterclassRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<MasterclassCourse>> getMyCourses() async {
    try {
      final response = await _api.get(ApiConstants.myCourses);
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return ((data['courses'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => MasterclassCourse.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }

  @override
  Future<CourseDetail> getCourseDetail(int courseId) async {
    try {
      final response = await _api.get(
        ApiConstants.courseDetail,
        query: {'course_id': courseId},
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return CourseDetail.fromJson(data);
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }

  @override
  Future<CourseCertificate> generateCertificate(int courseId) async {
    try {
      final response = await _api.post(
        ApiConstants.generateCertificate,
        body: {'course_id': courseId},
        acceptedErrorCodes: const {'CERTIFICATE_ALREADY_GENERATED'},
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();

      final certificate = CourseCertificate(
        generated: true,
        generatedOn: data['generated_on']?.toString() ?? '',
        downloadUrl: data['download_url']?.toString() ?? '',
      );

      if (!certificate.canDownload) throw const FormatException();
      return certificate;
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }
  @override
  Future<CourseQuiz> submitQuiz({
    required int courseId,
    required int chapterId,
    required Map<int, int> answers,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.submitQuiz,
        body: {
          'course_id': courseId,
          'chapter_id': chapterId,
          'answers': answers.map(
            (quizId, optionNo) => MapEntry(quizId.toString(), optionNo),
          ),
        },
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return CourseQuiz.fromSubmission(data);
    } on AppException catch (error, stackTrace) {
      if (error.errorCode == 'QUIZ_ALREADY_SUBMITTED') {
        final detail = await getCourseDetail(courseId);
        for (final chapter in detail.chapters) {
          if (chapter.id == chapterId && chapter.quiz.completed) {
            return chapter.quiz;
          }
        }
      }
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }


}
