# Video Playback Plan

## Implemented
- Parse `video_url`, `vimeo_video_url`, and `main_video_url`.
- Use `main_video_url` as the playback source of truth.
- Vimeo URLs route to the Vimeo WebView/JavaScript adapter with native Vimeo controls enabled.
- Non-Vimeo URLs route to the existing network/MP4 adapter.
- Resume persistence remains provider-neutral and keyed by backend `video_id`.
- Resume waits until provider duration/metadata is available.
- Position is persisted approximately every five seconds and on pause/exit.
- Saved position is cleared at 95% completion.

## Next
- Add server-side video progress only when an API contract exists.
- Add provider-neutral fullscreen/Picture-in-Picture if required.

- Remove redundant playback-position helper copy from the player screen; resume remains silent except for the existing resumed-from hint.

- Player control UI is provider-neutral: Vimeo declares native controls, while network/MP4 declares custom controls, preventing duplicate overlays.

- Added app-managed fullscreen with landscape/immersive system UI and back-to-exit-fullscreen behavior while preserving the same player/resume state.

- Step 11: Vimeo plays through the server's signed player page (`player.php`) so domain-restricted videos work; plain Vimeo links keep the old path. Not yet tested on a device by the agent.
- Next: server-side watch tracking (owner: later); website player.
- Step 13: watch tracking for the admin Video Watch Report.
- Next: use the server position for resume on a new phone (not built).
