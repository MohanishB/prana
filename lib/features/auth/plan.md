# Auth Feature Plan

## Completed
- Login API integration.
- Theme-aligned localized login screen.
- BLoC authentication state.
- Secure persisted session.
- Automatic session restore at startup.
- Central logout on invalid/missing bearer token.
- Central email/password validation.
- Static device token support.
- Platform device type mapping.

## Next
- Replace static device token with Firebase Messaging token.
- Integrate backend logout endpoint when requested.
- Add forgot-password/change-password flows when their APIs are selected.
- Add auth/session tests.

## Refresh token
- [x] Refresh persisted access token during app startup.
- [x] Keep login/session BLoC state synchronized through `SessionManager.changes`.
- [x] Fall back to login when refresh is rejected terminally.
- [x] Preserve working session behavior during transient connectivity/server failures.
