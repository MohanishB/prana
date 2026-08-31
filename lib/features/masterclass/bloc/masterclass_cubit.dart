import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_models.dart';
import '../data/masterclass_repository.dart';

enum MasterclassSection { workshops, masterclasses }

class MasterclassState {
  const MasterclassState({
    this.section = MasterclassSection.workshops,
    this.courses = const [],
    this.loading = false,
    this.error,
  });
  final MasterclassSection section;
  final List<MasterclassCourse> courses;
  final bool loading;
  final AppException? error;

  MasterclassState copyWith({
    MasterclassSection? section,
    List<MasterclassCourse>? courses,
    bool? loading,
    AppException? error,
    bool clearError = false,
  }) =>
      MasterclassState(
        section: section ?? this.section,
        courses: courses ?? this.courses,
        loading: loading ?? this.loading,
        error: clearError ? null : error ?? this.error,
      );
}

class MasterclassCubit extends Cubit<MasterclassState> {
  MasterclassCubit(this._repository) : super(const MasterclassState());
  final MasterclassRepository _repository;

  void select(MasterclassSection section) {
    emit(state.copyWith(section: section, clearError: true));
    if (section == MasterclassSection.masterclasses &&
        state.courses.isEmpty &&
        !state.loading) {
      loadCourses();
    }
  }

  Future<void> loadCourses() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final courses = await _repository.getMyCourses();
      emit(state.copyWith(courses: courses, loading: false, clearError: true));
    } on Object catch (error, stackTrace) {
      emit(state.copyWith(
        loading: false,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
