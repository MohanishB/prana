# Prakriti Quiz Feature Guidance

- Network access only through `PrakritiRepository` and the central `ApiClient`; state only in `PrakritiQuizCubit` (no new setState for quiz logic).
- The app never scores: do not add dosha letters, weights or thresholds to the app. Option ids are opaque.
- All visible text comes from the API or `context.l10n`; do not hard-code English.
- Saved progress is phone-only and must be dropped when the version changes.
- The full module guide follows.

# Prakriti Quiz (new Dosha quiz) - module guide

Reference for the new 40-question body type quiz: logic, assumptions, scope, tables, endpoints, admin workflow and open items. Keep this file next to the code (app feature folder, `student_app_webservices/prakriti/`, admin docs).

## 1. What it is
A 40-question Ayurvedic body type (Prakriti) quiz inside the PRANA student app. It replaces the old quiz in the app everywhere (Account menu). It needs a signed-in student (a visitor who is not logged in sees "Please log in" and a Log in button). The website quiz is NOT changed and still uses the old tables.

Everything the user sees (questions, answers, result texts, thresholds, weights) lives in database tables and is edited in the admin panel by the doctors. The server does all scoring; the app only displays.

## 2. Scope
In this step (v1):
- New quiz in the app: instructions, questions (one per screen), disclaimer, result, retake.
- New webservices: `prakriti/questions.php`, `prakriti/submit.php`, `prakriti/my_result.php`.
- Result email through Notification Settings event `prakriti_result`.
- Admin menu "Prakriti Quiz": versions, settings, parts, questions + options, 7 result texts, results list.
- SQL seed of the quiz from the doctors' document (version `prakriti-v1`, live).

