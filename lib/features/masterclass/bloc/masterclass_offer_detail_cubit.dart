import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_offer_models.dart';
import '../data/masterclass_offer_repository.dart';

class MasterclassOfferDetailState {
  const MasterclassOfferDetailState({
    this.detail,
    this.loading = false,
    this.error,
  });

  final MasterclassOfferDetail? detail;
  final bool loading;
  final AppException? error;
}

class MasterclassOfferDetailCubit extends Cubit<MasterclassOfferDetailState> {
  MasterclassOfferDetailCubit(this._repository, this.courseId)
      : super(const MasterclassOfferDetailState(loading: true));

  final MasterclassOfferRepository _repository;
  final int courseId;

  Future<void> load() async {
    emit(MasterclassOfferDetailState(detail: state.detail, loading: true));
    try {
      emit(MasterclassOfferDetailState(
        detail: await _repository.getOfferDetail(courseId),
      ));
    } on Object catch (error, stackTrace) {
      emit(MasterclassOfferDetailState(
        detail: state.detail,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
