import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/prakriti_models.dart';
import '../data/prakriti_repository.dart';

enum PrakritiPhase {
  /// Fetching the quiz.
  loading,

  /// The quiz could not be fetched.
  failed,

  /// Instructions (or "Continue where you stopped").
  welcome,

  /// One question per screen.
  question,

  /// Thank-you line and the disclaimer, shown before the result.
  closing,

  /// The result, either just taken or the last saved one.
  result,
}

class PrakritiQuizState {
  const PrakritiQuizState({
    this.phase = PrakritiPhase.loading,
    this.quiz,
    this.answers = const {},
    this.index = 0,
    this.result,
    this.error,
    this.submitting = false,
    this.submitError,
    this.canResume = false,
    this.versionChanged = false,
  });

  final PrakritiPhase phase;
  final PrakritiQuiz? quiz;

  /// question id -> option id
  final Map<int, int> answers;

  /// Index of the question on screen.
  final int index;
  final PrakritiResult? result;
  final AppException? error;
  final bool submitting;
  final AppException? submitError;

  /// Unfinished answers from an earlier visit are waiting on the phone.
  final bool canResume;

  /// The quiz was updated while the person was answering.
  final bool versionChanged;

  int get total => quiz?.questions.length ?? 0;
  PrakritiQuestion? get question {
    final q = quiz;
    if (q == null || phase != PrakritiPhase.question) return null;
    if (index < 0 || index >= q.questions.length) return null;
    return q.questions[index];
  }

  int? get chosen {
    final q = question;
    return q == null ? null : answers[q.id];
  }

  PrakritiQuizState copyWith({
    PrakritiPhase? phase,
    PrakritiQuiz? quiz,
    Map<int, int>? answers,
    int? index,
    PrakritiResult? result,
    AppException? error,
    bool? submitting,
    AppException? submitError,
    bool? canResume,
    bool? versionChanged,
    bool clearError = false,
    bool clearSubmitError = false,
  }) =>
      PrakritiQuizState(
        phase: phase ?? this.phase,
        quiz: quiz ?? this.quiz,
        answers: answers ?? this.answers,
        index: index ?? this.index,
        result: result ?? this.result,
        error: clearError ? null : error ?? this.error,
        submitting: submitting ?? this.submitting,
        submitError: clearSubmitError ? null : submitError ?? this.submitError,
        canResume: canResume ?? this.canResume,
        versionChanged: versionChanged ?? this.versionChanged,
      );
}

/// The Prakriti quiz: instructions, 40 questions one at a time, the disclaimer,
/// and the result (signed-in students only). The server does the scoring.
class PrakritiQuizCubit extends Cubit<PrakritiQuizState> {
  PrakritiQuizCubit(this._repository, this._progress)
      : super(const PrakritiQuizState());

  final PrakritiRepository _repository;
  final PrakritiProgressStore _progress;

