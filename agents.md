# PRANA Agent Guide

## Non-negotiable engineering rules
- No `setState`.
- Use BLoC/Cubit for mutable feature/application state.
- Use `go_router` for app navigation.
- All static user-facing UI text must be localized.
- Do not hard-code screen labels, buttons, statuses, errors, dialogs or navigation text.
- Colors, spacing, radii, dimensions, typography, gradients and breakpoints must use the core design system.
- Avoid duplication; promote reusable primitives appropriately.
- Technical failures must be converted into typed errors and then localized, meaningful user messages.
- Never expose raw exceptions, HTTP payloads or provider errors to users.
- External integrations such as YouTube and payments must sit behind abstractions.
- Never ship API/payment/YouTube secrets in the client.
- Preserve phone/tablet and light/dark support.

## Review checklist
- `flutter analyze` passes.
- No `setState`.
- No hard-coded static UI strings in feature screens.
- No raw feature `Color(0x...)` values.
- No repeated magic layout values when tokens exist.
- Loading/error/empty states are deliberate.
- Error messages are localized and user-friendly.
- Repositories remain replaceable.
