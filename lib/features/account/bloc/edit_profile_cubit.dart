import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/account_models.dart';
import '../data/account_repository.dart';

sealed class EditProfileState {
  const EditProfileState({this.selectedPhotoPath});

  final String? selectedPhotoPath;
}

final class EditProfileIdle extends EditProfileState {
  const EditProfileIdle({super.selectedPhotoPath});
}

final class EditProfileSaving extends EditProfileState {
  const EditProfileSaving({super.selectedPhotoPath});
}

final class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess(
    this.profile, {
    super.selectedPhotoPath,
  });

  final AccountProfile profile;
}

final class EditProfileFailure extends EditProfileState {
  const EditProfileFailure(
    this.error, {
    super.selectedPhotoPath,
  });

  final AppException error;
}

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._repository) : super(const EditProfileIdle());

  final AccountRepository _repository;

  void selectPhoto(String path) {
    if (state is EditProfileSaving) return;
    final value = path.trim();
    emit(
      EditProfileIdle(
        selectedPhotoPath: value.isEmpty ? null : value,
      ),
    );
  }

  Future<void> save(UpdateProfileRequest request) async {
    if (state is EditProfileSaving) return;
    final photoPath = state.selectedPhotoPath;
    emit(EditProfileSaving(selectedPhotoPath: photoPath));
    try {
      emit(
        EditProfileSuccess(
          await _repository.updateProfile(
            UpdateProfileRequest(
              firstName: request.firstName,
              middleName: request.middleName,
              lastName: request.lastName,
              gender: request.gender,
              dob: request.dob,
              countryId: request.countryId,
              cityName: request.cityName,
              pincode: request.pincode,
              photoPath: photoPath,
            ),
          ),
          selectedPhotoPath: photoPath,
        ),
      );
    } on Object catch (error, stackTrace) {
      emit(
        EditProfileFailure(
          ApiErrorHandler.normalize(error, stackTrace: stackTrace),
          selectedPhotoPath: photoPath,
        ),
      );
    }
  }
}
