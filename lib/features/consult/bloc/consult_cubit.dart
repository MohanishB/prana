import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/consult_models.dart';
import '../data/consult_repository.dart';

class ConsultState {
  const ConsultState({
    this.consultations = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final List<ConsultationOffer> consultations;
  final bool loading;

  /// True once a load has finished successfully (so "nothing to book" is real).
  final bool loaded;
  final AppException? error;
}

/// Consult tab: the consultations that can be booked (guest or student).
class ConsultCubit extends Cubit<ConsultState> {
  ConsultCubit(this._repository) : super(const ConsultState());

  final ConsultRepository _repository;

  Future<void> load() async {
    emit(ConsultState(
      consultations: state.consultations,
      loaded: state.loaded,
      loading: true,
    ));
    try {
      emit(ConsultState(
        consultations: await _repository.getConsultations(),
        loaded: true,
      ));
    } on Object catch (error, stackTrace) {
      emit(ConsultState(
        consultations: state.consultations,
        loaded: state.loaded,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
