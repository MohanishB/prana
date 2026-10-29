# Consult Agent Guide
- Public list (`catalog/consultations.php`), detail, quote and create order (`checkout/consultation_*`), My consultations (`consultation/my_bookings.php`, needs `authenticated: true`).
- A booked consultation disappears from the Consult list (guest bookings are stored with `student_id` 0 and still hide the item).
- A guest consultation creates no account; so no inbox message and no push exist for a guest consultation.
- The calendar link opens in a web view from the confirmation screen and My consultations; it points to `WEBSITE_BASE_URL` (config/mail.php) and only works if that site reads the same database.
- Razorpay for consultation is written on the server (`startRazorpayPayment`/`confirmRazorpayPayment`) but no endpoint or screen calls it.
- Book button is fixed at the bottom of the page.
