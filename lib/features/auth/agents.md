# Auth Feature Agent Guide

- Authentication state is owned by `AuthBloc`; presentation never persists tokens.
- Session data is stored only through `SessionStore`/`SessionManager`.
- Access tokens must use secure storage and must never be logged.
- Login validation uses `core/validation`; do not duplicate regex or validation rules.
- Static UI copy must use localization.
- Technical/API messages are mapped to typed `AppException` values before presentation.
- `TOKEN_INVALID` and `TOKEN_MISSING` clear the local session centrally in `ApiClient`.
- Device token is temporary/static until Firebase messaging is integrated.
- Never add `setState` for authentication behavior.

## Session restoration
- `AuthStarted` must restore the persisted session through `AuthRepository.restoreSession()`.
- Startup restoration refreshes the token before emitting the authenticated state when network access is available.
- Transient refresh failures may keep the locally stored session so the app can recover when connectivity returns.
- Terminal refresh failures must resolve to the unauthenticated/login state.
