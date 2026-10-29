import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/dependencies.dart';
import '../../../core/utils/workshop_date_formatter.dart';
import '../../../core/video/video_playback_snapshot.dart';
import '../../../core/video/video_player_adapter.dart';
import '../../../core/video/video_watch_repository.dart';
import '../../../core/video/video_watch_tracker.dart';
import '../../../core/widgets/html_rich_text.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/workshop_cubit.dart';
import '../bloc/workshop_playback_cubit.dart';
import '../data/workshop_models.dart';

class WorkshopDayVideoScreen extends StatelessWidget {
  const WorkshopDayVideoScreen({required this.itemId, super.key});

  final int itemId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => WorkshopVideoCubit(
          context.read<AppDependencies>().workshopRepository,
          itemId,
        )..load(),
        child: const _VideoContent(),
      );
}

class _VideoContent extends StatelessWidget {
  const _VideoContent();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<WorkshopVideoCubit, WorkshopVideoState>(
        listenWhen: (previous, next) =>
            previous.error != next.error || previous.marked != next.marked,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.marked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Day marked as done')),
            );
          }
        },
        builder: (context, state) {
          final video = state.video;
          if (video == null) {
            return Scaffold(
              appBar: const PranaAppBar(title: 'Workshop', showBack: true),
              body: Center(
                child: state.loading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.error ?? 'Unable to load this video'),
                          TextButton(
                            onPressed: context.read<WorkshopVideoCubit>().load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
              ),
            );
          }

          if (video.mainUrl.isEmpty) {
            return Scaffold(
              appBar: PranaAppBar(
                title: 'Day ${video.day}',
                showBack: true,
              ),
              body: const Center(child: Text('Video unavailable')),
            );
          }

          return BlocProvider(
            key: ValueKey(video.itemId),
            create: (context) => WorkshopPlaybackCubit(
              context.read<AppDependencies>().videoPlayerFactory,
              video.mainUrl,
              video.itemId,
              context.read<AppDependencies>().videoProgressStore,
              watchTracker: VideoWatchTracker(
                repository: context.read<AppDependencies>().videoWatchRepository,
                videoType: VideoWatchType.gutReset,
                videoRefId: video.itemId,
              ),
            )..initialize(),
            child: _WorkshopPlayerSystemUiGuard(
              child: _VideoLoaded(video: video, state: state),
            ),
          );
        },
      );
}

/// Matches the Masterclass screen's fullscreen cleanup on navigation away.
class _WorkshopPlayerSystemUiGuard extends StatefulWidget {
  const _WorkshopPlayerSystemUiGuard({required this.child});

  final Widget child;

  @override
  State<_WorkshopPlayerSystemUiGuard> createState() =>
      _WorkshopPlayerSystemUiGuardState();
}

