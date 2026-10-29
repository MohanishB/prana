# Video Playback Agent Guide

- `course_detail.php -> videos[].main_video_url` is the source of truth for course playback.
- Parse and preserve `video_url`, `vimeo_video_url`, and `main_video_url`.
- Do not play `video_url` instead of `main_video_url`; the backend keeps it as a migration/reference field.
- Provider selection belongs in `AppVideoSource`, not feature screens.
- A `main_video_url` containing `vimeo` uses `VimeoVideoPlayerAdapter`.
- Any other non-empty `main_video_url` uses `NetworkVideoPlayerAdapter`.
- Presentation code depends on `VideoPlayerFactory` / `VideoPlayerAdapter`, never directly on provider-specific SDKs.
- Vimeo playback follows the demo's WebView + Vimeo Player JavaScript bridge approach.
- Playback progress is provider-independent and keyed by backend `video_id`.
- Save periodically and on pause/exit; do not write on every frame.
- Clear resume progress at the completion threshold.
- No `setState` for playback state; use BLoC/Cubit.

- Vimeo native controls are enabled, including Vimeo-provided fullscreen where supported.

- Player control rendering is capability-driven through `VideoControlsMode`; presentation must not type-check Vimeo/MP4 adapters.
- Vimeo uses native Vimeo controls only. Network/MP4 uses the app's custom Flutter controls.

- Fullscreen is app-managed for reliability; do not re-enable Vimeo HTML fullscreen. Preserve playback/resume state across fullscreen transitions.

- Vimeo videos reach the app as a signed link to the server's player page (`/player/player.php?t=...`, built by the backend `PlayerLink`). `AppVideoSource.isPlayerPage` is true for it and `VimeoVideoPlayerAdapter` loads it with `loadRequest`; only that page's site may stay in the view (`onNavigationRequest`). The page talks through the same `PranaBridge` channel and `window.pranaPlay/pranaPause/pranaSeek/pranaSnapshot/pranaDispose` functions – keep both sides in step (`student_app_webservices/player/agents.md`).
- A plain Vimeo link (backend links switched off) still works through the old in-app page, but domain-restricted videos need the player page.
- Do not add a website address to the in-app page: Vimeo did not accept it (Step 10 test failed with PrivacyError), that is why the player page exists.

- Watch tracking (Step 13): `VideoWatchTracker` counts real played seconds from player snapshots (a jump of more than 3 s is a seek and adds nothing) and reports through `VideoWatchRepository` -> `POST /video/progress.php` about every 30 s of playing, on pause and when the video is closed. It never throws; a failed report is kept and sent with the next one (30 s back-off). Both players (`CourseVideoCubit`, `WorkshopPlaybackCubit`) take an optional tracker. Types: `VideoWatchType.chapter` (ref = chapter video id), `VideoWatchType.gutReset` (ref = booking item id).
