import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'certificate_models.dart';

/// The signed-in student's generated certificates, newest first.
abstract interface class CertificateRepository {
  Future<List<StudentCertificate>> getMyCertificates();
}

final class ApiCertificateRepository implements CertificateRepository {
  ApiCertificateRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<StudentCertificate>> getMyCertificates() async {
    try {
      final response = await _api.get(ApiConstants.myCertificates);
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return jsonList(data['certificates'], StudentCertificate.fromJson)
          .where((c) => c.downloadUrl.trim().isNotEmpty)
          .toList(growable: false);
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }
}
