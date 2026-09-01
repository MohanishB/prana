import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import 'faq_models.dart';

abstract interface class FaqRepository {
  Future<FaqCollection> getFaqs();
}

final class ApiFaqRepository implements FaqRepository {
  ApiFaqRepository(this._api);

  final ApiClient _api;

  @override
  Future<FaqCollection> getFaqs() async {
    final json = await _api.get(ApiConstants.faqList);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Missing FAQ data');
    }
    return FaqCollection.fromJson(data);
  }
}
