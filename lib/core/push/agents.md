# Push (core) Agent Guide
Files: `push_client.dart` (interface), `firebase_push_client.dart` (the only file that imports firebase), `push_message.dart`, `push_preferences.dart` (what the phone remembers), `push_token_service.dart` (token for login/checkout/logout).
- Android only for now: `FirebasePushClient.iosEnabled` is false because starting Firebase on iOS without `GoogleService-Info.plist` stops the app. Set it to true after the plist and APNs key exist.
- `initialize()` never throws; if it returns false the app works without push.
- `subscribeToTopic/unsubscribeFromTopic` exist for the broadcast topic `all_users`; they never throw. Topics belong to a token, so subscribe again whenever the token changes.
- Login needs a token: real FCM token, else `local-<install id>` (the server skips those).
- Never log tokens. Never store the service-account JSON in the app.
