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
