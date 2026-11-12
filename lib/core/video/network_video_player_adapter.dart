import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../network/api_constants.dart';
import 'video_playback_snapshot.dart';
import 'video_player_adapter.dart';
import 'video_source.dart';

/// Headers sent with every direct video (.mp4) request.
///
/// The video server only serves files to requests that come from the app's own
/// site (hotlink protection), and a native player sends no `Referer` by
/// itself. The referer is the address of the web-service server the app
/// already talks to, so it follows the test -> live switch of
/// [ApiConstants.baseUrl] with no separate setting.
Map<String, String> videoRequestHeaders({String? baseUrl}) {
  final uri = Uri.tryParse(baseUrl ?? ApiConstants.baseUrl);
  if (uri == null || uri.host.isEmpty) return const <String, String>{};
  return <String, String>{'Referer': '${uri.scheme}://${uri.host}/'};
}

final class NetworkVideoPlayerAdapter implements VideoPlayerAdapter {
  NetworkVideoPlayerAdapter(this.source)
      : _controller = VideoPlayerController.networkUrl(
          Uri.parse(source.url),
          httpHeaders: videoRequestHeaders(),
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
