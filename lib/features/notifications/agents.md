# Notifications Agent Guide
Three channels, all controlled by the admin "Notification Settings" page (table `notification_settings`):
- **Email** – website/admin/app mailers.
- **Inbox** – the bell + list (`student_app_notifications`). Written by `NotificationService::notify` on the server.
- **Push** – Firebase Cloud Messaging, sent by the server right after the inbox message is stored (same title/text, edited in Notification Settings).

## App rules
- Inbox: `NotificationBadgeCubit` (the bell number, refreshed on login/logout, after purchases, on resume, on a push), `NotificationsCubit` (list, paging, mark read), `openInboxRoute/openInboxRouteOn` (route values: `home`, `masterclass`, `consult`, `my_consultations`, `program:<id>`; unknown or empty opens nothing).
- Push: `PushPermissionCubit` decides when to ask and keeps the token on the server; `PushMessagesCubit` turns Firebase events into state; `PushOverlayHost` (in the app builder) shows the screen/banner and navigates. Firebase classes are used only inside `core/push/firebase_push_client.dart`.
- Asking for permission: our own explanation screen first (Turn on / Not now). "Not now" never shows the phone's real prompt. The screen is offered at most 3 times, 7 days apart (stored in secure storage). After the real prompt is refused the app never asks again and the Account tab shows a note.
- Broadcast topic: every phone joins the Firebase topic `all_users` (`PushTopics.allUsers`) from `PushPermissionCubit` (at start, after the permission answer, and whenever the token changes: a new token has no topics). A phone whose permission was refused leaves the topic. The admin sends ONE message to the topic; the app does nothing special, the push arrives like any other (banner while open, `route` data opens a screen).
- A guest purchase sends the push token with the order; the server links it only to an account created by that order.
- Foreground pushes show a banner (no extra package); background/closed pushes are shown by Android itself (channel `prana_general`).
- Do not add `flutter_local_notifications` without being asked.
