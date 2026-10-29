import '../../../core/models/json_readers.dart';

/// One message in the student's inbox (the bell).
final class InboxMessage {
  const InboxMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;

  /// Screen to open on tap: home, masterclass, consult, my_consultations,
  /// `program:<workshop booking id>`, or empty (nothing to open).
  final String route;
  final bool isRead;
  final DateTime? createdAt;

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    // The server writes times in India time (IST).
    final created = jsonString(json['created_at']).trim().replaceFirst(' ', 'T');
    return InboxMessage(
      id: jsonInt(json['id']),
      title: jsonString(json['title']),
      body: jsonString(json['body']),
      route: jsonString(json['route']),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: created.isEmpty
          ? null
          : DateTime.tryParse('$created+05:30')?.toLocal(),
    );
  }

  InboxMessage asRead() => InboxMessage(
        id: id,
        title: title,
        body: body,
        route: route,
        isRead: true,
        createdAt: createdAt,
      );
}

/// One page of the inbox, newest first.
final class InboxPage {
  const InboxPage({
    required this.messages,
    required this.unreadCount,
    required this.hasMore,
  });

  final List<InboxMessage> messages;
  final int unreadCount;
  final bool hasMore;

  factory InboxPage.fromJson(Map<String, dynamic> json) => InboxPage(
        messages: jsonList(json['notifications'], InboxMessage.fromJson),
        unreadCount: jsonInt(json['unread_count']),
        hasMore: json['has_more'] == true,
      );
}
