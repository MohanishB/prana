import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

class RegisterState {
  const RegisterState({this.submitting = false, this.error});

  final bool submitting;
  final AppException? error;
}

/// Sign-up. On success the session is set, so the app moves to the signed-in
/// screens by itself; the cubit only reports "submitting" and errors.
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState());

  final AuthRepository _repository;

  Future<void> submit(RegisterRequest request) async {
    if (state.submitting) return;
    emit(const RegisterState(submitting: true));
    try {
      await _repository.register(request);
      emit(const RegisterState());
    } on Object catch (error, stackTrace) {
      emit(RegisterState(
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
