# Core Layer Agent Guide

## Purpose
`core` contains reusable, feature-agnostic building blocks only.

## Design system
All reusable visual values must come from `core/theme`.
Do not place raw design constants inside feature screens when a shared token exists.

Centralize:
- colors
- spacing
- radii
- dimensions
- breakpoints
- typography
- gradients
- shadows/elevation
- reusable component sizing

Do not use raw `Color(0x...)` values inside feature presentation code.
Do not scatter numeric paddings/margins/radii throughout feature screens.

## Localization
- All static user-facing UI text must be localized.
- Use the shared localization accessor/extension from `core/localization`.
- Do not hard-code English strings in widgets, dialogs, snackbars, buttons, tabs or navigation.
- Domain data received from APIs, YouTube or the backend is not automatically ARB content.
- Errors must be converted to localized presentation messages at the UI boundary.

## Errors
- Repositories/services should throw or return typed application errors.
- BLoCs/Cubits should expose typed error state, not raw exception strings.
- Presentation converts error types into clear localized messages.
- Never display stack traces, HTTP bodies, server exception text or technical implementation details to end users.
- Unknown failures must fall back to a safe generic localized message.
- Retry actions should be provided where recovery is possible.

## State
- Do not use `setState`.
- Use BLoC/Cubit for mutable application or feature state.
- Keep ephemeral state outside widgets when it affects behavior, navigation or business rules.

## Dependencies
Core must never import from a feature.
External SDKs should be hidden behind interfaces where practical.


## Networking and session
- All HTTP calls go through `ApiClient`; feature screens must never make requests directly.
- `ApiClient` owns base URL, bearer header, authenticated `student_id`, timeout, response envelope parsing and token-expiry handling.
- Request/response logging is debug-only and redacts credentials/tokens.
- Connectivity is checked centrally through `NetworkInfo`.
- Session persistence uses secure storage; never persist access tokens in plain preferences/files.
- Validation/regex belongs in `core/validation`.

- Multipart endpoints must also go through `ApiClient`; authenticated `student_id` injection and token handling stay centralized.
- Logger redaction must cover every credential field name, including current/new/confirm password fields.


## Downloaded files
- Reusable file download/open behavior belongs in `core/files`.
- Downloaded files must be stored in the application documents directory, grouped by a stable feature folder.
- Always check for an existing local file before performing a network request.
- Partial downloads must use a temporary `.part` file and must never be treated as complete.
- Download/open failures must use typed `AppException` values and localized UI messages.
- Presentation must use BLoC/Cubit for download state; do not use `setState`.
- Do not duplicate download logic in Notes, Certificates, or future downloadable-content features.

- API callers may explicitly whitelist a documented application error code only when that endpoint contract intentionally returns usable data for that code. Token/session errors must never be whitelisted.

## Shared profile/session UI
- `UserSession` includes optional `photoUrl` and must remain backward-compatible with stored sessions that predate the field.
- `PranaAppBar` renders the authenticated session avatar and listens to session changes.
- Multipart requests may include binary files, but logs must contain only safe file metadata, never file bytes.
- Account text fields inherit the centralized `InputDecorationTheme`; avoid screen-specific field styling.

