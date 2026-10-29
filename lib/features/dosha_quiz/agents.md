# Dosha Quiz Agent Guide
- Questions (30) and scoring live on the server (`dosha/questions.php`, `dosha/submit.php`, content in `config/dosha_quiz.php`). The app never scores.
- One question per page: tapping an answer moves on (no Back/Next buttons); only the details page has a button. Top-left and phone Back open My account.
- Details page: empty for a guest, prefilled with the email locked for a student. Validation is `CheckoutDetails` on the server.
- Result (Vata/Pitta/Kapha; ties go Vata, then Pitta) is saved in `student_dosha_quiz_result` and emailed (admin on/off + editable text, event `dosha_result`).
- `DoshaQuizCubit` owns step and answers. No `setState`.
