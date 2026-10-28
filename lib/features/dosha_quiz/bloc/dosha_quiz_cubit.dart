import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/checkout/checkout_models.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/dosha_models.dart';
import '../data/dosha_repository.dart';

class DoshaQuizState {
  const DoshaQuizState({
    this.quiz,
    this.loading = true,
    this.error,
    this.answers = const [],
    this.step = 0,
    this.submitting = false,
    this.submitError,
    this.result,
  });

  final DoshaQuiz? quiz;
  final bool loading;
  final AppException? error;

  /// The chosen option (0 to 2) for each question; null while unanswered.
  final List<int?> answers;

  /// 0 .. questions-1 are the questions; [questionCount] is the details screen.
  final int step;
  final bool submitting;
  final AppException? submitError;
  final DoshaResult? result;

  int get questionCount => quiz?.questions.length ?? 0;
  bool get onDetails => quiz != null && step >= questionCount;

  DoshaQuizState copyWith({
    DoshaQuiz? quiz,
    bool? loading,
    AppException? error,
    List<int?>? answers,
    int? step,
    bool? submitting,
    AppException? submitError,
    DoshaResult? result,
    bool clearError = false,
    bool clearSubmitError = false,
  }) =>
      DoshaQuizState(
        quiz: quiz ?? this.quiz,
        loading: loading ?? this.loading,
        error: clearError ? null : error ?? this.error,
        answers: answers ?? this.answers,
        step: step ?? this.step,
        submitting: submitting ?? this.submitting,
        submitError: clearSubmitError ? null : submitError ?? this.submitError,
        result: result ?? this.result,
      );
}

/// The Dosha quiz: one question at a time, then the details, then the result.
class DoshaQuizCubit extends Cubit<DoshaQuizState> {
  DoshaQuizCubit(this._repository) : super(const DoshaQuizState());

  final DoshaRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final quiz = await _repository.getQuiz();
      emit(DoshaQuizState(
        quiz: quiz,
        loading: false,
        answers: List<int?>.filled(quiz.questions.length, null),
      ));
    } on Object catch (error, stackTrace) {
      emit(state.copyWith(
        loading: false,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  /// Saves the answer and goes straight to the next question (after the last
  /// question comes the details screen).
  void select(int option) {
    if (state.onDetails || state.quiz == null) return;
    final answers = [...state.answers]..[state.step] = option;
    emit(state.copyWith(
      answers: answers,
      step: state.step + 1,
      clearSubmitError: true,
    ));
  }

  Future<void> submit(CheckoutDetails details) async {
    if (state.submitting || state.answers.any((a) => a == null)) return;
    emit(state.copyWith(submitting: true, clearSubmitError: true));
    try {
      final result = await _repository.submit(
        details: details,
        answers: [for (final a in state.answers) a!],
      );
      emit(state.copyWith(submitting: false, result: result));
    } on Object catch (error, stackTrace) {
      emit(state.copyWith(
        submitting: false,
        submitError: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }
}
