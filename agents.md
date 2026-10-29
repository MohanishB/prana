# PRANA – Agent Guide (repository root)

Read this first, then the `agents.md` / `plan.md` in the folder you are changing.
Every folder listed below has its own pair of files; `plan.md` says what is done and what is next, `agents.md` says the rules.

## What this repository is
Student-facing mobile app (Flutter, iOS + Android) for "Prana by Dimple" academy, plus the PHP web services it calls, plus the admin pages and website mail code that had to change for it.

| Folder | What | Guide |
|---|---|---|
| `lib/` | The Flutter app (BLoC/Cubit, go_router) | `lib/**/agents.md` |
| `android/`, `ios/` | Platform projects (Firebase / launcher name are edited by hand). Launcher icons: heart-only logo, dark green `#12301F`, in `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset` | this file |
| `student_app_webservices/` | PHP API (PDO, JWT bearer, `Response::success/error`) | `student_app_webservices/agents.md` |
| `admin/application/` | CodeIgniter 3 admin: only the files changed for the app | `admin/agents.md` |
| `website/application/` | CodeIgniter website: only `models/Mail_model.php` | `admin/agents.md` |
| `alter*.sql` | One-time database scripts, also kept in `student_app_webservices/migrations/` | `student_app_webservices/migrations/agents.md` |

## Non-negotiable rules
1. One feature per delivery. Deliver a zip of changed files in repo structure; the owner uploads, tests, reports. The owner runs all SQL.
2. Structure: `lib/features/<name>/{bloc,data,presentation}`. Shared widgets in `core/widgets`, shared models in `core/…`. No shared "catalog" folder.
3. No `setState`. State lives in Bloc/Cubit. No raw colours, paddings or radii in feature screens: use `core/theme` tokens.
4. All user-facing text comes from `lib/l10n/app_en.arb` (`context.l10n`). Server content (course titles, messages) is data, not ARB.
5. Screens never call `ApiClient` directly: Screen → Cubit → Repository → `fetchData/postData`.
6. Logged-in calls must pass `authenticated: true` (the default is false). Forgetting it shows "session expired".
7. Payment stays simulated (`CHECKOUT_SIMULATE_PAYMENT=true`) until the owner says otherwise. Never copy the website's live Razorpay keys into the app backend.
8. Secrets are never shipped in a zip: the Mandrill key (`config/mail.php`) and the Firebase service-account JSON (path in `config/fcm.php`) are placed by the owner.
9. Dependencies are not upgraded unless asked. Flutter 3.27.2 / Dart 3.6.1, Android Gradle Plugin 8.1.1, Kotlin 1.8.22, firebase_core 3.15.2, firebase_messaging 15.2.10.
10. Never claim something works unless it was run. Tests here are PHP lint + sqlite harness tests and a Dart syntax/import/l10n check; the app has not been compiled by the agent and MySQL has not been run by the agent.
11. Launcher icon: heart only (no text), background `#12301F` (same colour as `ic_launcher_background.xml`). iOS icons must stay square and without transparency; Android adaptive foreground keeps the heart inside the centre 66 dp circle of the 108 dp canvas.
12. Vimeo videos are never played from a raw Vimeo link in the app: the backend gives a signed link to `student_app_webservices/player/player.php` and the Vimeo embed domain is that server's domain.

## PHP/MySQL lessons (cost real bugs)
- MySQL runs in strict mode: no zero dates (`1970-01-01`), no empty enum values, set every NOT NULL column.
- `PDO::ATTR_EMULATE_PREPARES=false`: a named placeholder may appear only once per statement (`:created_at`, `:modified_at`, never `:now` twice). With native prepares `prepare()` itself throws if a table is missing, so wrap prepare + execute together when a table may not exist.
- Admin/website files use CRLF line endings; app web-service files use LF. Keep each file's endings.

## Where to look for history
- `plan.md` (this folder): status of every step.
- Project docs (claude.ai Project "Prana"): `development-log.md`, `go-live-changelog.md` (DB + admin changes to repeat on live), `notifications-decisions.md`, `step4-gut-reset-decisions.md`, `open-questions.md`.
