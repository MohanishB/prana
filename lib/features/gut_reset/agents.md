# Gut Reset (offer and booking) Agent Guide
- Offers come from `catalog/gut_reset.php` (`gut_reset_bookable`). Booking = `checkout/gut_reset_create_order.php` (login optional). A signed-in student sends only the type; a guest sends name/email/country/phone and gets a new account (default password shown on the booked screen).
- Payment is simulated (test mode); `GutResetCheckoutModel::createPaidBooking` is also what the future Swipe Pages webhook will call.
- 3-day: starts on a Friday (booked Mon–Thu = coming Friday, Fri–Sun = the following Friday; the next 3-day takes the next free Friday). 7-day: no days until the student taps "Start Day 1" (in `features/workshops`); each next day opens 24 h later.
- Fixed Book button at the bottom; signed-in students confirm "Book now (test mode)?".
- Guest orders also send the push token (if allowed) so the first push reaches the new account.
- Programme viewing/day videos are `features/workshops`, not here.