NOT in this step (next step, needs the owner's go-ahead):
- Daily health tips (2,555 tips: 7 body types x 365 days, from the CSV), tips table + admin, "Health tip of the day" Home card for signed-in students, daily 8:00 AM IST push + inbox by cron.
- Home page redesign (owner will send the design).
- Website quiz update.
- Premium trial / daily plan / check-ins text (not shown on the result screen).

## 3. User flow (app)
1. Account > Dosha Quiz. A signed-in student with an earlier result sees that result first with "Take the quiz again".
2. Instructions screen (text from the live version). If unfinished answers are on the phone: "Continue where you stopped" or "Start over".
3. Questions, one per screen: "Part x of 4 · Question n of 40", Back, progress bar, the part intro card at the first question of each part, the "not sure" tip under the answers. Tapping an answer moves on. Answers are shuffled by the server and the order is not fixed per question.
4. After the last question: thank-you line + disclaimer (full screen).
5. The answers are submitted straight away with the student's saved profile (no details form).
6. Result: three percentage bars, body type name and heading, elements line, description, strengths, watch-outs, food, routine, movement and mind, "What are doshas?", footer note, "Your Prana plan" (plain text), doctors' advice lines + "Book a consultation" (Consult tab), Retake button.
7. The result email is sent right after the quiz (event `prakriti_result`).

Progress is saved on the phone only (secure storage key `prana_prakriti_progress`). It is dropped when the quiz version changed, when answers no longer match the questions, and when the quiz is finished.

## 4. Scoring (server side only)
- Every question has exactly 3 options: one each for Vata (V), Pitta (P), Kapha (K). The app never sees which dosha an option belongs to (option ids are opaque).
- Each answer adds its part's weight (points) to the chosen dosha. v1 weights: Part 1 Body 2.0 (12 questions), Part 2 Digestion and appetite 1.5 (9), Part 3 Sleep, energy and activity 1.0 (8), Part 4 Mind, emotions and habits 1.0 (11). Total = 56.5 points. Total is always computed from the live active questions.
- percent of a dosha = its points / total x 100.
- Rank by points high to low. Ties: more Part 1 (lowest part_no) points first, then V, P, K.
- Thresholds (editable per version, v1 = 10 and 15):
  - first - third <= `tridoshic_max_gap` (10) -> TRIDOSHIC
  - else first - second >= `single_min_gap` (15) -> single dosha (VATA / PITTA / KAPHA)
  - else the top two together (dual). Code order VATA_PITTA, VATA_KAPHA, PITTA_KAPHA; the display name lists the stronger first (e.g. "Kapha-Pitta").
- Gap comparisons use an epsilon of 1e-9.
- Displayed percentages are whole numbers that add up to exactly 100 (largest-remainder rounding; ties go to the stronger dosha). Raw points and percentages are also stored with every attempt.
- The 7 result types: VATA, PITTA, KAPHA, VATA_PITTA, VATA_KAPHA, PITTA_KAPHA, TRIDOSHIC.
- The thresholds are a starting proposal. The doctors adjust them after testing with patients.

## 5. Versions (admin workflow)
- Statuses: draft, live, archived. The app always uses the live version.
- A live version is locked. To change it: "Copy to draft" -> edit the draft -> Publish. Only one draft at a time (named `prakriti-vN`).
- Publish checks: every active question has all 3 answers, all 7 result texts exist and are filled, thresholds valid (tridoshic < single). Publishing archives the current live version.
- Old attempts keep the version they were taken on. An app that is in the middle of the quiz when a new version is published gets QUIZ_VERSION_CHANGED, clears its saved answers and starts again with a notice.
- A draft can be deleted. Live and archived versions cannot be edited.
- Admin visibility: same as Notification Settings (any logged-in admin; there is no permission system).

## 6. Tables (migration `010_prakriti_quiz.sql`, run once on test and live; re-runnable)
- `prakriti_quiz_version`: version_id, version_name, status, tridoshic_max_gap, single_min_gap, intro_text, final_screen_text, disclaimer_text, not_sure_tip, doshas_text ("What are doshas?"), footer_text, dates.
- `prakriti_quiz_part`: part_no, part_title, part_intro, part_weight (unique version + part_no).
- `prakriti_quiz_question`: version_id, part_id, sort_order, question_text, is_active.
- `prakriti_quiz_option`: question_id, dosha (V/P/K), option_text (unique question + dosha).
- `prakriti_quiz_result`: version_id, type_code, display_name, title, elements, summary, strengths, watch_outs, food, routine, movement_mind, prana_plan (unique version + type).
- `student_app_prakriti_results`: attempt_id, student_id (always a real student; older rows with 0 came from the guest period and are not attached to anyone), name/email/phone/country, version_id, version_name, answers_json, points_json, percent_json, type_code, display_name, date_created. Each retake is a new row (history kept).
- The seed also adds the notification event `prakriti_result` (group "5. Account & engagement", email on, push and inbox off).
- The old tables (`student_dosha_quiz_result`, old questions) are untouched.

## 7. Endpoints (`student_app_webservices/prakriti/`)
- `GET questions.php` (login required): live quiz payload {version, total_questions, parts[questions[options{id,text}]], profile}. 503 QUIZ_NOT_AVAILABLE when no live version.
- `POST submit.php` (login required): `{version_id, answers:{question_id: option_id}}`; the saved profile is used. Every active question must be answered. Errors: UNAUTHORIZED 401, VALIDATION_ERROR 400, PROFILE_NOT_FOUND 404, QUIZ_VERSION_CHANGED 409, QUIZ_NOT_AVAILABLE 503, SAVE_FAILED 500.
- `GET my_result.php` (login required): `{result: payload | null}` - the student's own latest result only.
- Result email: `MailHelper::sendPrakritiResult` -> Notification Settings event `prakriti_result` (placeholders {name} {type_name} {type_title} {vata_percent} {pitta_percent} {kapha_percent} {summary} {strengths} {watch_outs} {food} {routine} {movement_mind} {footer} {contact_email}). A missing table/row falls back to the built-in default text. Email failures never fail the quiz.

## 8. Files
Webservices: `migrations/010_prakriti_quiz.sql`, `models/PrakritiQuizModel.php`, `prakriti/questions.php`, `submit.php`, `my_result.php`, `helpers/MailHelper.php` (full file; also holds the forgot-password methods). Tests: `test/prakriti_quiz_test.php` (sqlite in memory).
Admin (CI3): `controllers/Prakriti_quiz.php`, `models/Prakriti_quiz_model.php`, `views/prakriti_quiz/*` (view_versions, view_version, edit_question, edit_result_text, view_results, _top, _bottom), routes in `config/routes.php`, sidebar group "Prakriti Quiz" in `views/includes/sidebar.php`.
App: `lib/features/prakriti_quiz/{data,bloc,presentation}`, route `/prakriti-quiz` (`RouteNames.prakritiQuiz`), `ApiConstants.prakriti*`, `AppDependencies.prakritiRepository` + `prakritiProgressStore`, l10n keys `prakriti*`. The old `features/dosha_quiz` folder, its routes and its dependency are removed. Tests: `test/features/prakriti_quiz/prakriti_quiz_cubit_test.dart`.

## 9. Assumptions and decisions
- Plain text with line breaks everywhere (no HTML) in questions, answers and result texts.
- Login required (no guest path, no details form). Result email is sent for every completed quiz.
- Content (40 questions, 7 result texts) is seeded verbatim from the doctors' docx; the doctors review and edit it in the admin.
- The quiz is not a medical diagnosis; the disclaimer is shown before the result and under it.
- Consultation contact lines on the result: consultation@pranabydimple.com, 77180 20212 / 393 / 991 (set in `PrakritiQuizModel::resultPayload`).
- One live version, one draft at a time. No per-student assignment of versions.

## 10. Known limits / open items
- Dart code was written without a Flutter SDK in the build environment: run `flutter gen-l10n`, `flutter analyze`, `flutter test` and fix anything reported.
- MySQL was not available when testing; PHP tests run on sqlite with the migration translated. Run the SQL on the test server first and check the admin pages.
- Admin pages were written to match the existing CI3 admin style but were not opened in a browser.
- The old Dosha quiz strings (`dosha*`) remain in `app_en.arb` unused; they can be removed later.
- Next: daily tips + Home card + daily push (see section 2).
