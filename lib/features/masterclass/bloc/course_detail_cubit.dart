import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_models.dart';
import '../data/masterclass_repository.dart';

sealed class CourseDetailState {
  const CourseDetailState();
}

final class CourseDetailLoading extends CourseDetailState {
  const CourseDetailLoading();
}

final class CourseDetailLoaded extends CourseDetailState {
  const CourseDetailLoaded(
    this.course, {
    this.isGeneratingCertificate = false,
    this.certificateGenerationError,
  });

  final CourseDetail course;
  final bool isGeneratingCertificate;
  final AppException? certificateGenerationError;

  CourseDetailLoaded copyWith({
    CourseDetail? course,
    bool? isGeneratingCertificate,
    AppException? certificateGenerationError,
    bool clearCertificateGenerationError = false,
  }) =>
      CourseDetailLoaded(
        course ?? this.course,
        isGeneratingCertificate:
            isGeneratingCertificate ?? this.isGeneratingCertificate,
        certificateGenerationError: clearCertificateGenerationError
            ? null
            : certificateGenerationError ?? this.certificateGenerationError,
      );
}

final class CourseDetailFailure extends CourseDetailState {
  const CourseDetailFailure(this.error);

  final AppException error;
}

class CourseDetailCubit extends Cubit<CourseDetailState> {
  CourseDetailCubit(this._repository, this.courseId)
      : super(const CourseDetailLoading());

  final MasterclassRepository _repository;
  final int courseId;

  Future<void> load() async {
    emit(const CourseDetailLoading());
    try {
      emit(CourseDetailLoaded(await _repository.getCourseDetail(courseId)));
    } on Object catch (error, stackTrace) {
      emit(
        CourseDetailFailure(
          ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
    }
  }

  Future<void> generateCertificate() async {
    final current = state;
    if (current is! CourseDetailLoaded ||
        current.isGeneratingCertificate ||
        current.course.certificate.generated) {
      return;
    }

    emit(
      current.copyWith(
        isGeneratingCertificate: true,
        clearCertificateGenerationError: true,
      ),
    );

    try {
      final certificate = await _repository.generateCertificate(courseId);
      emit(
        CourseDetailLoaded(
          current.course.copyWith(certificate: certificate),
        ),
      );
    } on Object catch (error, stackTrace) {
      emit(
        current.copyWith(
          isGeneratingCertificate: false,
          certificateGenerationError:
              ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
