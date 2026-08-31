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
- Quiz submission uses `POST /masterclasses/submit_quiz.php` through `MasterclassRepository`; screens never call the API directly.
- Quiz answers are one-time/non-reversible. Require every API question to have a selected answer and show a confirmation before submission.
- `CourseQuizCubit` owns editable quiz answers/submission state. Do not use `setState`.
- After grading, render only the API-provided student answer and `is_correct`; never infer or fabricate the correct answer because the API intentionally does not return it.
- Ignore empty option text in presentation (some True/False questions include blank option slots), but preserve backend option numbers for submitted answers.
- `QUIZ_ALREADY_SUBMITTED` must not cause a second submission; recover the completed quiz from fresh course detail when possible.
- API-provided titles/descriptions/questions/notes are domain content and are not ARB strings. UI chrome remains localized.


## Notes and certificates
- Chapter notes must use `DownloadableFileTile`/`FileDownloadService`; never download directly from presentation.
- A note with an existing local copy must open that copy instead of downloading again.
- Masterclass certificate availability comes from `certificate.generated`; its downloadable document comes from `certificate.download_url`.
- Do not fabricate a certificate URL when the backend returns none.


## Download source-of-truth rules
- Notes are chapter-scoped and use `course_detail.php -> chapters[].notes[].file_url`.
- Certificate availability on the course detail screen comes from `course_detail.php -> data.certificate`.
- `my_courses.php` may still expose certificate status for the masterclass list; do not make the course detail screen depend on list state.
- Never show a certificate as downloadable unless `generated == true` and `download_url` is non-empty.
- Never fabricate certificate recipient, certificate ID, issue date, or other metadata that the selected API does not return.

## Video playback rules
- Parse all three backend video URL fields: `video_url`, `vimeo_video_url`, and `main_video_url`.
- Course playback must use `main_video_url`.
- If `main_video_url` contains `vimeo`, use the shared Vimeo adapter; otherwise use the network/MP4 adapter.
- Keep provider detection and Vimeo WebView code out of feature presentation screens.
- Resume is keyed by backend `video_id` and is local-device state until a server progress API exists.
- Do not infer course completion from local video position.

- Do not show redundant copy that playback position is saved automatically; resume should work silently.

- Never render duplicate control layers. Respect the adapter's `VideoControlsMode`: Vimeo native controls only; MP4 custom app controls.

- Fullscreen is app-managed for reliability; do not re-enable Vimeo HTML fullscreen. Preserve playback/resume state across fullscreen transitions.

- Use `POST /masterclasses/generate_certificate.php` from course detail only when `certificate.generated == false`.
- Treat `CERTIFICATE_ALREADY_GENERATED` as an idempotent certificate result when the documented response includes `data.download_url`; do not trigger another generation attempt.
- Keep the existing certificate download/open service unchanged after generation; generation only refreshes the in-memory certificate metadata.
- Course intro must expose a visible localized “View chapters” action that scrolls to the existing chapter section.
- Selecting a chapter, or moving Previous/Next between chapters, must reset the course detail scroll position to the top.
