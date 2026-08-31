class VideoPlaybackSnapshot {
  const VideoPlaybackSnapshot({
    required this.initialized,
    required this.playing,
    required this.buffering,
    required this.position,
    required this.duration,
    required this.aspectRatio,
    this.errorMessage,
  });

  const VideoPlaybackSnapshot.initial()
      : initialized = false,
        playing = false,
        buffering = false,
        position = Duration.zero,
        duration = Duration.zero,
        aspectRatio = 16 / 9,
        errorMessage = null;

  final bool initialized;
  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration duration;
  final double aspectRatio;
  final String? errorMessage;

  double get progress {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }
}
