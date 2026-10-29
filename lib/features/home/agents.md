# Home Agent Guide
- Data comes from `home/home.php` (signed in) or `catalog/home.php` (guest) through `HomeRepository`; the server picks INR/USD by IP.
- Layout order: greeting/name, Gut Reset, Masterclasses, Consultations. A Gut Reset type that is already upcoming/running/not started is hidden (`can_book = false`).
- Cards are `core/widgets/offer_card.dart`; do not build new card styles here.
- After a purchase the list reloads via `CatalogRefreshCubit`; do not poll.
- No `setState`; text from l10n; money text comes pre-formatted from the server (`Money`).
