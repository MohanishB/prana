import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/masterclass_models.dart';
import '../data/masterclass_repository.dart';

sealed class CourseQuizState {
  const CourseQuizState();
}

final class CourseQuizReady extends CourseQuizState {
  const CourseQuizReady({
    required this.quiz,
    required this.answers,
    this.isSubmitting = false,
    this.error,
  });

  final CourseQuiz quiz;
  final Map<int, int> answers;
  final bool isSubmitting;
  final AppException? error;

  bool get allAnswered =>
      quiz.questions.isNotEmpty &&
      quiz.questions.every((question) => answers.containsKey(question.id));

  CourseQuizReady copyWith({
    CourseQuiz? quiz,
    Map<int, int>? answers,
    bool? isSubmitting,
    AppException? error,
    bool clearError = false,
  }) =>
      CourseQuizReady(
        quiz: quiz ?? this.quiz,
        answers: answers ?? this.answers,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: clearError ? null : error ?? this.error,
      );
}

class CourseQuizCubit extends Cubit<CourseQuizState> {
  CourseQuizCubit({
    required MasterclassRepository repository,
    required this.courseId,
    required this.chapterId,
    required CourseQuiz quiz,
  })  : _repository = repository,
        super(
          CourseQuizReady(
            quiz: quiz,
            answers: {
              for (final question in quiz.questions)
                if (question.studentAnswer != null)
                  question.id: question.studentAnswer!.optionNo,
            },
          ),
        );

  final MasterclassRepository _repository;
  final int courseId;
  final int chapterId;

  void selectAnswer({
    required int quizId,
    required int optionNo,
  }) {
    final current = state;
    if (current is! CourseQuizReady ||
        current.quiz.completed ||
        current.isSubmitting) {
      return;
    }

    emit(
      current.copyWith(
        answers: {...current.answers, quizId: optionNo},
        clearError: true,
      ),
    );
  }

  Future<CourseQuiz?> submit() async {
    final current = state;
    if (current is! CourseQuizReady ||
        current.quiz.completed ||
        current.isSubmitting ||
        !current.allAnswered) {
      return null;
    }

    emit(current.copyWith(isSubmitting: true, clearError: true));

    try {
      final result = await _repository.submitQuiz(
        courseId: courseId,
        chapterId: chapterId,
        answers: current.answers,
      );
      emit(
        CourseQuizReady(
          quiz: result,
          answers: {
            for (final question in result.questions)
              if (question.studentAnswer != null)
                question.id: question.studentAnswer!.optionNo,
          },
        ),
      );
      return result;
    } on Object catch (error, stackTrace) {
      emit(
        current.copyWith(
          isSubmitting: false,
          error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
        ),
      );
      return null;
    }
  }
}
