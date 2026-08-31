import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_playback_snapshot.dart';
import 'video_player_adapter.dart';
import 'video_source.dart';

final class NetworkVideoPlayerAdapter implements VideoPlayerAdapter {
  NetworkVideoPlayerAdapter(this.source)
      : _controller = VideoPlayerController.networkUrl(
          Uri.parse(source.url),
        ) {
    _controller.addListener(_publish);
  }

  final AppVideoSource source;
  final VideoPlayerController _controller;
  final StreamController<VideoPlaybackSnapshot> _streamController =
      StreamController<VideoPlaybackSnapshot>.broadcast();

  VideoPlaybackSnapshot _current = const VideoPlaybackSnapshot.initial();

  @override
  Stream<VideoPlaybackSnapshot> get snapshots => _streamController.stream;

  @override
  VideoPlaybackSnapshot get current => _current;

  @override
  VideoControlsMode get controlsMode => VideoControlsMode.custom;

  @override
  Widget buildView() => VideoPlayer(_controller);

  @override
  Future<void> initialize() async {
    await _controller.initialize();
    _publish();
  }

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seekTo(Duration position) => _controller.seekTo(position);

  @override
  Future<void> setFullscreen(bool fullscreen) async {
    // Fullscreen presentation is owned by the app shell/presentation layer.
    // This method exists on the adapter contract so a future provider adapter
    // (for example Vimeo) can react to fullscreen transitions if required.
  }

  @override
  Future<void> dispose() async {
    _controller.removeListener(_publish);
    await _controller.dispose();
    await _streamController.close();
  }

  void _publish() {
    final value = _controller.value;

    _current = VideoPlaybackSnapshot(
      initialized: value.isInitialized,
      playing: value.isPlaying,
      buffering: value.isBuffering,
      position: value.position,
      duration: value.duration,
      aspectRatio: value.isInitialized && value.aspectRatio > 0
          ? value.aspectRatio
          : 16 / 9,
      errorMessage: value.hasError ? value.errorDescription : null,
    );

    if (!_streamController.isClosed) {
      _streamController.add(_current);
    }
  }
}
