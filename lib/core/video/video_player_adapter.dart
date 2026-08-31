import 'package:flutter/widgets.dart';

import 'video_playback_snapshot.dart';

enum VideoControlsMode {
  custom,
  native,
}

abstract interface class VideoPlayerAdapter {
  Stream<VideoPlaybackSnapshot> get snapshots;

  VideoPlaybackSnapshot get current;

  VideoControlsMode get controlsMode;

  Widget buildView();

  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(Duration position);

  Future<void> setFullscreen(bool fullscreen);

  Future<void> dispose();
}
