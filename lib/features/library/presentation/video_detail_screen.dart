import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../bloc/library_feed_cubit.dart';
import '../domain/library_video.dart';

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({super.key});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  PageController? _pageController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController ??= PageController(
      initialPage: context.read<LibraryFeedCubit>().state.currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<LibraryFeedCubit, LibraryFeedState>(
          builder: (context, state) {
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.videos.length,
                  onPageChanged:
                      context.read<LibraryFeedCubit>().pageChanged,
                  itemBuilder: (context, index) {
                    final video = state.videos[index];
                    return _LibraryFeedPage(
                      key: ValueKey(video.id),
                      video: video,
                      isActive: index == state.currentIndex,
                      onSwipe: (delta) {
                        final target = index + delta;
                        if (target < 0 || target >= state.videos.length) {
                          return;
                        }
                        _pageController?.animateToPage(
                          target,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      isDescriptionExpanded:
                          state.expandedDescriptionVideoId == video.id,
                      onToggleDescription: () => context
                          .read<LibraryFeedCubit>()
                          .toggleDescription(video.id),
                    );
                  },
                ),
                Positioned(
                  left: AppSpacing.xs,
                  top: AppSpacing.xs,
                  child: IconButton.filledTonal(
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                if (state.isLoadingMore)
                  Positioned(
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LibraryFeedPage extends StatefulWidget {
  const _LibraryFeedPage({
    required this.video,
    required this.isActive,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
    required this.onSwipe,
    super.key,
  });

  final LibraryVideo video;
  final bool isActive;
  final void Function(int delta) onSwipe;
  final bool isDescriptionExpanded;
  final VoidCallback onToggleDescription;

  @override
  State<_LibraryFeedPage> createState() => _LibraryFeedPageState();
}

class _LibraryFeedPageState extends State<_LibraryFeedPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant _LibraryFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.video.youtubeVideoId != widget.video.youtubeVideoId) {
      _syncController();
    }
  }

  void _syncController() {
    _controller?.close().ignore();
    _controller = null;

    if (!widget.isActive) return;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        // PRANA draws its own controls, so YouTube's are hidden.
        showControls: false,
        showFullscreenButton: false,
        loop: true,
        enableCaption: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFeedLayout(context, controller: _controller);
  }

  /// The player draws its video in an overlay above the app, so anything that
  /// must sit on top of the video (controls, swipe, error message) is
  /// returned from here and is drawn inside that overlay.
  Widget _buildControlsLayer(
    YoutubePlayerController controller,
    _ChromeMode mode,
  ) {
    return YoutubeValueBuilder(
      controller: controller,
      buildWhen: (o, n) =>
          o.hasError != n.hasError || o.playerState != n.playerState,
      builder: (context, value) {
        if (value.hasError) {
          return _PlaybackFallback(video: widget.video);
        }

        final Widget chrome = switch (mode) {
          _ChromeMode.none => const SizedBox.shrink(),
          _ChromeMode.seekOnly => _PlayerSeekControls(controller: controller),
          _ChromeMode.full => _FeedBottomChrome(
              video: widget.video,
              controller: controller,
              isDescriptionExpanded: widget.isDescriptionExpanded,
              onToggleDescription: widget.onToggleDescription,
            ),
        };

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (value.playerState == PlayerState.playing) {
              controller.pauseVideo();
            } else {
              controller.playVideo();
            }
          },
          onVerticalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -250) {
              widget.onSwipe(1);
            } else if (velocity > 250) {
              widget.onSwipe(-1);
            }
          },
          child: Align(
            alignment: Alignment.bottomCenter,
            child: chrome,
          ),
        );
      },
    );
  }

  Widget _buildFeedLayout(
    BuildContext context, {
    required YoutubePlayerController? controller,
  }) {
    final video = widget.video;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortForm = video.isShortForm;
        final playerAspectRatio = shortForm ? 9 / 16 : 16 / 9;
        final tabletPortraitWidth = constraints.maxWidth > 700
            ? constraints.maxWidth * 0.58
            : constraints.maxWidth;
        final portraitWidth = tabletPortraitWidth
            .clamp(
              0.0,
              constraints.maxHeight * playerAspectRatio,
            )
            .toDouble();

        final isLandscape =
            constraints.maxWidth > constraints.maxHeight && !shortForm;

        final mode = controller == null
            ? _ChromeMode.none
            : isLandscape
                ? _ChromeMode.seekOnly
                : shortForm
                    ? _ChromeMode.full
                    : _ChromeMode.none;

        final Widget player = controller == null
            ? _VideoPoster(video: video)
            : YoutubePlayer(
                controller: controller,
                aspectRatio: playerAspectRatio,
                backgroundColor: Colors.black,
                // PRANA handles rotation itself: in landscape the video
                // fills the screen, so the player's own fullscreen is off.
                autoFullScreen: false,
                enableFullScreenOnVerticalDrag: false,
                controlsBuilder: (context, isFullscreen) =>
                    _buildControlsLayer(controller, mode),
              );

        if (isLandscape) {
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              Center(
                child: AspectRatio(
                  aspectRatio: playerAspectRatio,
                  child: ColoredBox(
                    color: Colors.black,
                    child: player,
                  ),
                ),
              ),
            ],
          );
        }

        // Short-form videos with a live player show their chrome inside the
        // player overlay; everything else shows it in the page itself.
        final chromeInPage = !(shortForm && controller != null);

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: shortForm ? portraitWidth : constraints.maxWidth,
                child: AspectRatio(
                  aspectRatio: playerAspectRatio,
                  child: ColoredBox(
                    color: Colors.black,
                    child: player,
                  ),
                ),
              ),
            ),
            if (chromeInPage)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _FeedBottomChrome(
                  video: video,
                  controller: controller,
                  isDescriptionExpanded: widget.isDescriptionExpanded,
                  onToggleDescription: widget.onToggleDescription,
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _ChromeMode { none, seekOnly, full }

class _FeedBottomChrome extends StatelessWidget {
  const _FeedBottomChrome({
    required this.video,
    required this.controller,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
  });

  final LibraryVideo video;
  final YoutubePlayerController? controller;
  final bool isDescriptionExpanded;
  final VoidCallback onToggleDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller != null) _PlayerSeekControls(controller: controller!),
        _VideoMetadataOverlay(
          video: video,
          isExpanded: isDescriptionExpanded,
          onToggleDescription: onToggleDescription,
        ),
      ],
    );
  }
}

