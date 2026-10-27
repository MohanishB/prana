import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'gut_reset_models.dart';

/// The Gut Reset programs a visitor can book (guest or student).
abstract interface class GutResetRepository {
  Future<List<GutResetOffer>> getOffers();
}

final class ApiGutResetRepository implements GutResetRepository {
  ApiGutResetRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  @override
  Future<List<GutResetOffer>> getOffers() async {
    final data = await fetchData(
      _api,
      ApiConstants.catalogGutReset,
      authenticated: _sessionManager.current != null,
    );
    return parseData(
      () => jsonList(data['gut_reset_bookable'], GutResetOffer.fromJson),
    );
  }
}
