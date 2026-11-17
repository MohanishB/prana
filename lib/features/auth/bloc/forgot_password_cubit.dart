import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/auth_repository.dart';

sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

final class ForgotPasswordIdle extends ForgotPasswordState {
  const ForgotPasswordIdle();
}

final class ForgotPasswordSending extends ForgotPasswordState {
  const ForgotPasswordSending();
}

/// The server accepted the request. The same state is reached whether or not the email is
/// registered, so the screen must not say which one it was.
final class ForgotPasswordSent extends ForgotPasswordState {
  const ForgotPasswordSent();
}

final class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure(this.error);
  final AppException error;
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._repository) : super(const ForgotPasswordIdle());

  final AuthRepository _repository;

  Future<void> submit(String email) async {
    if (state is ForgotPasswordSending) return;
    emit(const ForgotPasswordSending());
    try {
      await _repository.requestPasswordReset(email);
      emit(const ForgotPasswordSent());
    } on Object catch (error, stackTrace) {
      emit(
        ForgotPasswordFailure(
          ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
