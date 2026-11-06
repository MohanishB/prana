import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'cms_models.dart';

/// The admin-edited pages of the Account menu (Contact support, Terms & privacy).
abstract interface class CmsRepository {
  Future<CmsPage> getPage(CmsPageKey key);
}

final class ApiCmsRepository implements CmsRepository {
  ApiCmsRepository(this._api);

  final ApiClient _api;

  @override
  Future<CmsPage> getPage(CmsPageKey key) async {
    try {
      final response = await _api.get(
        ApiConstants.cmsPage,
        query: {'page': key.apiValue},
        authenticated: false,
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) throw const FormatException();
      return CmsPage.fromJson(data);
    } on Object catch (error, stackTrace) {
      throw ApiErrorHandler.normalize(
        error,
        stackTrace: stackTrace,
        fallback: AppErrorType.invalidResponse,
      );
    }
  }
}
