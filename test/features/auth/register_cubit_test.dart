import 'package:flutter_test/flutter_test.dart';
import 'package:prana/core/errors/app_exception.dart';
import 'package:prana/core/session/user_session.dart';
import 'package:prana/features/auth/bloc/register_cubit.dart';
import 'package:prana/features/auth/data/auth_models.dart';
import 'package:prana/features/auth/data/auth_repository.dart';

class _Repo implements AuthRepository {
  _Repo({this.error});

  final Object? error;
  RegisterRequest? sent;

  @override
  Future<void> register(RegisterRequest request) async {
    sent = request;
    if (error != null) throw error!;
  }

  @override
  Future<UserSession?> restoreSession() async => null;

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestPasswordReset(String email) async {}
}

const _request = RegisterRequest(
  firstName: ' Asha ',
  lastName: '',
  gender: 'FEMALE',
  dob: '1990-05-01',
  countryId: 1,
  city: 'Pune',
  pincode: '',
  phone: '9876543210',
  email: 'a@x.com',
  password: 'secret1',
);

void main() {
  test('a successful sign-up passes the form on and ends without an error',
      () async {
    final repo = _Repo();
    final cubit = RegisterCubit(repo);
    await cubit.submit(_request);
    expect(repo.sent, same(_request));
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error, isNull);
  });

  test('the server message for a duplicate email is kept', () async {
    final cubit = RegisterCubit(_Repo(
      error: const AppException(
        AppErrorType.checkout,
        errorCode: 'REGISTER_EMAIL_EXISTS',
        serverMessage: 'Email address is already registered. Please log in.',
      ),
    ));
    await cubit.submit(_request);
    expect(cubit.state.submitting, isFalse);
    expect(cubit.state.error!.errorCode, 'REGISTER_EMAIL_EXISTS');
    expect(cubit.state.error!.serverMessage, contains('already registered'));
  });

  test('the request is sent with trimmed text and the device fields', () {
    final json = _request.toJson(deviceToken: 'tok', deviceType: 1);
    expect(json['first_name'], 'Asha');
    expect(json['gender'], 'FEMALE');
    expect(json['country_id'], 1);
    expect(json['device_token'], 'tok');
    expect(json['device_type'], 1);
  });
}
