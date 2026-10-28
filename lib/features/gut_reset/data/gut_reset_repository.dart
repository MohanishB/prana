import '../../../core/checkout/checkout_models.dart';
import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'gut_reset_models.dart';
import 'gut_reset_order_models.dart';

/// The Gut Reset programs a visitor can book (guest or student).
abstract interface class GutResetRepository {
  Future<List<GutResetOffer>> getOffers();

  /// "Book now". A signed-in student sends only the type; a guest sends the details.
  Future<GutResetOrderResult> book({
    required String type,
    CheckoutDetails? details,
  });
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

  @override
  Future<GutResetOrderResult> book({
    required String type,
    CheckoutDetails? details,
  }) async {
    final data = await postData(
      _api,
      ApiConstants.gutResetCreateOrder,
      authenticated: _sessionManager.current != null,
      body: {
        'type': type,
        if (details != null) ...{
          'name': details.name,
          'email': details.email,
          'country_id': details.countryId,
          'phone': details.phone,
        },
      },
    );
    return parseData(() => GutResetOrderResult.fromJson(data));
  }
}
