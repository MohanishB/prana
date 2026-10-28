import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/checkout/checkout_models.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/gut_reset_order_models.dart';
import '../data/gut_reset_repository.dart';

class GutResetCheckoutState {
  const GutResetCheckoutState({this.placing = false, this.error, this.result});

  final bool placing;
  final AppException? error;
  final GutResetOrderResult? result;
}

/// "Book now" for a 3-day or 7-day Gut Reset. While payment is in test mode the
/// server records the booking as paid straight away.
class GutResetCheckoutCubit extends Cubit<GutResetCheckoutState> {
  GutResetCheckoutCubit(this._repository)
      : super(const GutResetCheckoutState());

  final GutResetRepository _repository;

  Future<void> book(String type, {CheckoutDetails? details}) async {
    if (state.placing || state.result != null) return;
    emit(const GutResetCheckoutState(placing: true));
    try {
      final result = await _repository.book(type: type, details: details);
      emit(GutResetCheckoutState(result: result));
    } on Object catch (error, stackTrace) {
      emit(GutResetCheckoutState(
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
