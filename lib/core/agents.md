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


## Downloaded files
- Reusable file download/open behavior belongs in `core/files`.
- Downloaded files must be stored in the application documents directory, grouped by a stable feature folder.
- Always check for an existing local file before performing a network request.
- Partial downloads must use a temporary `.part` file and must never be treated as complete.
- Download/open failures must use typed `AppException` values and localized UI messages.
- Presentation must use BLoC/Cubit for download state; do not use `setState`.
- Do not duplicate download logic in Notes, Certificates, or future downloadable-content features.
