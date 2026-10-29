import 'push_message.dart';

enum PushPermission { granted, denied, notAsked }

/// Firebase topics every phone joins. The admin sends one push to the topic and Firebase
/// delivers it to every phone that joined (no list of students needed).
abstract final class PushTopics {
  static const allUsers = 'all_users';
}

/// Everything the app needs from the push service. The real implementation talks to
/// Firebase; tests use a fake.
abstract interface class PushClient {
  /// Starts the push service. Never throws: returns false when push cannot be used
  /// (for example the Firebase setup file is missing on this platform).
  Future<bool> initialize();

  bool get isAvailable;

  Future<PushPermission> permission();

  /// Shows the phone's own permission question.
  Future<PushPermission> requestPermission();

  /// This phone's push token, or null when it cannot be obtained.
  Future<String?> getToken();

  Future<void> deleteToken();

  /// Joins / leaves a topic. Never throws. A new token (after sign-out, reinstall or a
  /// refresh) starts with no topics, so this is called again whenever the token changes.
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);

  Stream<String> get onTokenRefresh;

  /// A push that arrived while the app is open.
  Stream<PushMessage> get onForegroundMessage;

  /// The student tapped a push while the app was in the background.
  Stream<PushMessage> get onMessageOpened;

  /// The push that was tapped to start the app from closed, if any.
  Future<PushMessage?> initialMessage();
}
