import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_models.dart';
import '../data/masterclass_repository.dart';

sealed class CourseDetailState { const CourseDetailState(); }
final class CourseDetailLoading extends CourseDetailState { const CourseDetailLoading(); }
final class CourseDetailLoaded extends CourseDetailState {
  const CourseDetailLoaded(this.course);
  final CourseDetail course;
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
      emit(CourseDetailFailure(
        ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
