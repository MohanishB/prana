import '../../../core/checkout/checkout_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'dosha_models.dart';

/// The Dosha quiz is open to everyone. A signed-in student sends the token, so
/// the saved details come back and the student's own email is used.
abstract interface class DoshaRepository {
  Future<DoshaQuiz> getQuiz();

  Future<DoshaResult> submit({
    required CheckoutDetails details,
    required List<int> answers,
  });
}

final class ApiDoshaRepository implements DoshaRepository {
  ApiDoshaRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  bool get _loggedIn => _sessionManager.current != null;

  @override
  Future<DoshaQuiz> getQuiz() async {
    final data = await fetchData(
      _api,
      ApiConstants.doshaQuestions,
      authenticated: _loggedIn,
    );
    return parseData(() => DoshaQuiz.fromJson(data));
  }

  @override
  Future<DoshaResult> submit({
    required CheckoutDetails details,
    required List<int> answers,
  }) async {
    final data = await postData(
      _api,
      ApiConstants.doshaSubmit,
      authenticated: _loggedIn,
      body: {
        'name': details.name,
        'email': details.email,
        'country_id': details.countryId,
        'phone': details.phone,
        'answers': answers,
      },
    );
    return parseData(() => DoshaResult.fromJson(data));
  }
}
