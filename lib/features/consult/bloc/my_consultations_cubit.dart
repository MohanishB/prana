import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/consult_checkout_models.dart';
import '../data/consult_checkout_repository.dart';

class MyConsultationsState {
  const MyConsultationsState({
    this.bookings = const [],
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final List<ConsultationBooking> bookings;
  final bool loading;
  final bool loaded;
  final AppException? error;
}

/// The student's booked consultations.
class MyConsultationsCubit extends Cubit<MyConsultationsState> {
  MyConsultationsCubit(this._repository) : super(const MyConsultationsState());

  final ConsultationCheckoutRepository _repository;

  Future<void> load() async {
    emit(MyConsultationsState(
      bookings: state.bookings,
      loaded: state.loaded,
      loading: true,
    ));
    try {
      emit(MyConsultationsState(
        bookings: await _repository.getMyBookings(),
        loaded: true,
      ));
    } on Object catch (error, stackTrace) {
      emit(MyConsultationsState(
        bookings: state.bookings,
        loaded: state.loaded,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
