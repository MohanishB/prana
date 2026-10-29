import 'package:equatable/equatable.dart';

/// A push notification as the app sees it (independent of Firebase).
class PushMessage extends Equatable {
  const PushMessage({
    required this.title,
    required this.body,
    required this.route,
    required this.notificationId,
    required this.eventKey,
  });

  final String title;
  final String body;

  /// Where tapping it leads (same values as the inbox: home, masterclass, program:12, ...).
  final String route;

  /// The matching inbox message, 0 when the message was not stored in the inbox.
  final int notificationId;
  final String eventKey;

  @override
  List<Object?> get props => [title, body, route, notificationId, eventKey];
}
