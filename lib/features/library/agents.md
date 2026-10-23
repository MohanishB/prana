# Library feature guidance

- Keep Library state in BLoC/Cubit. Do not use setState.
- Search must remain scoped to the official PRANA YouTube channel.
- Debounce keyword searches because YouTube search requests are quota-expensive.
- Preserve pagination and vertical swipe playback.
- Only one YouTube player should be active at a time.
- Backend API is the default Library data source. Keep the direct YouTube repository available as a controlled fallback/dev mode.
- Switch data source with `--dart-define=LIBRARY_DATA_SOURCE=backend` (default) or `--dart-define=LIBRARY_DATA_SOURCE=youtube`.
- Backend parsing must include every top-level video bucket returned by the endpoint (for example videos, shorts, podcasts and future content types), deduplicated by videoId.
- Keep the YouTube API key out of source control. It is required only when `LIBRARY_DATA_SOURCE=youtube`.
- Do not scrape YouTube HTML.

- Mobile YouTube playback currently uses `youtube_player_flutter` 9.1.x. Do not move to `youtube_player_iframe` 6.x / `youtube_player_flutter` 10.x until the app toolchain is Flutter >=3.38 and Dart >=3.10.
- Do not set a fabricated iframe `origin`; use the player package defaults and preserve the external YouTube fallback for playback errors.

- Keep the feed visually swipe-first: use the adaptive portrait stage for short-form videos and 16:9 for regular videos.
- Keep metadata compact by default. Only the description itself is interactive; tapping it expands/collapses via LibraryFeedCubit while vertical PageView gestures remain available elsewhere.
- Short-form classification is a presentation heuristic (Shorts tags or <=3-minute duration), not a claim that YouTube officially classifies the item as a Short.

- On phones, short-form playback should use the full available width whenever the 9:16 stage fits the viewport; avoid decorative side margins.
- On tablets/iPads, keep portrait playback centered with a proportional width cap rather than stretching it edge-to-edge.
- Keep landscape playback centered at 16:9 with black letterboxing instead of cropping YouTube content.

- Keep YouTube top actions/title chrome hidden, but keep the package interaction overlay enabled so tap-to-reveal play/pause remains functional; PRANA still owns the always-visible seek/fullscreen row outside the embedded surface.
- Feed videos should loop automatically (`loop: true`) so completion returns directly to playback instead of leaving the YouTube replay/loading overlay visible.

- Do not use backend `isShort: false` as a hard layout override. Keep the existing client presentation heuristic available so portrait/short-duration videos continue to render in the full-height 9:16 Reels-style layout across both backend and direct-YouTube data sources.

- Backend pagination is page-number based. Treat `LibraryPage.nextPageToken` as an opaque token at the BLoC/Cubit boundary; the backend repository maps it to `page=<n>` and reads `pagination.hasNextPage` / `pagination.page`.
- Prefer the backend `thumbnails` object (maxres -> standard -> high -> medium -> default) with the legacy `thumbnail` field as fallback.
- Search loading should use a visible themed status surface rather than only a thin progress line; keep the existing result list visible during debounced refreshes when possible.
- Description expansion belongs to `LibraryFeedCubit`; do not introduce `setState` for feed metadata.
- Keep the seek bar in Flutter UI above the metadata block so expanded/collapsed descriptions never cover it.
- Regular videos may use `YoutubePlayerBuilder` orientation/fullscreen handling so device rotation can enter landscape; Shorts keep the portrait/Reels presentation.
- Hide package-level YouTube title/action chrome where supported, but do not use DOM/JavaScript hacks to remove branding required by the official YouTube embed.


- Search status copy is intentionally concise: show `Searching…` while the debounced request is active, then a themed `Search complete` state with the currently loaded result count.
- When a search (including clearing the query back to the latest catalogue) finishes, reset the Library result list to the top because the dataset has been replaced; preserve scroll position only for pagination/appends.
- Keep YouTube package controls enabled so tap-to-reveal and center play/pause remain interactive, while top actions stay empty to minimize provider chrome.
- Do not override `YoutubePlayerBuilder.onExitFullScreen` orientation in the feed; package fullscreen orientation callbacks can fire during rebuilds and cause an immediate return to portrait on some devices.
- Keep a PRANA-owned seek slider bound directly to `YoutubePlayerController` values so its thumb follows playback time continuously and seeking remains independent of the description overlay.
- Regular videos use reversible orientation-aware landscape presentation on natural device rotation; do not force YouTube fullscreen on sensor rotation because its fullscreen mode may lock orientation. The explicit fullscreen button remains available.