  Future<void> load({bool versionChanged = false}) async {
    emit(PrakritiQuizState(versionChanged: versionChanged));
    try {
      final quiz = await _repository.getQuiz();
      PrakritiResult? saved;
      try {
        saved = await _repository.myResult();
      } on Object {
        // The saved result is a bonus; the quiz still works without it.
      }
      if (saved != null && !versionChanged) {
        emit(PrakritiQuizState(
          phase: PrakritiPhase.result,
          quiz: quiz,
          result: saved,
        ));
        return;
      }
      final progress = await _usableProgress(quiz);
      emit(PrakritiQuizState(
        phase: PrakritiPhase.welcome,
        quiz: quiz,
        answers: progress?.answers ?? const {},
        canResume: progress != null,
        versionChanged: versionChanged,
      ));
    } on Object catch (error, stackTrace) {
      emit(PrakritiQuizState(
        phase: PrakritiPhase.failed,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  /// Saved answers count only for the same quiz version and for questions that
  /// still exist; anything else is dropped.
  Future<PrakritiProgress?> _usableProgress(PrakritiQuiz quiz) async {
    final saved = await _progress.read();
    if (saved == null) return null;
    if (saved.versionId != quiz.versionId) {
      await _progress.clear();
      return null;
    }
    final ids = {for (final q in quiz.questions) q.id: q};
    final answers = <int, int>{};
    for (final e in saved.answers.entries) {
      final q = ids[e.key];
      if (q != null && q.options.any((o) => o.id == e.value)) {
        answers[e.key] = e.value;
      }
    }
    if (answers.isEmpty || answers.length >= quiz.questions.length) {
      await _progress.clear();
      return null;
    }
    return PrakritiProgress(
      versionId: quiz.versionId,
      answers: answers,
      index: saved.index,
    );
  }

  /// Starts from question 1 and forgets any saved answers.
  Future<void> start() async {
    if (state.quiz == null || state.total == 0) return;
    await _progress.clear();
    emit(state.copyWith(
      phase: PrakritiPhase.question,
      answers: const {},
      index: 0,
      canResume: false,
      versionChanged: false,
      clearSubmitError: true,
    ));
  }

  /// Carries on at the first question that has no answer yet.
  void resume() {
    final quiz = state.quiz;
    if (quiz == null) return;
    var next = quiz.questions.indexWhere((q) => !state.answers.containsKey(q.id));
    if (next < 0) next = 0;
    emit(state.copyWith(
      phase: PrakritiPhase.question,
      index: next,
      versionChanged: false,
      clearSubmitError: true,
    ));
  }

  /// Saves the answer and goes straight on; after the last question comes the
  /// disclaimer screen.
  void select(int optionId) {
    final q = state.question;
    if (q == null) return;
    final answers = {...state.answers, q.id: optionId};
    final last = state.index >= state.total - 1;
    emit(state.copyWith(
      answers: answers,
      phase: last ? PrakritiPhase.closing : PrakritiPhase.question,
      index: last ? state.index : state.index + 1,
      clearSubmitError: true,
    ));
    if (last) {
      _progress.clear();
    } else {
      _progress.save(PrakritiProgress(
        versionId: state.quiz!.versionId,
        answers: answers,
        index: state.index,
      ));
    }
  }

  /// One step back. Returns false when there is nothing to go back to (the
  /// screen then closes).
  bool back() {
    switch (state.phase) {
      case PrakritiPhase.question:
        if (state.index > 0) {
          emit(state.copyWith(index: state.index - 1));
        } else {
          emit(state.copyWith(
            phase: PrakritiPhase.welcome,
            canResume: state.answers.isNotEmpty,
          ));
        }
        return true;
      case PrakritiPhase.closing:
        emit(state.copyWith(
          phase: PrakritiPhase.question,
          index: state.total - 1,
        ));
        return true;
      case PrakritiPhase.loading:
      case PrakritiPhase.failed:
      case PrakritiPhase.welcome:
      case PrakritiPhase.result:
        return false;
    }
  }

  /// After the disclaimer the answers go to the server (the quiz needs a login).
  Future<void> continueFromClosing() => submit();

  Future<void> submit() async {
    final quiz = state.quiz;
    if (quiz == null || state.submitting) return;
    if (quiz.questions.any((q) => !state.answers.containsKey(q.id))) return;
    emit(state.copyWith(submitting: true, clearSubmitError: true));
    try {
      final result = await _repository.submit(
        versionId: quiz.versionId,
        answers: state.answers,
      );
      await _progress.clear();
      emit(state.copyWith(
        phase: PrakritiPhase.result,
        result: result,
        submitting: false,
      ));
    } on Object catch (error, stackTrace) {
      final normalized =
          ApiErrorHandler.normalize(error, stackTrace: stackTrace);
      if (normalized.errorCode == 'QUIZ_VERSION_CHANGED') {
        // The doctors published a new quiz: the old answers no longer fit.
        await _progress.clear();
        await load(versionChanged: true);
        return;
      }
      emit(state.copyWith(submitting: false, submitError: normalized));
    }
  }

  /// "Take the quiz again" from the saved result.
  Future<void> retake() async {
    await _progress.clear();
    emit(state.copyWith(
      phase: PrakritiPhase.welcome,
      answers: const {},
      index: 0,
      canResume: false,
      clearSubmitError: true,
    ));
  }
}
