import 'package:flutter_test/flutter_test.dart';
import 'package:prana/core/errors/app_exception.dart';
import 'package:prana/features/prakriti_quiz/bloc/prakriti_quiz_cubit.dart';
import 'package:prana/features/prakriti_quiz/data/prakriti_models.dart';
import 'package:prana/features/prakriti_quiz/data/prakriti_repository.dart';

PrakritiQuiz _quiz({bool signedIn = false, int version = 1}) =>
    PrakritiQuiz.fromJson({
      'version': {
        'id': version,
        'name': 'v$version',
        'intro_text': 'Intro',
        'final_screen_text': 'Thanks',
        'disclaimer_text': 'Not medical',
        'not_sure_tip': 'Think of your twenties',
      },
      'total_questions': 3,
      'parts': [
        {
          'part_no': 1,
          'title': 'Body',
          'intro': 'About your body',
          'questions': [
            {
              'id': 10,
              'text': 'Q1',
              'options': [
                {'id': 101, 'text': 'a'},
                {'id': 102, 'text': 'b'},
                {'id': 103, 'text': 'c'},
              ],
            },
            {
              'id': 11,
              'text': 'Q2',
              'options': [
                {'id': 111, 'text': 'a'},
                {'id': 112, 'text': 'b'},
                {'id': 113, 'text': 'c'},
              ],
            },
          ],
        },
        {
          'part_no': 2,
          'title': 'Mind',
          'intro': '',
          'questions': [
            {
              'id': 20,
              'text': 'Q3',
              'options': [
                {'id': 201, 'text': 'a'},
                {'id': 202, 'text': 'b'},
                {'id': 203, 'text': 'c'},
              ],
            },
          ],
        },
      ],
      'profile': signedIn
          ? {'name': 'Asha', 'email': 'a@x.com', 'phone': '999', 'country_id': 1}
          : null,
    });

PrakritiResult _result() => PrakritiResult.fromJson({
      'attempt_id': 5,
      'taken_at': '2026-11-17 10:00:00',
      'type_code': 'VATA',
      'display_name': 'Vata',
      'title': 'The Creative',
      'percent': {'vata': 60, 'pitta': 25, 'kapha': 15},
      'signed_in': true,
    });

class _FakeRepository implements PrakritiRepository {
  _FakeRepository({
    this.quiz,
    this.saved,
    this.submitErrors = const [],
    this.loadError,
  });

  PrakritiQuiz? quiz;
  final PrakritiResult? saved;
  final List<AppException> submitErrors;
  final Object? loadError;
  var submitCalls = 0;
  Map<int, int>? lastAnswers;
  int? lastVersion;

  @override
  Future<PrakritiQuiz> getQuiz() async {
    if (loadError != null) throw loadError!;
    return quiz!;
  }

  @override
  Future<PrakritiResult?> myResult() async => saved;

  @override
  Future<PrakritiResult> submit({
    required int versionId,
    required Map<int, int> answers,
  }) async {
    submitCalls++;
    lastAnswers = answers;
    lastVersion = versionId;
    if (submitCalls <= submitErrors.length) throw submitErrors[submitCalls - 1];
    return _result();
  }
}

class _FakeStore implements PrakritiProgressStore {
  PrakritiProgress? saved;

  @override
  Future<PrakritiProgress?> read() async => saved;

  @override
  Future<void> save(PrakritiProgress progress) async => saved = progress;

  @override
  Future<void> clear() async => saved = null;
}

Future<void> _answerAll(PrakritiQuizCubit cubit) async {
  cubit.select(101);
  cubit.select(112);
  cubit.select(203);
}

