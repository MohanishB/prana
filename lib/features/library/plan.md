# Library plan

Implemented:
- Official PRANA YouTube channel resolution by handle.
- Latest uploads catalogue.
- Debounced keyword search scoped to the channel.
- Real thumbnails, titles, descriptions, durations and pagination.
- Vertical swipe video feed with one active embedded YouTube player.
- Mobile playback uses `youtube_player_flutter` 9.1.x for Android/iOS compatibility and improved YouTube error handling.
- Non-active feed pages dispose their player; playback errors fall back to opening the video in YouTube.
- Playback UI uses a Reels-style full-height portrait 9:16 stage on phones for short-form videos, while regular videos remain centered at 16:9.
- Portrait playback width is capped proportionally on tablets/iPads so content is not unnaturally stretched.
- Video metadata uses a compact bottom gradient overlay to reduce duplicated UI and preserve the swipe-first feed.
- Player controls start hidden so playback opens without a persistent dark controls overlay.
- Feed videos loop automatically when playback reaches the end instead of stopping on the replay/loading state.
- Automatic feed pagination.
- Light/dark-compatible Library results list.

Production follow-up:
- Move YouTube Data API access behind the PRANA backend.
- Cache channel metadata/search responses and enforce rate limits.
- Add transcript/caption indexing server-side if transcript-level search is required.
- Add analytics for searches, video opens and watch progress if approved.


Validation follow-up:
- Verify inline playback, vertical paging, adaptive short-form presentation and fullscreen on representative Android and iOS devices.
- Keep `youtube_player_flutter` on the 9.1.x line until the project is upgraded to Flutter >=3.38 / Dart >=3.10; the 10.x/iframe 6.x line requires that newer toolchain.