class _PlayerSeekControls extends StatefulWidget {
  const _PlayerSeekControls({required this.controller});

  final YoutubePlayerController controller;

  @override
  State<_PlayerSeekControls> createState() => _PlayerSeekControlsState();
}

class _PlayerSeekControlsState extends State<_PlayerSeekControls> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.72),
      child: YoutubeValueBuilder(
        controller: controller,
        buildWhen: (o, n) =>
            o.playerState != n.playerState ||
            o.metaData.duration != n.metaData.duration,
        builder: (context, value) {
          final durationMs = value.metaData.duration.inMilliseconds;
          final maxMs = durationMs > 0 ? durationMs.toDouble() : 1.0;
          final playing = value.playerState == PlayerState.playing ||
              value.playerState == PlayerState.buffering;

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                IconButton(
                  color: Colors.white,
                  onPressed: () {
                    if (playing) {
                      controller.pauseVideo();
                    } else {
                      controller.playVideo();
                    }
                  },
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: StreamBuilder<YoutubeVideoState>(
                    stream: controller.videoStateStream,
                    initialData: const YoutubeVideoState(),
                    builder: (context, snapshot) {
                      final positionMs = (_dragMs ??
                              (snapshot.data?.position.inMilliseconds ?? 0)
                                  .toDouble())
                          .clamp(0.0, maxMs)
                          .toDouble();

                      return Slider(
                        min: 0,
                        max: maxMs,
                        value: positionMs,
                        onChanged: durationMs <= 0
                            ? null
                            : (newValue) =>
                                setState(() => _dragMs = newValue),
                        onChangeEnd: durationMs <= 0
                            ? null
                            : (newValue) {
                                controller.seekTo(
                                  seconds: newValue / 1000,
                                  allowSeekAhead: true,
                                );
                                setState(() => _dragMs = null);
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VideoMetadataOverlay extends StatelessWidget {
  const _VideoMetadataOverlay({
    required this.video,
    required this.isExpanded,
    required this.onToggleDescription,
  });

  final LibraryVideo video;
  final bool isExpanded;
  final VoidCallback onToggleDescription;

  @override
  Widget build(BuildContext context) {
    final description = video.description;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.78),
            Colors.black,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                video.title,
                maxLines: isExpanded ? 4 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleDescription,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isExpanded)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.sizeOf(context).height * 0.38,
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.45,
                                  ),
                            ),
                          ),
                        )
                      else
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            size: 16,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            isExpanded
                                ? context.l10n.libraryCollapseDescription
                                : context.l10n.libraryExpandDescription,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (!isExpanded) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.keyboard_double_arrow_up,
                      size: 16,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        context.l10n.librarySwipeForMore,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPoster extends StatelessWidget {
  const _VideoPoster({required this.video});

  final LibraryVideo video;

  @override
  Widget build(BuildContext context) {
    if (video.thumbnailUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 56,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          video.thumbnailUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 56,
          ),
        ),
      ],
    );
  }
}

class _PlaybackFallback extends StatelessWidget {
  const _PlaybackFallback({required this.video});

  final LibraryVideo video;

  Future<void> _openYouTube() async {
    final uri = Uri.https(
      'www.youtube.com',
      '/watch',
      {'v': video.youtubeVideoId},
    );
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _VideoPoster(video: video),
        ColoredBox(
          color: Colors.black.withValues(alpha: 0.72),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_disabled_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.libraryPlaybackUnavailable,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: _openYouTube,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(context.l10n.libraryWatchOnYoutube),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
