import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/session/session_manager.dart';
import '../../../core/session/user_session.dart';
import '../data/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}
final class AuthStarted extends AuthEvent { const AuthStarted(); }
final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted(this.email, this.password);
  final String email;
  final String password;
}
final class AuthLogoutRequested extends AuthEvent { const AuthLogoutRequested(); }
final class _AuthSessionChanged extends AuthEvent {
  const _AuthSessionChanged(this.session);
  final UserSession? session;
}

sealed class AuthState { const AuthState(); }
final class AuthInitial extends AuthState { const AuthInitial(); }
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.error});
  final AppException? error;
}
final class AuthLoading extends AuthState { const AuthLoading(); }
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);
  final UserSession session;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._sessionManager) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<_AuthSessionChanged>(_onSessionChanged);
    _subscription = _sessionManager.changes.listen(
      (session) => add(_AuthSessionChanged(session)),
    );
  }

  final AuthRepository _repository;
  final SessionManager _sessionManager;
  late final StreamSubscription<UserSession?> _subscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final session = await _repository.restoreSession();
    emit(session == null
        ? const AuthUnauthenticated()
        : AuthAuthenticated(session));
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.login(email: event.email, password: event.password);
    } on Object catch (error, stackTrace) {
      emit(AuthUnauthenticated(
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
  }

  void _onSessionChanged(
    _AuthSessionChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(event.session == null
        ? const AuthUnauthenticated()
        : AuthAuthenticated(event.session!));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
