import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'consult_models.dart';

/// Consultations a visitor can book. A guest uses the public endpoints with no
/// token; a student sends the token so already-booked ones are left out.
abstract interface class ConsultRepository {
  Future<List<ConsultationOffer>> getConsultations();
  Future<ConsultationOfferDetail> getConsultationDetail(int consultationId);
}

final class ApiConsultRepository implements ConsultRepository {
  ApiConsultRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  bool get _loggedIn => _sessionManager.current != null;

  @override
  Future<List<ConsultationOffer>> getConsultations() async {
    final data = await fetchData(
      _api,
      ApiConstants.catalogConsultations,
      authenticated: _loggedIn,
    );
    return parseData(
      () => jsonList(data['consultations'], ConsultationOffer.fromJson),
    );
  }

  @override
  Future<ConsultationOfferDetail> getConsultationDetail(
    int consultationId,
  ) async {
    final data = await fetchData(
      _api,
      ApiConstants.catalogConsultationDetail,
      authenticated: _loggedIn,
      query: {'consultation_id': consultationId},
    );
    return parseData(() => ConsultationOfferDetail.fromJson(data));
  }
}
