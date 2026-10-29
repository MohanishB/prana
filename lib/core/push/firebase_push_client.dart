import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_client.dart';
import 'push_message.dart';

/// Runs when a push arrives while the app is closed. Android shows the notification
/// itself, so nothing is needed here; Firebase only requires that a top-level handler exists.
@pragma('vm:entry-point')
Future<void> pranaFirebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final class FirebasePushClient implements PushClient {
  /// iOS push needs GoogleService-Info.plist and the Apple push key (Apple Developer account).
  /// Without the plist, starting Firebase on iOS stops the app, so iOS stays off until
  /// that is set up. Then change this to true.
  static const iosEnabled = false;

  Future<bool>? _initialization;
  bool _available = false;

  @override
  bool get isAvailable => _available;

  @override
  Future<bool> initialize() => _initialization ??= _initialize();

  Future<bool> _initialize() async {
    if (defaultTargetPlatform == TargetPlatform.iOS && !iosEnabled) {
      return _available = false;
    }
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(pranaFirebaseBackgroundHandler);
      // The app shows its own banner while it is open.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
      _available = true;
    } on Object catch (error) {
      debugPrint('Push notifications are not available: $error');
      _available = false;
    }
    return _available;
  }

  @override
  Future<PushPermission> permission() async {
    if (!_available) return PushPermission.denied;
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return _map(settings.authorizationStatus);
    } on Object {
      return PushPermission.denied;
    }
  }

  @override
  Future<PushPermission> requestPermission() async {
    if (!_available) return PushPermission.denied;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return _map(settings.authorizationStatus);
    } on Object {
      return PushPermission.denied;
    }
  }

  @override
  Future<String?> getToken() async {
    if (!_available) return null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return (token == null || token.isEmpty) ? null : token;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } on Object {
      // The server stops sending to this token anyway.
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } on Object {
      // tried again on the next launch / token change
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } on Object {
      // nothing to undo
    }
  }

  @override
  Stream<String> get onTokenRefresh => _available
      ? FirebaseMessaging.instance.onTokenRefresh
      : const Stream<String>.empty();

  @override
  Stream<PushMessage> get onForegroundMessage => _available
      ? FirebaseMessaging.onMessage.map(_toMessage)
      : const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> get onMessageOpened => _available
      ? FirebaseMessaging.onMessageOpenedApp.map(_toMessage)
      : const Stream<PushMessage>.empty();

  @override
  Future<PushMessage?> initialMessage() async {
    if (!_available) return null;
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      return message == null ? null : _toMessage(message);
    } on Object {
      return null;
    }
  }

  PushPermission _map(AuthorizationStatus status) => switch (status) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional =>
          PushPermission.granted,
        AuthorizationStatus.denied => PushPermission.denied,
        AuthorizationStatus.notDetermined => PushPermission.notAsked,
      };

  PushMessage _toMessage(RemoteMessage message) {
    final data = message.data;
    return PushMessage(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      route: '${data['route'] ?? ''}',
      notificationId: int.tryParse('${data['notification_id'] ?? ''}') ?? 0,
      eventKey: '${data['event_key'] ?? ''}',
    );
  }
}
