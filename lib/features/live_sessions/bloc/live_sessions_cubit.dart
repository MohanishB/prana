import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/live_session_models.dart';
import '../data/live_session_repository.dart';

class LiveSessionsState {
  const LiveSessionsState({
    this.sessions = const [],
    this.now,
    this.loading = false,
    this.loaded = false,
    this.error,
  });

  final List<LiveSession> sessions;

  /// The current server time (IST as typed in the admin); null before the first load.
  final DateTime? now;
  final bool loading;
  final bool loaded;
  final AppException? error;

  LiveSessionsState withNow(DateTime value) => LiveSessionsState(
        sessions: sessions,
        now: value,
        loading: loading,
        loaded: loaded,
        error: error,
      );
}

/// The upcoming live Q&A sessions, in the order the server sends them. Keeps a
/// server-time clock ticking so the Join button turns on at the start time and
/// the session leaves the list at the end time without a manual refresh.
class LiveSessionsCubit extends Cubit<LiveSessionsState> {
  LiveSessionsCubit(this._repository) : super(const LiveSessionsState());

  static const _tick = Duration(seconds: 15);

  final LiveSessionRepository _repository;
  Duration _serverOffset = Duration.zero;
  Timer? _timer;

  DateTime _serverNow() => DateTime.now().add(_serverOffset);

  Future<void> load() async {
    emit(LiveSessionsState(
      sessions: state.sessions,
      now: state.now,
      loaded: state.loaded,
      loading: true,
    ));
    try {
      final data = await _repository.getUpcomingSessions();
      if (isClosed) return;
      final serverTime = data.serverTime;
      _serverOffset = serverTime == null
          ? Duration.zero
          : serverTime.difference(DateTime.now());
      emit(LiveSessionsState(
        sessions: data.sessions,
        now: _serverNow(),
        loaded: true,
      ));
      _timer?.cancel();
      _timer = Timer.periodic(_tick, (_) {
        if (!isClosed) emit(state.withNow(_serverNow()));
      });
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      emit(LiveSessionsState(
        sessions: state.sessions,
        now: state.now,
        loaded: state.loaded,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
