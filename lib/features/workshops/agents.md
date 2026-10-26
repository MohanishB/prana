# Workshops agent notes

- Keep Workshops integrated under the Masterclass segmented control; Masterclass flow unchanged.
- Use existing AppDependencies/ApiClient session student_id, bearer and temporary base URL.
- Endpoints: gut_reset/my_programs.php, program_detail.php, day_video.php (GET), mark_day_done.php (PHP form POST).
- Backend `state` controls labels and `can_play` playback access; map legacy `missed` to `over`.
- Mark-as-Done persists via backend; disable duplicate submissions and reload detail on return.
- Ignore watched_days, progress_pct, video_finished and video_finish_date_time for progress.
- Progress percentage calculated in Flutter as round(100*(over+watched)/total_days) from detail day states.
- Workshop list queries detail for each enrollment to calculate progress; cross-device parity follows backend day states.
- Day video renders sub_description and description_html (Today's practice); do not show 'Closes in'.
- Reuse core VideoPlayerFactory with `main_video_url` for Vimeo/MP4 and DownloadableFileTile for notes.
- Keep Bloc/Cubit only, no setState, maintain light/dark and tablet responsiveness.


## Workshop UI refinement (2026-10-23)
- Keep existing Masterclass and Library behavior unchanged.
- Use high-contrast, surface-based rounded cards and accessible status pills in Workshop list/detail.
- Day state is backend-authoritative; `missed` is displayed as `over`; `can_play` gates navigation.
- Format workshop unlocking times via `core/utils/workshop_date_formatter.dart` (Today/Tomorrow/date at 12-hour time). Never display raw API date strings.
- Render `description_html` directly with `HtmlRichText` after workshop-local empty-wrapper/whitespace normalization; do not add a duplicate "Today's practice" heading or alter the shared HTML parser.
- Workshop video fullscreen copies Masterclass's fullscreen scaffold, immersive landscape orientation and restoration in dispose; player adapter selection still comes from `main_video_url` and the shared factory.
- Mark as Done persists through the API; completion state remains backend-authoritative, while circular progress is calculated from `over` and `watched` day counts.
- No `setState`; only a StatefulWidget for platform UI cleanup, as in Masterclass.
