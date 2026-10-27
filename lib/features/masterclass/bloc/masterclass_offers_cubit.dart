import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_offer_models.dart';
import '../data/masterclass_offer_repository.dart';

class MasterclassOffersState {
  const MasterclassOffersState({
    this.offers = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final List<MasterclassOffer> offers;
  final bool loading;
  final bool loaded;
  final AppException? error;
}

/// Masterclasses available to buy (Masterclass tab).
class MasterclassOffersCubit extends Cubit<MasterclassOffersState> {
  MasterclassOffersCubit(this._repository)
      : super(const MasterclassOffersState());

  final MasterclassOfferRepository _repository;

  Future<void> load() async {
    emit(MasterclassOffersState(
      offers: state.offers,
      loaded: state.loaded,
      loading: true,
    ));
    try {
      emit(MasterclassOffersState(
        offers: await _repository.getOffers(),
        loaded: true,
      ));
    } on Object catch (error, stackTrace) {
      emit(MasterclassOffersState(
        offers: state.offers,
        loaded: state.loaded,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
