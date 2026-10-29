import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/push/push_client.dart';
import '../../../core/push/push_message.dart';
import '../../../core/session/session_manager.dart';
import '../data/notification_repository.dart';
import 'notification_badge_cubit.dart';

/// What the screen should react to. [sequence] changes for every new event, so the same
/// message can be handled twice if it arrives twice.
class PushMessagesState extends Equatable {
  const PushMessagesState({this.sequence = 0, this.foreground, this.opened});

  final int sequence;

  /// A push that arrived while the app was open: show a banner.
  final PushMessage? foreground;

  /// A push the student tapped: open the screen it points to.
  final PushMessage? opened;

  @override
  List<Object?> get props => [sequence, foreground, opened];
}

/// Receives pushes while the app is open and when one is tapped.
class PushMessagesCubit extends Cubit<PushMessagesState> {
  PushMessagesCubit(
    this._client,
    this._notifications,
    this._badge,
    this._sessionManager,
  ) : super(const PushMessagesState());

  final PushClient _client;
  final NotificationRepository _notifications;
  final NotificationBadgeCubit _badge;
  final SessionManager _sessionManager;

  final List<StreamSubscription<PushMessage>> _subscriptions = [];
  bool _started = false;

  Future<void> start() async {
    if (_started || !_client.isAvailable) return;
    _started = true;
    _subscriptions
      ..add(_client.onForegroundMessage.listen(_onForeground))
      ..add(_client.onMessageOpened.listen(_onOpened));
    final initial = await _client.initialMessage();
    if (initial != null) _onOpened(initial);
  }

  void _onForeground(PushMessage message) {
    unawaited(_badge.refresh());
    emit(PushMessagesState(
      sequence: state.sequence + 1,
      foreground: message,
    ));
  }

  void _onOpened(PushMessage message) {
    unawaited(_markRead(message));
    emit(PushMessagesState(sequence: state.sequence + 1, opened: message));
  }

  Future<void> _markRead(PushMessage message) async {
    if (message.notificationId < 1 || _sessionManager.current == null) return;
    try {
      final unread = await _notifications.markRead(message.notificationId);
      _badge.setCount(unread);
    } on Object {
      // the message simply stays unread
    }
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
