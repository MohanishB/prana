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
- Notes open the backend-provided PDF/file URL.
- Previous/Next chapter navigation is presentation state owned by `CourseViewCubit`.
- UI follows the approved mobile wireframe while mapping to the web LMS content structure.

## Explicitly deferred
- `POST /masterclasses/submit_quiz.php`: start/answer/submit remains disabled until that API is selected.
- Per-video watched/progress state: the current backend contract does not provide video-watch tracking.
- Certificate download API.
- WhatsApp group link: no backend field/URL has been supplied.
- Masterclass live-session ingestion: endpoint/data contract not supplied.
- Workshops: API and business rules remain a separate milestone.
- Consultation/Calendly/prescription/payment flows: separate features; contracts not supplied.

## Next
- Integrate quiz submission when selected.
- Replace the lightweight HTML-to-text presentation with the approved shared rich HTML renderer if/when a dependency is approved.
- Add repository/model/BLoC/widget tests with representative API fixtures.
