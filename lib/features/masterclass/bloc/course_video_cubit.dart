import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_error_handler.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/video/video_playback_snapshot.dart';
import '../../../core/video/video_player_adapter.dart';
import '../../../core/video/video_player_factory.dart';
import '../../../core/video/video_progress_store.dart';
import '../../../core/video/video_source.dart';
import '../data/masterclass_models.dart';

sealed class CourseVideoState {
  const CourseVideoState();
}

final class CourseVideoLoading extends CourseVideoState {
  const CourseVideoLoading();
}

final class CourseVideoReady extends CourseVideoState {
  const CourseVideoReady({
    required this.snapshot,
    required this.resumedFrom,
    required this.fullscreen,
  });

  final VideoPlaybackSnapshot snapshot;
  final Duration resumedFrom;
  final bool fullscreen;
}

final class CourseVideoFailure extends CourseVideoState {
  const CourseVideoFailure(this.error);
  final AppException error;
}

final class CourseVideoCubit extends Cubit<CourseVideoState> {
  CourseVideoCubit({
    required CourseVideo video,
    required VideoPlayerFactory playerFactory,
    required VideoProgressStore progressStore,
  })  : _video = video,
        _progressStore = progressStore,
        _adapter = playerFactory.create(
          AppVideoSource.fromUrl(
            id: 'course_video_${video.id}',
            url: video.mainVideoUrl,
          ),
        ),
        super(const CourseVideoLoading());

  static const Duration _saveInterval = Duration(seconds: 5);
  static const double _completionThreshold = 0.95;

  final CourseVideo _video;
  final VideoProgressStore _progressStore;
  final VideoPlayerAdapter _adapter;

  StreamSubscription<VideoPlaybackSnapshot>? _subscription;
  Duration _lastSaved = Duration.zero;
  Duration _resumedFrom = Duration.zero;
  Duration _storedPosition = Duration.zero;

  bool _resumeResolved = false;
  bool _disposed = false;
  bool _fullscreen = false;

  VideoPlayerAdapter get adapter => _adapter;

  Future<void> initialize() async {
    try {
      await _subscription?.cancel();
      _resumeResolved = false;
      _resumedFrom = Duration.zero;
      _storedPosition = await _progressStore.read(_progressKey);

      _subscription = _adapter.snapshots.listen(_onSnapshot);
      await _adapter.initialize();
      _onSnapshot(_adapter.current);
    } catch (error, stackTrace) {
      if (!isClosed) {
        emit(
          CourseVideoFailure(
            ApiErrorHandler.normalize(
              error,
              stackTrace: stackTrace,
              fallback: AppErrorType.videoPlayback,
            ),
          ),
        );
      }
    }
  }

  Future<void> togglePlayPause() async {
    final snapshot = _adapter.current;
    if (!snapshot.initialized) return;

    if (snapshot.playing) {
      await _adapter.pause();
      await _persist(snapshot.position, force: true);
    } else {
      await _adapter.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _adapter.seekTo(position);
    await _persist(position, force: true);
  }

  Future<void> replay() async {
    await _progressStore.clear(_progressKey);
    _storedPosition = Duration.zero;
    _resumedFrom = Duration.zero;
    _lastSaved = Duration.zero;
    _resumeResolved = true;
    await _adapter.seekTo(Duration.zero);
    await _adapter.play();
  }

  void enterFullscreen() {
    if (_fullscreen) return;
    _fullscreen = true;
    _emitCurrentReady();
  }

  void exitFullscreen() {
    if (!_fullscreen) return;
    _fullscreen = false;
    _emitCurrentReady();
  }

  void _emitCurrentReady() {
    if (isClosed) return;
    emit(
      CourseVideoReady(
        snapshot: _adapter.current,
        resumedFrom: _resumedFrom,
        fullscreen: _fullscreen,
      ),
    );
  }

  Future<void> persistNow() async {
    await _persist(_adapter.current.position, force: true);
  }

  void _onSnapshot(VideoPlaybackSnapshot snapshot) {
    if (_disposed || isClosed) return;

    if (snapshot.errorMessage != null &&
        snapshot.errorMessage!.trim().isNotEmpty) {
      emit(
        CourseVideoFailure(
          AppException(
            AppErrorType.videoPlayback,
            cause: snapshot.errorMessage,
          ),
        ),
      );
      return;
    }

    _resolveResumeIfPossible(snapshot);

    final duration = snapshot.duration;
    final complete = duration > Duration.zero &&
        snapshot.position.inMilliseconds >=
            (duration.inMilliseconds * _completionThreshold);

    if (complete) {
      unawaited(_progressStore.clear(_progressKey));
      _lastSaved = Duration.zero;
    } else {
      unawaited(_persist(snapshot.position));
    }

    emit(
      CourseVideoReady(
        snapshot: snapshot,
        resumedFrom: _resumedFrom,
        fullscreen: _fullscreen,
      ),
    );
  }

  void _resolveResumeIfPossible(VideoPlaybackSnapshot snapshot) {
    if (_resumeResolved ||
        !snapshot.initialized ||
        snapshot.duration <= Duration.zero) {
      return;
    }

    _resumeResolved = true;

    if (_shouldResume(_storedPosition, snapshot.duration)) {
      _resumedFrom = _storedPosition;
      _lastSaved = _storedPosition;
      unawaited(_adapter.seekTo(_storedPosition));
      return;
    }

    if (_storedPosition > Duration.zero) {
      unawaited(_progressStore.clear(_progressKey));
    }
  }

  Future<void> _persist(
    Duration position, {
    bool force = false,
  }) async {
    if (position <= Duration.zero) return;

    final duration = _adapter.current.duration;
    if (duration > Duration.zero &&
        position.inMilliseconds >=
            (duration.inMilliseconds * _completionThreshold)) {
      await _progressStore.clear(_progressKey);
      _lastSaved = Duration.zero;
      return;
    }

    final delta = position - _lastSaved;
    if (!force &&
        delta.inMilliseconds.abs() < _saveInterval.inMilliseconds) {
      return;
    }

    _lastSaved = position;
    await _progressStore.write(_progressKey, position);
  }

  bool _shouldResume(Duration stored, Duration duration) {
    if (stored <= Duration.zero || duration <= Duration.zero) {
      return false;
    }

    final ratio = stored.inMilliseconds / duration.inMilliseconds;
    return ratio > 0 && ratio < _completionThreshold;
  }

  String get _progressKey => 'course_video_${_video.id}';

  @override
  Future<void> close() async {
    _disposed = true;
    await persistNow();
    await _subscription?.cancel();
    await _adapter.dispose();
    return super.close();
  }
}
