import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'video_playback_snapshot.dart';
import 'video_player_adapter.dart';
import 'video_source.dart';

final class VimeoVideoPlayerAdapter implements VideoPlayerAdapter {
  VimeoVideoPlayerAdapter(this.source)
      : _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted);

  final AppVideoSource source;
  final WebViewController _controller;
  final StreamController<VideoPlaybackSnapshot> _streamController =
      StreamController<VideoPlaybackSnapshot>.broadcast();

  VideoPlaybackSnapshot _current = const VideoPlaybackSnapshot.initial();
  bool _initializedController = false;

  @override
  Stream<VideoPlaybackSnapshot> get snapshots => _streamController.stream;

  @override
  VideoPlaybackSnapshot get current => _current;

  @override
  VideoControlsMode get controlsMode => VideoControlsMode.native;

  @override
  Widget buildView() => WebViewWidget(controller: _controller);

  @override
  Future<void> initialize() async {
    if (_initializedController) {
      await _controller.reload();
      return;
    }

    _initializedController = true;

    await _controller.addJavaScriptChannel(
      'PranaBridge',
      onMessageReceived: (message) {
        _handleMessage(message.message);
      },
    );

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {
          if (error.isForMainFrame != true) return;
          _publish(
            VideoPlaybackSnapshot(
              initialized: _current.initialized,
              playing: false,
              buffering: false,
              position: _current.position,
              duration: _current.duration,
              aspectRatio: _current.aspectRatio,
              errorMessage: error.description,
            ),
          );
        },
      ),
    );

    await _controller.loadHtmlString(_buildHtml());
  }

  @override
  Future<void> play() => _run('window.pranaPlay && window.pranaPlay();');

  @override
  Future<void> pause() => _run('window.pranaPause && window.pranaPause();');

  @override
  Future<void> seekTo(Duration position) => _run(
        'window.pranaSeek && window.pranaSeek('
        '${position.inMilliseconds / 1000.0}'
        ');',
      );

  @override
  Future<void> setFullscreen(bool fullscreen) async {}

  @override
  Future<void> dispose() async {
    try {
      await _run('window.pranaDispose && window.pranaDispose();');
    } on Object {
      // Best-effort cleanup.
    }
    await _streamController.close();
  }

  Future<void> _run(String script) async {
    await _controller.runJavaScript(script);
  }

  void _handleMessage(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map) return;
      final message = decoded.cast<String, dynamic>();
      final event = message['event']?.toString() ?? '';

      final seconds = _asDouble(message['seconds']);
      final durationSeconds = _asDouble(message['duration']);
      final position =
          Duration(milliseconds: (seconds * 1000).round());
      final duration =
          Duration(milliseconds: (durationSeconds * 1000).round());

      switch (event) {
        case 'loaded':
        case 'ready':
          _publish(
            VideoPlaybackSnapshot(
              initialized: true,
              playing: false,
              buffering: false,
              position: position,
              duration: duration,
              aspectRatio: 16 / 9,
            ),
          );
          break;
        case 'play':
          _publish(_copyCurrent(
            initialized: true,
            playing: true,
            buffering: false,
            position: position,
            duration: duration,
          ));
          break;
        case 'pause':
          _publish(_copyCurrent(
            initialized: true,
            playing: false,
            buffering: false,
            position: position,
            duration: duration,
          ));
          break;
        case 'timeupdate':
          _publish(_copyCurrent(
            initialized: true,
            position: position,
            duration: duration,
          ));
          break;
        case 'bufferstart':
          _publish(_copyCurrent(buffering: true));
          break;
        case 'bufferend':
          _publish(_copyCurrent(buffering: false));
          break;
        case 'ended':
          _publish(_copyCurrent(
            initialized: true,
            playing: false,
            buffering: false,
            position: duration,
            duration: duration,
          ));
          break;
        case 'error':
          _publish(_copyCurrent(
            playing: false,
            buffering: false,
            errorMessage:
                message['message']?.toString() ?? 'Vimeo playback error',
          ));
          break;
      }
    } on Object {
      // Ignore malformed bridge messages.
    }
  }

  VideoPlaybackSnapshot _copyCurrent({
    bool? initialized,
    bool? playing,
    bool? buffering,
    Duration? position,
    Duration? duration,
    double? aspectRatio,
    String? errorMessage,
  }) {
    return VideoPlaybackSnapshot(
      initialized: initialized ?? _current.initialized,
      playing: playing ?? _current.playing,
      buffering: buffering ?? _current.buffering,
      position: position ?? _current.position,
      duration: duration ?? _current.duration,
      aspectRatio: aspectRatio ?? _current.aspectRatio,
      errorMessage: errorMessage,
    );
  }

  void _publish(VideoPlaybackSnapshot snapshot) {
    _current = snapshot;
    if (!_streamController.isClosed) {
      _streamController.add(snapshot);
    }
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _buildHtml() {
    final encodedUrl = jsonEncode(source.url);

    return '''
<!doctype html>
<html>
<head>
  <meta name="viewport"
        content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    html, body, #player {
      margin: 0;
      width: 100%;
      height: 100%;
      background: #000;
      overflow: hidden;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <div id="player"></div>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <script>
    (function () {
      const sourceUrl = $encodedUrl;
      const root = document.getElementById('player');
      let player = null;

      function post(payload) {
        try {
          PranaBridge.postMessage(JSON.stringify(payload));
        } catch (_) {}
      }

      function snapshot(eventName) {
        if (!player) return;
        Promise.all([
          player.getCurrentTime().catch(() => 0),
          player.getDuration().catch(() => 0),
          player.getPaused().catch(() => true)
        ]).then(function (values) {
          post({
            event: eventName,
            seconds: values[0] || 0,
            duration: values[1] || 0,
            paused: values[2] === true
          });
        }).catch(function (error) {
          post({event: 'error', message: String(error)});
        });
      }

      function buildPlayer() {
        if (!window.Vimeo || !window.Vimeo.Player) {
          post({
            event: 'error',
            message: 'Vimeo player library could not be loaded.'
          });
          return;
        }

        const iframe = document.createElement('iframe');
        const separator = sourceUrl.indexOf('?') >= 0 ? '&' : '?';
        iframe.src = sourceUrl + separator +
          'playsinline=1&transparent=0&controls=1&fullscreen=0';
        iframe.setAttribute(
          'allow',
          'autoplay; fullscreen; picture-in-picture'
        );
        iframe.setAttribute('allowfullscreen', '');
        root.appendChild(iframe);

        player = new Vimeo.Player(iframe);

        player.ready().then(function () {
          snapshot('loaded');
        }).catch(function (error) {
          post({event: 'error', message: String(error)});
        });

        player.on('play', function () { snapshot('play'); });
        player.on('pause', function () { snapshot('pause'); });

        player.on('timeupdate', function (data) {
          post({
            event: 'timeupdate',
            seconds: data.seconds || 0,
            duration: data.duration || 0
          });
        });

        player.on('bufferstart', function () { snapshot('bufferstart'); });
        player.on('bufferend', function () { snapshot('bufferend'); });

        player.on('ended', function (data) {
          post({
            event: 'ended',
            seconds: data.seconds || data.duration || 0,
            duration: data.duration || 0
          });
        });

        player.on('error', function (error) {
          post({
            event: 'error',
            message: error && error.message
              ? error.message
              : String(error)
          });
        });

        window.pranaPlay = function () {
          if (!player) return;
          player.play().catch(function (error) {
            post({event: 'error', message: String(error)});
          });
        };

        window.pranaPause = function () {
          if (!player) return;
          player.pause().catch(function (error) {
            post({event: 'error', message: String(error)});
          });
        };

        window.pranaSeek = function (seconds) {
          if (!player) return;
          player.setCurrentTime(Number(seconds) || 0).then(function () {
            snapshot('timeupdate');
          }).catch(function (error) {
            post({event: 'error', message: String(error)});
          });
        };

        window.pranaSnapshot = function () {
          snapshot('timeupdate');
        };

        window.pranaDispose = function () {
          if (!player) return;
          player.unload().catch(function () {});
          player = null;
        };
      }

      buildPlayer();
    })();
  </script>
</body>
</html>
''';
  }
}