class _WorkshopPlayerSystemUiGuardState
    extends State<_WorkshopPlayerSystemUiGuard> {
  @override
  void dispose() {
    _restoreSystemUi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _VideoLoaded extends StatelessWidget {
  const _VideoLoaded({required this.video, required this.state});

  final WorkshopVideo video;
  final WorkshopVideoState state;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<WorkshopPlaybackCubit, WorkshopPlaybackState>(
        listenWhen: (previous, next) =>
            previous.fullscreen != next.fullscreen,
        listener: (context, playback) {
          if (playback.fullscreen) {
            _enterFullscreenSystemUi();
          } else {
            _restoreSystemUi();
          }
        },
        builder: (context, playback) {
          final fullscreen = playback.fullscreen;
          return PopScope(
            canPop: !fullscreen,
            onPopInvokedWithResult: (didPop, _) {
              if (fullscreen) {
                context.read<WorkshopPlaybackCubit>().fullscreen(false);
              }
            },
            child: Scaffold(
              backgroundColor: fullscreen ? Colors.black : null,
              appBar: fullscreen
                  ? null
                  : PranaAppBar(title: 'Day ${video.day}', showBack: true),
              body: fullscreen
                  ? SafeArea(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(child: _PlayerSurface(fullscreen: true)),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: IconButton.filledTonal(
                              onPressed: () => context
                                  .read<WorkshopPlaybackCubit>()
                                  .fullscreen(false),
                              icon: const Icon(Icons.fullscreen_exit),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: ResponsiveContent(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _PlayerSurface(fullscreen: false),
                            _VideoInformation(video: video, state: state),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      );
}

class _VideoInformation extends StatelessWidget {
  const _VideoInformation({required this.video, required this.state});

  final WorkshopVideo video;
  final WorkshopVideoState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'DAY ${video.day} · VIDEO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 8),
          Text(video.heading, style: theme.textTheme.headlineSmall),
          if (video.summary.trim().isNotEmpty) ...[
            const SizedBox(height: 11),
            Text(
              video.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ],
          if (video.practiceHtml.trim().isNotEmpty) ...[
            const SizedBox(height: 21),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: .8),
                ),
              ),
              // Heading comes from description_html. Do not duplicate it.
              child: HtmlRichText(
                _tidyPracticeHtml(video.practiceHtml),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.55,
                ),
              ),
            ),
          ],
          const SizedBox(height: 19),
          FilledButton.icon(
            onPressed: state.marked || state.submitting
                ? null
                : context.read<WorkshopVideoCubit>().markDone,
            icon: state.submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(state.marked ? Icons.check_circle : Icons.check),
            label: Text(
              state.marked
                  ? 'Day ${video.day} completed'
                  : 'Mark Day ${video.day} as done',
            ),
          ),
          if (video.nextStart.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available_outlined,
                    color: scheme.onSurfaceVariant, size: 17),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    WorkshopDateFormatter.nextDay(
                      video.day + 1,
                      video.nextStart,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Strip indentation and empty HTML wrappers in the workshop response only.
/// Leave the shared Masterclass HTML renderer untouched.
String _tidyPracticeHtml(String input) {
  return input
      .replaceAll(
        RegExp(
          r'<div[^>]*>\s*(?:&nbsp;|&#160;|\u00a0|\s)*</div>',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'>\s+<'), '><')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({required this.fullscreen});

  final bool fullscreen;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WorkshopPlaybackCubit, WorkshopPlaybackState>(
        builder: (context, state) {
          final cubit = context.read<WorkshopPlaybackCubit>();
          final adapter = cubit.adapter;
          final snapshot = state.snapshot;
          if (adapter == null) {
            return const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.error != null) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: Text(state.error!)),
            );
          }

          final nativeControls = adapter.controlsMode == VideoControlsMode.native;
          final aspect = snapshot.aspectRatio <= 0 ? 16 / 9 : snapshot.aspectRatio;

          return ClipRRect(
            borderRadius: fullscreen
                ? BorderRadius.zero
                : BorderRadius.circular(14),
            child: ColoredBox(
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: aspect,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        adapter.buildView(),
                        if (!snapshot.initialized || snapshot.buffering)
                          const Center(child: CircularProgressIndicator()),
                        if (!nativeControls && !fullscreen)
                          Center(
                            child: IconButton.filledTonal(
                              onPressed: cubit.toggle,
                              iconSize: 34,
                              icon: Icon(
                                snapshot.playing ? Icons.pause : Icons.play_arrow,
                              ),
                            ),
                          ),
                        if (!fullscreen)
                          Positioned(
                            top: 7,
                            right: 7,
                            child: IconButton.filledTonal(
                              onPressed: () => cubit.fullscreen(true),
                              icon: const Icon(Icons.fullscreen),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!nativeControls)
                    _PlaybackControls(
                      snapshot: snapshot,
                      fullscreen: fullscreen,
                    ),
                ],
              ),
            ),
          );
        },
      );
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.snapshot,
    required this.fullscreen,
  });

  final VideoPlaybackSnapshot snapshot;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkshopPlaybackCubit>();
    final max = snapshot.duration.inMilliseconds.toDouble();
    final position = snapshot.position.inMilliseconds.clamp(
      0,
      snapshot.duration.inMilliseconds,
    ).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(children: [
        Slider(
          value: max <= 0 ? 0 : position,
          max: max <= 0 ? 1 : max,
          onChanged: max <= 0
              ? null
              : (value) =>
                  cubit.seek(Duration(milliseconds: value.round())),
        ),
        Row(children: [
          IconButton(
            onPressed: cubit.toggle,
            icon: Icon(
              snapshot.playing ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          Text(
            '${_time(snapshot.position)} / ${_time(snapshot.duration)}',
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => cubit.fullscreen(!fullscreen),
            icon: Icon(
              fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ]),
      ]),
    );
  }
}

String _time(Duration duration) {
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

Future<void> _enterFullscreenSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );
}

Future<void> _restoreSystemUi() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
}
