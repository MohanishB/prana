# Masterclass Agent Guide

- Workshops and Masterclasses are distinct domains; Workshops remain static until their API is selected.
- Masterclass API access must go through `MasterclassRepository`.
- Screens never call `ApiClient` directly.
- `student_id` and bearer token are injected centrally by `ApiClient`; do not duplicate them in repositories.
- API content such as course titles/descriptions is domain data, not localization content.
- Static UI labels/errors must use localization.
- Course IDs are backend integer IDs.
- API failures are typed and localized at presentation.
- Reusable UI belongs in feature widgets or `core/widgets` when feature-agnostic.
- No `setState`.


## Course detail UI rules
- Preserve the approved mobile information architecture: course intro -> chapters -> Intro/Videos/Quiz/Notes.
- Web LMS screenshots are content/behavior references; do not reproduce desktop layout on mobile.
- Never invent progress, watched duration, file size, pass percentage, retake policy, WhatsApp URLs, live-session URLs, or access windows when the API does not provide them.
- `CourseViewCubit` owns chapter/tab navigation state. Do not introduce `setState`.
- Quiz submission stays disabled until `/masterclasses/submit_quiz.php` is selected for integration.
- API-provided titles/descriptions/questions/notes are domain content and are not ARB strings. UI chrome remains localized.
