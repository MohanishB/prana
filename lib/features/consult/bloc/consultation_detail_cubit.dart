import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/consult_models.dart';
import '../data/consult_repository.dart';

class ConsultationDetailState {
  const ConsultationDetailState({
    this.detail,
    this.loading = false,
    this.error,
  });

  final ConsultationOfferDetail? detail;
  final bool loading;
  final AppException? error;
}

class ConsultationDetailCubit extends Cubit<ConsultationDetailState> {
  ConsultationDetailCubit(this._repository, this.consultationId)
      : super(const ConsultationDetailState(loading: true));

  final ConsultRepository _repository;
  final int consultationId;

  Future<void> load() async {
    emit(ConsultationDetailState(detail: state.detail, loading: true));
    try {
      emit(ConsultationDetailState(
        detail: await _repository.getConsultationDetail(consultationId),
      ));
    } on Object catch (error, stackTrace) {
      emit(ConsultationDetailState(
        detail: state.detail,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
