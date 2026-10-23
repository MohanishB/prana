# Library plan

Implemented:
- PRANA backend Library API is now the default catalogue/search source.
- Empty query loads the latest backend catalogue; non-empty query uses the same endpoint with `q`.
- Backend responses consume all video-shaped top-level content buckets (videos, shorts, podcasts and future buckets) into one Library feed.
- Existing direct YouTube Data API implementation remains available through `LIBRARY_DATA_SOURCE=youtube`.
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
- Automatic feed pagination remains available for the direct YouTube data source.
- Backend catalogue and search now use the API `page` parameter and `pagination.hasNextPage` metadata for incremental loading.
- Light/dark-compatible Library results list.

Production follow-up:
- Keep YouTube Data API credentials, synchronization, caching and search logic on the PRANA backend.
- Cache channel metadata/search responses and enforce rate limits.
- Add transcript/caption indexing server-side if transcript-level search is required.
- Add analytics for searches, video opens and watch progress if approved.


Validation follow-up:
- Verify inline playback, vertical paging, adaptive short-form presentation and fullscreen on representative Android and iOS devices.
- Keep `youtube_player_flutter` on the 9.1.x line until the project is upgraded to Flutter >=3.38 / Dart >=3.10; the 10.x/iframe 6.x line requires that newer toolchain.

- Backend `isShort: true` is treated as authoritative, but `isShort: false` does not suppress the existing mobile presentation heuristic. This preserves the established portrait/Reels layout for short-duration portrait uploads (for example <= 180 seconds) even when the backend classifies them as normal videos.

- Backend thumbnail parsing supports the new nested thumbnail variants and prefers the highest available quality.
- Search-in-progress UI uses a themed, visually prominent status surface instead of relying on a thin linear progress bar.
- Player metadata descriptions can be expanded/collapsed through `LibraryFeedCubit`, with a scrollable expanded reading area.
- The seek control is rendered above metadata so it remains visible even when descriptions expand.
- Regular videos use the 9.x `YoutubePlayerBuilder` orientation/fullscreen path so tilting the device can enter landscape playback.
- Package-level title chrome remains hidden, while the interaction overlay stays enabled for tap-to-reveal play/pause; PRANA keeps its own always-visible seek/fullscreen row. Official embed branding is not removed with unsupported hacks.


- Search feedback now transitions from concise `Searching…` UI to a visible completed state after results arrive.
- Replaced-dataset searches and clearing search reset the result list to the top; pagination continues to preserve the user's current position.
- Re-enabled the package interaction overlay so tapping the video can reveal play/pause controls after they auto-hide.
- Removed the feed's custom `onExitFullScreen` orientation override to avoid the fullscreen-button immediately returning to portrait on affected devices; regular-video fullscreen remains handled by `YoutubePlayerBuilder`.
- The PRANA seek slider now listens directly to live `YoutubePlayerValue.position` / metadata duration and seeks through the controller, keeping the thumb synchronized on long videos.
- Regular videos use reversible orientation-aware landscape presentation on natural device rotation; do not force YouTube fullscreen on sensor rotation because its fullscreen mode may lock orientation. The explicit fullscreen button remains available.
