import 'package:flutter_test/flutter_test.dart';
import 'package:prana/core/errors/app_exception.dart';
import 'package:prana/features/auth/bloc/forgot_password_cubit.dart';
import 'package:prana/features/auth/data/auth_repository.dart';
import 'package:prana/core/session/user_session.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.error});

  final Object? error;
  final requested = <String>[];

  @override
  Future<void> requestPasswordReset(String email) async {
    requested.add(email);
    if (error != null) throw error!;
  }

  @override
  Future<UserSession?> restoreSession() async => null;

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  test('starts idle', () {
    expect(
      ForgotPasswordCubit(_FakeAuthRepository()).state,
      isA<ForgotPasswordIdle>(),
    );
  });

  test('sending goes sending -> sent and passes the email on', () async {
    final repository = _FakeAuthRepository();
    final cubit = ForgotPasswordCubit(repository);
    final states = <ForgotPasswordState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.submit('a@b.com');
    await Future<void>.delayed(Duration.zero);

    expect(repository.requested, ['a@b.com']);
    expect(states.map((s) => s.runtimeType), [
      ForgotPasswordSending,
      ForgotPasswordSent,
    ]);
    await sub.cancel();
    await cubit.close();
  });

  test('a server limit error becomes a failure the screen can show', () async {
    final cubit = ForgotPasswordCubit(
      _FakeAuthRepository(
        error: const AppException(AppErrorType.tooManyRequests),
      ),
    );

    await cubit.submit('a@b.com');

    final state = cubit.state;
    expect(state, isA<ForgotPasswordFailure>());
    expect(
      (state as ForgotPasswordFailure).error.type,
      AppErrorType.tooManyRequests,
    );
    await cubit.close();
  });

  test('can try again after a failure', () async {
    final cubit = ForgotPasswordCubit(
      _FakeAuthRepository(error: const AppException(AppErrorType.noInternet)),
    );
    await cubit.submit('a@b.com');
    expect(cubit.state, isA<ForgotPasswordFailure>());

    await cubit.submit('a@b.com');
    expect(cubit.state, isA<ForgotPasswordFailure>());
    await cubit.close();
  });
}
