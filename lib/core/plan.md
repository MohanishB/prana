# Core Layer Plan

## Completed
- Centralized theme foundation.
- Shared color, spacing and radius tokens.
- Shared responsive content primitives.
- Shared PRANA app bar/logo/status components.
- Localization accessor.
- Typed application error model and error normalization.
- Reusable localized error presentation.

## Next
- Add secure storage abstraction for authentication tokens.
- Add HTTP client abstraction and interceptors.
- Add API response/error mapping.
- Add analytics and crash-reporting adapters.
- Add local cache abstraction.
- Expand design tokens only when repeated values appear; avoid token bloat.
- Add accessibility helpers for minimum tap sizes and text scaling.

## API foundation completed
- API client and centralized base URL/endpoints.
- Debug request/response logger with secret redaction.
- Internet reachability check.
- Secure session storage/manager.
- Central token/session invalidation.
- Shared validators.


## File downloads completed
- Shared `FileDownloadService` for persistent local downloads.
- Existing-file detection to prevent duplicate downloads.
- Connectivity-aware downloads with timeout/error handling.
- Partial-file protection.
- Shared `FileDownloadCubit` and reusable `DownloadableFileTile`.
- Local file opening through the platform file viewer.

- Added narrowly scoped accepted API error-envelope support for idempotent endpoint contracts such as `CERTIFICATE_ALREADY_GENERATED`, while preserving normal centralized auth/session error handling.

## Account API support completed
- Multipart form POST support for profile updates.
- Account-specific API error mappings.
- Password request fields added to debug-log redaction.

## Shared profile UI support
- [x] Persist optional profile photo URL in the session.
- [x] Make app-bar avatar react to session profile changes.
- [x] Support file parts in centralized multipart requests.
- [x] Standardize input decoration for account and authentication forms.

## Refresh token integration
- [x] Add refresh-token endpoint constant.
- [x] Preserve stored expired sessions long enough to attempt the backend refresh window.
- [x] Refresh access token at app startup.
- [x] Refresh before authenticated calls when the local token is expired.
- [x] Retry an authenticated request once after token-invalid/token-missing responses.
- [x] Persist refreshed token/expiry while retaining student profile/session metadata.
- [x] Clear the session on terminal refresh failures.
- [x] Redact refresh token values in API logs.
