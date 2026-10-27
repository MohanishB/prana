import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import '../../../core/session/session_manager.dart';
import 'home_models.dart';

/// Home data: a student gets their own programs and courses plus what they can
/// book; a guest (no session) gets the public catalogue.
abstract interface class HomeRepository {
  Future<HomeData> getHome();
}

final class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._api, this._sessionManager);

  final ApiClient _api;
  final SessionManager _sessionManager;

  @override
  Future<HomeData> getHome() async {
    final loggedIn = _sessionManager.current != null;
    final data = await fetchData(
      _api,
      loggedIn ? ApiConstants.home : ApiConstants.catalogHome,
      authenticated: loggedIn,
    );
    return parseData(() => HomeData.fromJson(data));
  }
}
