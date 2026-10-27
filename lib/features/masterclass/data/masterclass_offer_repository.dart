import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'masterclass_offer_models.dart';

/// Masterclasses a visitor can buy. A guest uses the public endpoints with no
/// token; a student sends the token so owned courses are left out and the
/// student's own prices apply.
abstract interface class MasterclassOfferRepository {
  Future<List<MasterclassOffer>> getOffers();
  Future<MasterclassOfferDetail> getOfferDetail(int courseId);
}

final class ApiMasterclassOfferRepository
    implements MasterclassOfferRepository {
  ApiMasterclassOfferRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  bool get _loggedIn => _sessionManager.current != null;

  @override
  Future<List<MasterclassOffer>> getOffers() async {
    final data = await fetchData(
      _api,
      ApiConstants.catalogMasterclasses,
      authenticated: _loggedIn,
    );
    return parseData(
      () => jsonList(data['masterclasses'], MasterclassOffer.fromJson),
    );
  }

  @override
  Future<MasterclassOfferDetail> getOfferDetail(int courseId) async {
    final data = await fetchData(
      _api,
      ApiConstants.catalogMasterclassDetail,
      authenticated: _loggedIn,
      query: {'course_id': courseId},
    );
    return parseData(() => MasterclassOfferDetail.fromJson(data));
  }
}
