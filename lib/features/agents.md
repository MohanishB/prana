# Feature Layer Agent Guide

## Structure
Each feature owns its own data, domain, BLoC/Cubit and presentation concerns.

Recommended dependency direction:

`presentation -> domain <- data`

## Localization
- Feature widgets must not hard-code static user-facing English text.
- Use `context.l10n` or the approved localization helper.
- Buttons, titles, status labels, empty states, errors, dialogs and snackbars must be localized.
- API/user/generated content should remain domain data unless translation is a product requirement.

## Design system
- Do not add feature-specific raw colors when a semantic/core color exists.
- Do not add repeated magic spacing/radius/dimension values in screens.
- Reusable visual primitives belong in `core/widgets` when feature-agnostic.
- Reusable feature-specific components belong inside that feature.

## State
- No `setState`.
- BLoC/Cubit is required for mutable feature/application state.
- UI renders state and dispatches intent; business rules do not live in widgets.

## Errors
- Feature data layers map technical failures into typed app/domain errors.
- BLoC/Cubit exposes meaningful error state.
- Presentation localizes the final user-facing message.
- Never surface raw exceptions.

## Duplication
Before adding a widget/helper/model, check whether an equivalent already exists.
Prefer composition and shared abstractions over copied screen code.
- FAQ lives in `features/faq` and follows the standard data/BLoC/presentation split.
