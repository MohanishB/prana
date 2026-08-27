# App Layer Agent Guide

## Responsibilities
The `app` layer owns application composition, routing, shell navigation and app-wide configuration.

## Rules
- Keep all routing in `lib/app`.
- Use `go_router` only; do not introduce ad-hoc `Navigator` flows for app routes.
- Use named routes where practical.
- Keep feature business logic out of this layer.
- Keep route parameters typed/validated before handing them to a feature.
- Static user-facing labels used by app shell/navigation must come from localization.
- Do not hard-code bottom navigation labels or app-wide titles.
- Preserve deep-link-friendly route structure.
- Do not couple routes to concrete repository implementations.
