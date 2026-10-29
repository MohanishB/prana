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

## Added in Steps 1–7
- `app.dart` swaps the router by auth state: `loadingRouter` (AuthInitial), `appRouter` (signed in or guest), `loginRouter` (signed out). Entering the app always goes to `/home`; a token refresh must not reset navigation.
- `MaterialApp.router(builder:)` wraps every router in `PushOverlayHost` (features/notifications): the "Turn on notifications" screen, the in-app push banner and tap-to-open all live there because they must work over the login screen too. Do not add a route for them.
- `MultiBlocListener` in `PranaApp`: refresh the bell on login/logout and after purchases (`CatalogRefreshCubit`); start push (`PushPermissionCubit`, `PushMessagesCubit`) once auth is known; sync the token when a student is signed in.
- New routes must be registered in `route_names.dart` and `router.dart`; a screen reached from a notification must also be handled in `openInboxRouteOn` (features/notifications).
