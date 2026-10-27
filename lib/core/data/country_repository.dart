import '../models/json_readers.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/api_data.dart';
import 'country_models.dart';

abstract interface class CountryRepository {
  Future<List<Country>> getCountries();
}

final class ApiCountryRepository implements CountryRepository {
  ApiCountryRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Country>> getCountries() async {
    final data = await fetchData(_api, ApiConstants.catalogCountries);
    return parseData(() => jsonList(data['countries'], Country.fromJson));
  }
}