void main() {
  test('a student sees the instructions first', () async {
    final cubit = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), _FakeStore());
    await cubit.load();
    expect(cubit.state.phase, PrakritiPhase.welcome);
    expect(cubit.state.total, 3);
    expect(cubit.state.canResume, isFalse);
  });

  test('questions are flattened with their part', () {
    final quiz = _quiz();
    expect(quiz.partCount, 2);
    expect(quiz.questions.map((q) => q.partNo), [1, 1, 2]);
    expect(quiz.questions.map((q) => q.firstInPart), [true, false, true]);
    expect(quiz.questions[1].indexInPart, 2);
  });

  test('answering moves on and the last answer opens the disclaimer', () async {
    final cubit = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), _FakeStore());
    await cubit.load();
    await cubit.start();
    expect(cubit.state.phase, PrakritiPhase.question);
    expect(cubit.state.question!.id, 10);
    cubit.select(101);
    expect(cubit.state.index, 1);
    cubit.select(112);
    expect(cubit.state.index, 2);
    cubit.select(203);
    expect(cubit.state.phase, PrakritiPhase.closing);
    expect(cubit.state.answers, {10: 101, 11: 112, 20: 203});
  });

  test('back goes one step and the instructions screen has nowhere to go',
      () async {
    final cubit = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), _FakeStore());
    await cubit.load();
    expect(cubit.back(), isFalse);
    await cubit.start();
    cubit.select(101);
    expect(cubit.back(), isTrue);
    expect(cubit.state.index, 0);
    expect(cubit.state.chosen, 101);
    expect(cubit.back(), isTrue);
    expect(cubit.state.phase, PrakritiPhase.welcome);
    await cubit.start();
    await _answerAll(cubit);
    expect(cubit.back(), isTrue);
    expect(cubit.state.phase, PrakritiPhase.question);
    expect(cubit.state.index, 2);
  });

  test('after the disclaimer the answers are submitted and the result shows',
      () async {
    final repo = _FakeRepository(quiz: _quiz(signedIn: true));
    final cubit = PrakritiQuizCubit(repo, _FakeStore());
    await cubit.load();
    await cubit.start();
    await _answerAll(cubit);
    await cubit.continueFromClosing();
    expect(cubit.state.phase, PrakritiPhase.result);
    expect(cubit.state.result!.displayName, 'Vata');
    expect(cubit.state.result!.vata, 60);
    expect(repo.lastVersion, 1);
    expect(repo.lastAnswers, {10: 101, 11: 112, 20: 203});
  });

  test('a saved result is shown first and Retake starts a new quiz', () async {
    final cubit = PrakritiQuizCubit(
      _FakeRepository(quiz: _quiz(signedIn: true), saved: _result()),
      _FakeStore(),
    );
    await cubit.load();
    expect(cubit.state.phase, PrakritiPhase.result);
    await cubit.retake();
    expect(cubit.state.phase, PrakritiPhase.welcome);
    await cubit.start();
    expect(cubit.state.phase, PrakritiPhase.question);
    expect(cubit.state.answers, isEmpty);
  });

  test('unfinished answers are saved and can be resumed', () async {
    final store = _FakeStore();
    final first = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), store);
    await first.load();
    await first.start();
    first.select(101);
    expect(store.saved!.answers, {10: 101});

    final second = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), store);
    await second.load();
    expect(second.state.canResume, isTrue);
    second.resume();
    expect(second.state.index, 1);
    expect(second.state.answers, {10: 101});
  });

  test('saved answers from another quiz version are dropped', () async {
    final store = _FakeStore()
      ..saved = const PrakritiProgress(
          versionId: 1, answers: {10: 101}, index: 1);
    final cubit =
        PrakritiQuizCubit(_FakeRepository(quiz: _quiz(version: 2)), store);
    await cubit.load();
    expect(cubit.state.canResume, isFalse);
    expect(store.saved, isNull);
  });

  test('answers that no longer match the quiz are ignored', () async {
    final store = _FakeStore()
      ..saved = const PrakritiProgress(
          versionId: 1, answers: {10: 999, 99: 1}, index: 1);
    final cubit = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), store);
    await cubit.load();
    expect(cubit.state.canResume, isFalse);
  });

  test('a finished quiz clears the saved answers', () async {
    final store = _FakeStore();
    final cubit = PrakritiQuizCubit(_FakeRepository(quiz: _quiz()), store);
    await cubit.load();
    await cubit.start();
    await _answerAll(cubit);
    expect(store.saved, isNull);
  });

  test('a changed quiz version restarts with a notice', () async {
    final repo = _FakeRepository(
      quiz: _quiz(),
      submitErrors: [
        const AppException(AppErrorType.generic,
            errorCode: 'QUIZ_VERSION_CHANGED'),
      ],
    );
    final cubit = PrakritiQuizCubit(repo, _FakeStore());
    await cubit.load();
    await cubit.start();
    await _answerAll(cubit);
    repo.quiz = _quiz(signedIn: true, version: 2);
    await cubit.continueFromClosing();
    expect(cubit.state.phase, PrakritiPhase.welcome);
    expect(cubit.state.versionChanged, isTrue);
    expect(cubit.state.answers, isEmpty);
    expect(cubit.state.quiz!.versionId, 2);
  });

  test('another submit error stays on the screen so it can be retried',
      () async {
    final repo = _FakeRepository(
      quiz: _quiz(signedIn: true),
      submitErrors: [const AppException(AppErrorType.noInternet)],
    );
    final cubit = PrakritiQuizCubit(repo, _FakeStore());
    await cubit.load();
    await cubit.start();
    await _answerAll(cubit);
    await cubit.continueFromClosing();
    expect(cubit.state.phase, PrakritiPhase.closing);
    expect(cubit.state.submitError!.type, AppErrorType.noInternet);
    expect(cubit.state.submitting, isFalse);
    await cubit.continueFromClosing();
    expect(cubit.state.phase, PrakritiPhase.result);
  });

  test('a failed load can be retried', () async {
    final repo = _FakeRepository(loadError: const AppException(AppErrorType.noInternet));
    final cubit = PrakritiQuizCubit(repo, _FakeStore());
    await cubit.load();
    expect(cubit.state.phase, PrakritiPhase.failed);
    expect(cubit.state.error!.type, AppErrorType.noInternet);
  });

  test('submit does nothing while a question is unanswered', () async {
    final repo = _FakeRepository(quiz: _quiz());
    final cubit = PrakritiQuizCubit(repo, _FakeStore());
    await cubit.load();
    await cubit.start();
    cubit.select(101);
    await cubit.submit();
    expect(repo.submitCalls, 0);
  });
}
