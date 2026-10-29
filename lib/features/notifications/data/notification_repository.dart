import '../../../core/models/json_readers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_data.dart';
import 'notification_models.dart';

/// The student's inbox. Every call needs the student's token.
abstract interface class NotificationRepository {
  /// Newest first. For the next page pass the smallest id received as [beforeId].
  Future<InboxPage> getPage({int beforeId = 0});

  Future<int> getUnreadCount();

  /// Returns the new unread count.
  Future<int> markRead(int id);

  /// Returns the new unread count.
  Future<int> markAllRead();
}

final class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._api);

  final ApiClient _api;

  @override
  Future<InboxPage> getPage({int beforeId = 0}) async {
    final data = await fetchData(
      _api,
      ApiConstants.notificationsList,
      authenticated: true,
      query: <String, Object?>{
        'limit': 30,
        if (beforeId > 0) 'before_id': beforeId,
      },
    );
    return parseData(() => InboxPage.fromJson(data));
  }

  @override
  Future<int> getUnreadCount() async {
    final data = await fetchData(
      _api,
      ApiConstants.notificationsUnreadCount,
      authenticated: true,
    );
    return parseData(() => jsonInt(data['unread_count']));
  }

  @override
  Future<int> markRead(int id) async {
    final data = await postData(
      _api,
      ApiConstants.notificationsMarkRead,
      authenticated: true,
      body: {'id': id},
    );
    return parseData(() => jsonInt(data['unread_count']));
  }

  @override
  Future<int> markAllRead() async {
    final data = await postData(
      _api,
      ApiConstants.notificationsMarkRead,
      authenticated: true,
      body: {'all': true},
    );
    return parseData(() => jsonInt(data['unread_count']));
  }
}
