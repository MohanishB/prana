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
