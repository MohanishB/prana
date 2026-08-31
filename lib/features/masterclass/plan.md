# Masterclass Plan

## Completed
- `GET /masterclasses/my_courses.php`.
- `GET /masterclasses/course_detail.php`.
- Repository/model mapping and typed API errors.
- BLoC/Cubit loading, success, empty and error states.
- Authenticated requests with central student/session injection.
- API-driven course intro, chapter list and chapter detail experience.
- Chapter tabs: Intro, Videos, Quiz (when available), Notes (when available).
- Completed quiz answers/scores are rendered from `course_detail.php`.
- `POST /masterclasses/submit_quiz.php` is integrated with one-answer-per-question selection, complete-answer validation, irreversible-submit confirmation, loading/error states, and API-graded results.
- Quiz selections/submission are owned by `CourseQuizCubit`; successful results update the in-memory chapter quiz without resetting chapter navigation.
- Blank backend option slots are hidden from the quiz UI while real `option_no` values remain the submission source of truth.
- Notes use the shared persistent download service. They are downloaded once, kept locally, and can be reopened without another download.
- Previous/Next chapter navigation is presentation state owned by `CourseViewCubit`.
- UI follows the approved mobile wireframe while mapping to the web LMS content structure.

## Explicitly deferred
- Per-video watched/progress state: the current backend contract does not provide video-watch tracking.
- Certificate generation remains driven by `my_courses.php`; generated certificates use its `download_url`.
- WhatsApp group link: no backend field/URL has been supplied.
- Masterclass live-session ingestion: endpoint/data contract not supplied.
- Workshops: API and business rules remain a separate milestone.
- Consultation/Calendly/prescription/payment flows: separate features; contracts not supplied.

## Next
- Replace the lightweight HTML-to-text presentation with the approved shared rich HTML renderer if/when a dependency is approved.
- Add repository/model/BLoC/widget tests with representative API fixtures.


## Notes and certificate downloads
- Chapter notes use each chapter's `notes[].file_url` from `course_detail.php`.
- Course certificate availability now uses `data.certificate` from `course_detail.php` as the primary source on the course screen.
- `my_courses.php` certificate metadata remains supported for list-level certificate status/navigation.
- `generated == true` plus a non-empty `download_url` is required before a certificate download action is shown.
- Files are cached in app documents storage and reopened locally when already downloaded.

## In-app course video playback
- `CourseVideo` maps `video_url`, `vimeo_video_url`, and `main_video_url`.
- `main_video_url` is the playback source of truth.
- Vimeo `main_video_url` values use the shared Vimeo adapter.
- Non-Vimeo `main_video_url` values use the existing MP4/network adapter.
- Resume progress remains provider-neutral and persists across app restarts.

- Vimeo native controls/fullscreen are enabled; the extra auto-save helper text is removed while resume behavior is unchanged.

- Removed duplicate Vimeo/Flutter controls by making control mode an adapter capability.

- Added app-managed fullscreen with landscape/immersive system UI and back-to-exit-fullscreen behavior while preserving the same player/resume state.

- Positioned the app-managed fullscreen button outside the Vimeo iframe so it cannot overlap Vimeo native controls.

- Integrated certificate generation into course detail using the documented authenticated POST endpoint. On success, the existing course certificate metadata is replaced in memory so the established download/open flow becomes available immediately.
- Added a localized “View chapters” action near the course intro that smoothly scrolls to the chapter list.
- Chapter selection and Previous/Next chapter navigation now return the course detail scroll position to the top.
