import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/device/device_info.dart';
import '../../../core/push/push_client.dart';
import '../../../core/push/push_preferences.dart';
import '../../../core/session/session_manager.dart';
import '../data/device_token_repository.dart';

enum PushPermissionStatus {
  /// Not looked at yet.
  unknown,

  /// Show the "Turn on notifications" screen.
  askUser,

  /// Notifications are allowed and this phone is registered.
  enabled,

  /// The student refused the phone's permission question.
  systemDenied,

  /// Nothing to show now (the screen was dismissed, or was shown recently).
  hidden,

  /// Push cannot be used on this phone/build.
  unavailable,
}

class PushPermissionState extends Equatable {
  const PushPermissionState(this.status);

  final PushPermissionStatus status;

  @override
  List<Object?> get props => [status];
}

/// Asks for notification permission (once, politely) and keeps this phone's push token
/// known to the server while a student is signed in.
class PushPermissionCubit extends Cubit<PushPermissionState> {
  PushPermissionCubit(
    this._client,
    this._preferences,
    this._devices,
    this._sessionManager,
  ) : super(const PushPermissionState(PushPermissionStatus.unknown));

  final PushClient _client;
  final PushPreferences _preferences;
  final DeviceTokenRepository _devices;
  final SessionManager _sessionManager;

  /// The explanation screen is offered at most this many times, a week apart.
  static const maxPrompts = 3;
  static const promptGap = Duration(days: 7);

  bool _started = false;
  StreamSubscription<String>? _refreshSubscription;

  /// Call once the app knows who is signed in (or that nobody is).
  Future<void> start() async {
    if (_started) return;
    _started = true;
    if (!_client.isAvailable) {
      emit(const PushPermissionState(PushPermissionStatus.unavailable));
      return;
    }
    _refreshSubscription = _client.onTokenRefresh.listen(_onTokenRefreshed);

    final permission = await _client.permission();
    if (isClosed) return;
    if (permission == PushPermission.granted) {
      emit(const PushPermissionState(PushPermissionStatus.enabled));
      await syncToServer();
      return;
    }
    if (await _preferences.systemAsked()) {
      if (isClosed) return;
      emit(const PushPermissionState(PushPermissionStatus.systemDenied));
      await _client.unsubscribeFromTopic(PushTopics.allUsers);
      return;
    }
    // Not asked yet: joining the topic is harmless; the phone shows nothing until allowed.
    await _client.subscribeToTopic(PushTopics.allUsers);
    await _offerExplanation();
  }

  Future<void> _offerExplanation() async {
    final count = await _preferences.promptCount();
    final last = await _preferences.lastPromptAt();
    final tooMany = count >= maxPrompts;
    final tooSoon = last != null && DateTime.now().difference(last) < promptGap;
    if (isClosed) return;
    if (tooMany || tooSoon) {
      emit(const PushPermissionState(PushPermissionStatus.hidden));
      return;
    }
    await _preferences.recordPrompt(DateTime.now());
    if (isClosed) return;
    emit(const PushPermissionState(PushPermissionStatus.askUser));
  }

  /// "Turn on": shows the phone's own permission question.
  Future<void> turnOn() async {
    emit(const PushPermissionState(PushPermissionStatus.hidden));
    await _preferences.setSystemAsked();
    final permission = await _client.requestPermission();
    if (isClosed) return;
    if (permission == PushPermission.granted) {
      emit(const PushPermissionState(PushPermissionStatus.enabled));
      await syncToServer();
    } else {
      emit(const PushPermissionState(PushPermissionStatus.systemDenied));
      await _client.unsubscribeFromTopic(PushTopics.allUsers);
    }
  }

  /// "Not now": nothing else is shown; the screen comes back in a week (3 times at most).
  void notNow() {
    emit(const PushPermissionState(PushPermissionStatus.hidden));
  }

  /// Tells the server about this phone when a student is signed in and allowed notifications.
  /// Safe to call often; a failure is ignored (it is tried again on the next launch/login).
  Future<void> syncToServer() async {
    if (state.status != PushPermissionStatus.systemDenied) {
      // Broadcast topic: a new token (sign-out, refresh) starts with no topics.
      await _client.subscribeToTopic(PushTopics.allUsers);
    }
    if (state.status != PushPermissionStatus.enabled) return;
    if (_sessionManager.current == null) return;
    try {
      final token = await _client.getToken();
      if (token == null) return;
      final previous = await _preferences.lastToken();
      await _devices.register(
        token: token,
        deviceType: AppDeviceInfo.type,
        oldToken: previous != token ? previous : null,
      );
      await _preferences.setLastToken(token);
    } on Object {
      // best effort
    }
  }

  Future<void> _onTokenRefreshed(String token) async {
    // Signed out (or a guest): only the broadcast topic matters; syncToServer handles both.
    await syncToServer();
  }

  @override
  Future<void> close() async {
    await _refreshSubscription?.cancel();
    return super.close();
  }
}
