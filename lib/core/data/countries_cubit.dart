import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/api_error_handler.dart';
import '../errors/app_exception.dart';
import 'country_models.dart';
import 'country_repository.dart';

class CountriesState {
  const CountriesState({this.countries = const [], this.loading = false, this.error});

  final List<Country> countries;
  final bool loading;
  final AppException? error;
}

/// Countries for checkout forms (guests have no profile to take them from).
class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit(this._repository) : super(const CountriesState(loading: true));

  final CountryRepository _repository;

  Future<void> load() async {
    emit(CountriesState(countries: state.countries, loading: true));
    try {
      emit(CountriesState(countries: await _repository.getCountries()));
    } on Object catch (error, stackTrace) {
      emit(CountriesState(
        countries: state.countries,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
