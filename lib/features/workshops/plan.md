# Workshops implementation plan

- [x] Add typed workshop list, detail, day and note models.
- [x] Create repository for student-scoped backend GET APIs and form-encoded Mark as Done.
- [x] Replace placeholder Workshop cards with API-driven cards and progress.
- [x] Implement timeline/detail with locked/open/watched/over (legacy missed → over).
- [x] Implement workshop Notes/PDF tab using existing download component.
- [x] Implement Day Video with reusable Vimeo/MP4 player adapter and HTML practice notes.
- [x] Submit Mark as Done and refresh day state/progress after navigation.
- [x] Preserve current Masterclass, Library, Account and payment code.
- [ ] Run flutter gen-l10n, flutter analyze and physical-device tests in developer's Flutter environment.
- [ ] Verify backend mark_day_done.php accepts PHP form POST and returns updated watched state in program_detail.
- [ ] Check Notes download URL authorization and signed URLs if the backend requires it.


## Workshop UI refinement (2026-10-23)
- Keep existing Masterclass and Library behavior unchanged.
- Use high-contrast, surface-based rounded cards and accessible status pills in Workshop list/detail.
- Day state is backend-authoritative; `missed` is displayed as `over`; `can_play` gates navigation.
- Format workshop unlocking times via `core/utils/workshop_date_formatter.dart` (Today/Tomorrow/date at 12-hour time). Never display raw API date strings.
- Render `description_html` directly with `HtmlRichText` after workshop-local empty-wrapper/whitespace normalization; do not add a duplicate "Today's practice" heading or alter the shared HTML parser.
- Workshop video fullscreen copies Masterclass's fullscreen scaffold, immersive landscape orientation and restoration in dispose; player adapter selection still comes from `main_video_url` and the shared factory.
- Mark as Done persists through the API; completion state remains backend-authoritative, while circular progress is calculated from `over` and `watched` day counts.
- No `setState`; only a StatefulWidget for platform UI cleanup, as in Masterclass.

## Done in Steps 4–7
- Programme list/detail with start-day, open/close times, payment-driven creation from the Gut Reset booking.

## Next
- Reminders for day opened / ending soon / missed (needs the scheduled job and server-side watched tracking).

- Step 12: Gut Reset day videos resume where the student stopped (phone storage, 95% rule). Server-side tracking later.
- Step 13: reports watch time to the server.
