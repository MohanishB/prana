# App Layer Plan

## Completed
- `go_router` based application routing.
- Stateful shell navigation for Home, Masterclass, Consult, Library and Account.
- Central app composition.
- Light/dark theme wiring.
- Localization delegates and supported locales.

## Next
- Add authentication redirects when auth is integrated.
- Add deep links for course, consultation, certificate and library-video destinations.
- Add guarded routes for paid/entitled content.
- Add route-level analytics through an abstraction.
- Keep navigation labels fully localized as new locales are introduced.

## Done in Steps 1–7
- Guest mode (`AuthGuest`), guest-capable tabs, offer pages, checkout routes (masterclass, consultation, Gut Reset), Dosha quiz, My consultations, `/notifications` inbox route.
- Push overlay host in the app builder (Step 7).

## Next
- iOS: nothing in `app/` changes when iOS push is switched on.
