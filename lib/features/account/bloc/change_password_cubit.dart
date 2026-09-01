import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/account_repository.dart';

sealed class ChangePasswordState {
  const ChangePasswordState();
}

final class ChangePasswordIdle extends ChangePasswordState {
  const ChangePasswordIdle();
}

final class ChangePasswordSubmitting extends ChangePasswordState {
  const ChangePasswordSubmitting();
}

final class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

final class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure(this.error);
  final AppException error;
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._repository) : super(const ChangePasswordIdle());

  final AccountRepository _repository;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (state is ChangePasswordSubmitting) return;
    emit(const ChangePasswordSubmitting());
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      emit(const ChangePasswordSuccess());
    } on Object catch (error, stackTrace) {
      emit(
        ChangePasswordFailure(
          ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
