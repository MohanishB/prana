# Library feature guidance

- Keep Library state in BLoC/Cubit. Do not use setState.
- Search must remain scoped to the official PRANA YouTube channel.
- Debounce keyword searches because YouTube search requests are quota-expensive.
- Preserve pagination and vertical swipe playback.
- Only one YouTube player should be active at a time.
- Keep the YouTube API key out of source control. The direct client repository is an integration bridge; production should prefer a PRANA backend proxy/cache.
- Do not scrape YouTube HTML.

- Mobile YouTube playback currently uses `youtube_player_flutter` 9.1.x. Do not move to `youtube_player_iframe` 6.x / `youtube_player_flutter` 10.x until the app toolchain is Flutter >=3.38 and Dart >=3.10.
- Do not set a fabricated iframe `origin`; use the player package defaults and preserve the external YouTube fallback for playback errors.

- Keep the feed visually swipe-first: use the adaptive portrait stage for short-form videos and 16:9 for regular videos.
- Keep metadata compact and non-interactive over the lower gradient so vertical PageView gestures remain available outside the embedded player controls.
- Short-form classification is a presentation heuristic (Shorts tags or <=3-minute duration), not a claim that YouTube officially classifies the item as a Short.

- On phones, short-form playback should use the full available width whenever the 9:16 stage fits the viewport; avoid decorative side margins.
- On tablets/iPads, keep portrait playback centered with a proportional width cap rather than stretching it edge-to-edge.
- Keep landscape playback centered at 16:9 with black letterboxing instead of cropping YouTube content.

- Keep YouTube controls hidden on initial playback (`controlsVisibleAtStart: false`); controls remain available when the user taps the player.
- Feed videos should loop automatically (`loop: true`) so completion returns directly to playback instead of leaving the YouTube replay/loading overlay visible.
