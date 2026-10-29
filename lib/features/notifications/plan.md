# Notifications Plan
## Done
- Step 6: inbox end to end (server, bell, list, admin "Send Inbox Message").
- Step 8: topic `all_users` subscription (admin broadcast push, see `admin/plan.md`).
- Step 7: Android push (init, explanation screen, token sync and refresh, banner, tap to open, logout clean-up, server sender).
## Next (only when told)
- iOS push (needs Apple account: plist, APNs key, set `FirebasePushClient.iosEnabled`).
- Scheduled reminders (cron every 15 min + sent-log table).
- Admin broadcast by email; push to a segment (e.g. buyers of a course) - needs per-segment topics or token lists.
- Per-notification-type settings for the student, if the owner wants them.
