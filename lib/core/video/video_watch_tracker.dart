import 'dart:async';
import 'dart:math' as math;

import 'video_playback_snapshot.dart';
import 'video_watch_repository.dart';

/// Counts the time a student really plays a video and reports it to the server
/// (about every 30 s while playing, when paused, and when the video is closed).
/// Jumping ahead or back adds no watched time. Never throws: a failed report is
/// kept and sent with the next one.
final class VideoWatchTracker {
  VideoWatchTracker({
    required VideoWatchRepository repository,
    required this.videoType,
    required this.videoRefId,
    DateTime Function()? clock,
  })  : _repository = repository,
        _clock = clock ?? DateTime.now;

  /// Report when this many played seconds are waiting.
  static const double reportAfterSeconds = 30;

  /// A position change bigger than this between two updates is a seek, not playing.
  static const double maxPlayStepSeconds = 3;

  /// The server accepts at most this many played seconds per report.
  static const int maxPlayedPerReport = 150;

  /// After a failed report, do not retry on its own for this long.
  static const Duration retryAfter = Duration(seconds: 30);

  final String videoType;
  final int videoRefId;
  final VideoWatchRepository _repository;
  final DateTime Function() _clock;

  double _pendingSeconds = 0;
  double? _lastPositionSeconds;
  double _positionSeconds = 0;
  double _durationSeconds = 0;
  double? _lastReportedPosition;
  bool _wasPlaying = false;
  DateTime? _blockedUntil;
  Future<void>? _sending;

  /// Seconds played and not yet reported (for tests).
  double get pendingSeconds => _pendingSeconds;

  /// Feed every player update here.
  void onSnapshot(VideoPlaybackSnapshot snapshot) {
    if (!snapshot.initialized) return;
    final seconds = snapshot.position.inMilliseconds / 1000;
    final previous = _lastPositionSeconds;
    if (previous != null && snapshot.playing && !snapshot.buffering) {
      final step = seconds - previous;
      if (step > 0 && step <= maxPlayStepSeconds) {
        _pendingSeconds += step;
      }
    }
    _lastPositionSeconds = seconds;
    _positionSeconds = seconds;
    if (snapshot.duration > Duration.zero) {
      _durationSeconds = snapshot.duration.inMilliseconds / 1000;
    }

    final paused = _wasPlaying && !snapshot.playing;
    _wasPlaying = snapshot.playing;

    if (paused) {
      unawaited(flush());
      return;
    }
    final blocked = _blockedUntil;
    final waiting = blocked != null && _clock().isBefore(blocked);
    if (_pendingSeconds >= reportAfterSeconds && !waiting) {
      unawaited(flush());
    }
  }

  /// Sends what is waiting. Safe to call at any time (pause, leaving the video).
  Future<void> flush() async {
    final running = _sending;
    if (running != null) {
      await running;
    }
    final played =
        math.max(0, math.min(maxPlayedPerReport, _pendingSeconds.round()));
    final moved = _positionSeconds != _lastReportedPosition;
    if (played <= 0 && !moved) return;
    if (played <= 0 && _positionSeconds <= 0) return;

    _pendingSeconds -= played;
    final sending = _send(played, _positionSeconds, _durationSeconds);
    _sending = sending;
    await sending;
    if (identical(_sending, sending)) {
      _sending = null;
    }
  }

  Future<void> _send(int played, double position, double duration) async {
    try {
      await _repository.report(
        videoType: videoType,
        videoRefId: videoRefId,
        positionSeconds: position,
        durationSeconds: duration,
        playedSeconds: played,
      );
      _lastReportedPosition = position;
      _blockedUntil = null;
    } on Object {
      _pendingSeconds += played;
      _blockedUntil = _clock().add(retryAfter);
    }
  }
}
