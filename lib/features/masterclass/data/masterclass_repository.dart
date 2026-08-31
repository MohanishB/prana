import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'masterclass_models.dart';

abstract interface class MasterclassRepository {
  Future<List<MasterclassCourse>> getMyCourses();
  Future<CourseDetail> getCourseDetail(int courseId);
  Future<CourseCertificate> generateCertificate(int courseId);
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
}
