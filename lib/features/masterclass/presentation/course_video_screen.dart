import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/video/video_player_adapter.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/course_video_cubit.dart';
import '../data/masterclass_models.dart';

class CourseVideoScreen extends StatelessWidget {
  const CourseVideoScreen({
    required this.video,
    super.key,
  });

  final CourseVideo video;

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();

    return BlocProvider(
      create: (_) => CourseVideoCubit(
        video: video,
        playerFactory: dependencies.videoPlayerFactory,
        progressStore: dependencies.videoProgressStore,
      )..initialize(),
      child: _CourseVideoSystemUiGuard(
        child: _CourseVideoView(video: video),
      ),
    );
  }
}

/// Owns only platform lifecycle cleanup. Playback/UI state stays in the Cubit.
class _CourseVideoSystemUiGuard extends StatefulWidget {
  const _CourseVideoSystemUiGuard({required this.child});

  final Widget child;

  @override
  State<_CourseVideoSystemUiGuard> createState() =>
      _CourseVideoSystemUiGuardState();
}

class _CourseVideoSystemUiGuardState extends State<_CourseVideoSystemUiGuard> {
  @override
  void dispose() {
    _restoreSystemUi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _CourseVideoView extends StatelessWidget {
  const _CourseVideoView({required this.video});

  final CourseVideo video;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseVideoCubit, CourseVideoState>(
      listenWhen: (previous, current) =>
          _fullscreenOf(previous) != _fullscreenOf(current),
      listener: (context, state) {
        if (_fullscreenOf(state)) {
          _enterFullscreenSystemUi();
        } else {
          _restoreSystemUi();
        }
      },
      builder: (context, state) {
        final fullscreen = _fullscreenOf(state);

        return PopScope(
          canPop: !fullscreen,
          onPopInvokedWithResult: (didPop, _) {
            if (fullscreen) {
              context.read<CourseVideoCubit>().exitFullscreen();
              return;
            }
            if (didPop) {
              context.read<CourseVideoCubit>().persistNow();
            }
          },
          child: Scaffold(
            backgroundColor: fullscreen ? AppColors.black : null,
            appBar: fullscreen
                ? null
                : PranaAppBar(
                    title: video.title,
                    showBack: true,
                  ),
            body: _bodyForState(
              context,
              state,
              video,
              fullscreen,
            ),
          ),
        );
      },
    );
  }
}

Widget _bodyForState(
  BuildContext context,
  CourseVideoState state,
  CourseVideo video,
  bool fullscreen,
) {
  return switch (state) {
    CourseVideoLoading() => Stack(
        fit: StackFit.expand,
        children: [
          context.read<CourseVideoCubit>().adapter.buildView(),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    CourseVideoFailure(:final error) => ResponsiveContent(
        child: AppErrorView(
          message: error.userMessage(context),
          retryLabel: context.l10n.retry,
          onRetry: context.read<CourseVideoCubit>().initialize,
        ),
      ),
    CourseVideoReady(:final resumedFrom) => fullscreen
        ? _FullscreenPlayer(state: state)
        : SingleChildScrollView(
            child: ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlayerSurface(state: state),
                  if (resumedFrom > Duration.zero) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.videoResumedAt(
                        _formatDuration(resumedFrom),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
  };
}

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({required this.state});

  final CourseVideoReady state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CourseVideoCubit>();
    final snapshot = state.snapshot;
    final usesNativeControls =
        cubit.adapter.controlsMode == VideoControlsMode.native;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: ColoredBox(
        color: AppColors.black,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: snapshot.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  cubit.adapter.buildView(),
                  if (!usesNativeControls && snapshot.buffering)
                    const Center(child: CircularProgressIndicator()),
                  if (!usesNativeControls)
                    Center(
                      child: IconButton.filledTonal(
                        onPressed: cubit.togglePlayPause,
                        iconSize: 36,
                        icon: Icon(
                          snapshot.playing ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                  if (!usesNativeControls)
                    _FullscreenButton(
                      onPressed: cubit.enterFullscreen,
                    ),
                ],
              ),
            ),
            if (usesNativeControls)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                  ),
                  child: IconButton.filledTonal(
                    onPressed: cubit.enterFullscreen,
                    icon: const Icon(Icons.fullscreen),
                  ),
                ),
              ),
            if (!usesNativeControls) _PlaybackControls(state: state),
          ],
        ),
      ),
    );
  }
}

class _FullscreenPlayer extends StatelessWidget {
  const _FullscreenPlayer({required this.state});

  final CourseVideoReady state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CourseVideoCubit>();
    final snapshot = state.snapshot;
    final usesNativeControls =
        cubit.adapter.controlsMode == VideoControlsMode.native;

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: snapshot.aspectRatio,
              child: cubit.adapter.buildView(),
            ),
          ),
          if (!usesNativeControls)
            Align(
              alignment: Alignment.bottomCenter,
              child: _PlaybackControls(state: state),
            ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: IconButton.filledTonal(
              onPressed: cubit.exitFullscreen,
              icon: const Icon(Icons.fullscreen_exit),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSpacing.xs,
      right: AppSpacing.xs,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: const Icon(Icons.fullscreen),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.state});

  final CourseVideoReady state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CourseVideoCubit>();
    final snapshot = state.snapshot;
    final maxMilliseconds = snapshot.duration.inMilliseconds.toDouble();
    final positionMilliseconds = snapshot.position.inMilliseconds
        .clamp(0, snapshot.duration.inMilliseconds)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Column(
        children: [
          Slider(
            value: maxMilliseconds <= 0 ? 0 : positionMilliseconds,
            max: maxMilliseconds <= 0 ? 1 : maxMilliseconds,
            onChanged: maxMilliseconds <= 0
                ? null
                : (value) => cubit.seekTo(
                      Duration(milliseconds: value.round()),
                    ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: cubit.togglePlayPause,
                color: AppColors.white,
                icon: Icon(
                  snapshot.playing ? Icons.pause : Icons.play_arrow,
                ),
              ),
              Text(
                '${_formatDuration(snapshot.position)} / '
                '${_formatDuration(snapshot.duration)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: cubit.enterFullscreen,
                color: AppColors.white,
                icon: const Icon(Icons.fullscreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

bool _fullscreenOf(CourseVideoState state) =>
    state is CourseVideoReady && state.fullscreen;

Future<void> _enterFullscreenSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
    const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  );
}

Future<void> _restoreSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
