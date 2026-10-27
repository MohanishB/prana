import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/gut_reset_models.dart';
import '../data/gut_reset_repository.dart';

class GutResetOffersState {
  const GutResetOffersState({
    this.offers = const [],
    this.loading = false,
    this.error,
  });

  final List<GutResetOffer> offers;
  final bool loading;
  final AppException? error;

  /// Programs the visitor may book now (hides a type that is upcoming/running).
  List<GutResetOffer> get bookable =>
      offers.where((offer) => offer.canBook).toList(growable: false);
}

class GutResetOffersCubit extends Cubit<GutResetOffersState> {
  GutResetOffersCubit(this._repository) : super(const GutResetOffersState());

  final GutResetRepository _repository;

  Future<void> load() async {
    emit(GutResetOffersState(offers: state.offers, loading: true));
    try {
      emit(GutResetOffersState(offers: await _repository.getOffers()));
    } on Object catch (error, stackTrace) {
      emit(GutResetOffersState(
        offers: state.offers,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
