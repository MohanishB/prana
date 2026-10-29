import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../data/notification_models.dart';
import '../data/notification_repository.dart';
import 'notification_badge_cubit.dart';

class NotificationsState {
  const NotificationsState({
    this.messages = const [],
    this.loading = false,
    this.loadingMore = false,
    this.loaded = false,
    this.hasMore = false,
    this.error,
  });

  final List<InboxMessage> messages;
  final bool loading;
  final bool loadingMore;
  final bool loaded;
  final bool hasMore;
  final AppException? error;

  NotificationsState copyWith({
    List<InboxMessage>? messages,
    bool? loading,
    bool? loadingMore,
    bool? loaded,
    bool? hasMore,
    AppException? error,
    bool clearError = false,
  }) =>
      NotificationsState(
        messages: messages ?? this.messages,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        loaded: loaded ?? this.loaded,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : (error ?? this.error),
      );
}

/// The inbox list: first page, "Load more", mark one / all as read.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository, this._badge)
      : super(const NotificationsState());

  final NotificationRepository _repository;
  final NotificationBadgeCubit _badge;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final page = await _repository.getPage();
      emit(NotificationsState(
        messages: page.messages,
        loaded: true,
        hasMore: page.hasMore,
      ));
      _badge.setCount(page.unreadCount);
    } on Object catch (error, stackTrace) {
      emit(state.copyWith(
        loading: false,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.messages.isEmpty) return;
    emit(state.copyWith(loadingMore: true, clearError: true));
    try {
      final page = await _repository.getPage(beforeId: state.messages.last.id);
      emit(state.copyWith(
        messages: [...state.messages, ...page.messages],
        loadingMore: false,
        hasMore: page.hasMore,
      ));
      _badge.setCount(page.unreadCount);
    } on Object catch (error, stackTrace) {
      emit(state.copyWith(
        loadingMore: false,
        error: ApiErrorHandler.normalize(error, stackTrace: stackTrace),
      ));
    }
  }

  /// Marks one message read: shown as read at once, saved in the background.
  Future<void> markRead(InboxMessage message) async {
    if (message.isRead) return;
    emit(state.copyWith(messages: [
      for (final m in state.messages) m.id == message.id ? m.asRead() : m,
    ]));
    try {
      _badge.setCount(await _repository.markRead(message.id));
    } on Object {
      // The next refresh shows the real state.
    }
  }

  Future<void> markAllRead() async {
    if (state.messages.every((m) => m.isRead) && _badge.state == 0) return;
    emit(state.copyWith(
      messages: [for (final m in state.messages) m.asRead()],
    ));
    try {
      _badge.setCount(await _repository.markAllRead());
    } on Object {
      // The next refresh shows the real state.
    }
  }
}
