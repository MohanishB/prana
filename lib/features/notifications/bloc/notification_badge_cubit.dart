import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/session/session_manager.dart';
import '../data/notification_repository.dart';

/// The number on the bell (unread inbox messages). Shared by every screen's app bar.
class NotificationBadgeCubit extends Cubit<int> {
  NotificationBadgeCubit(this._repository, this._sessionManager) : super(0);

  final NotificationRepository _repository;
  final SessionManager _sessionManager;

  /// Asks the server for the unread count. A guest has no inbox; a failed call
  /// keeps the number that is shown.
  Future<void> refresh() async {
    if (_sessionManager.current == null) {
      if (state != 0) emit(0);
      return;
    }
    try {
      final count = await _repository.getUnreadCount();
      if (!isClosed) emit(count);
    } on Object {
      // keep the old number
    }
  }

  void setCount(int count) {
    if (!isClosed && count != state) emit(count);
  }
}
