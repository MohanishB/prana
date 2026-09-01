import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/account_models.dart';
import '../data/account_repository.dart';

sealed class AccountProfileState {
  const AccountProfileState();
}

final class AccountProfileLoading extends AccountProfileState {
  const AccountProfileLoading();
}

final class AccountProfileLoaded extends AccountProfileState {
  const AccountProfileLoaded(this.profile);
  final AccountProfile profile;
}

final class AccountProfileFailure extends AccountProfileState {
  const AccountProfileFailure(this.error);
  final AppException error;
}

class AccountProfileCubit extends Cubit<AccountProfileState> {
  AccountProfileCubit(this._repository) : super(const AccountProfileLoading());

  final AccountRepository _repository;

  Future<void> load() async {
    emit(const AccountProfileLoading());
    try {
      emit(AccountProfileLoaded(await _repository.getProfile()));
    } on Object catch (error, stackTrace) {
      emit(
        AccountProfileFailure(
          ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
