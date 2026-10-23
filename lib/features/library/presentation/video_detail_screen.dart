import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
    super.key,
  });

  final LibraryVideo video;
  final bool isActive;
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
    _controller?.dispose();
    _controller = null;

    if (!widget.isActive) return;

    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        loop: true,
        enableCaption: true,
        controlsVisibleAtStart: false,
        hideControls: false,
        useHybridComposition: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final controller = _controller;

    if (controller == null) {
      return _buildFeedLayout(
        context,
        player: _VideoPoster(video: video),
        controller: null,
      );
    }

    final player = YoutubePlayer(
      controller: controller,
      aspectRatio: video.isShortForm ? 9 / 16 : 16 / 9,
      showVideoProgressIndicator: false,
      topActions: const [],
      bottomActions: [
        CurrentPosition(controller: controller),
        ProgressBar(
          controller: controller,
          isExpanded: true,
        ),
        RemainingDuration(controller: controller),
        FullScreenButton(controller: controller),
      ],
    );

    if (video.isShortForm) {
      return _buildFeedLayout(
        context,
        player: _PlayerWithErrorFallback(
          controller: controller,
          video: video,
          player: player,
        ),
        controller: controller,
      );
    }

    // youtube_player_flutter 9.x automatically enters fullscreen when a
    // regular video is rotated to landscape when wrapped by the builder.
    return YoutubePlayerBuilder(
      player: player,
      builder: (context, builtPlayer) {
        return _buildFeedLayout(
          context,
          player: _PlayerWithErrorFallback(
            controller: controller,
            video: video,
            player: builtPlayer,
          ),
          controller: controller,
        );
      },
    );
  }

  Widget _buildFeedLayout(
    BuildContext context, {
    required Widget player,
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

        if (isLandscape) {
          // Natural device rotation should be reversible without entering the
          // YouTube fullscreen mode, which can lock the platform orientation.
          // In landscape we therefore make regular videos occupy the feed
          // viewport directly and keep PRANA seek/fullscreen controls on top.
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
              if (controller != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _PlayerSeekControls(
                    controller: controller,
                    allowFullscreen: true,
                  ),
                ),
            ],
          );
        }

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

class _PlayerWithErrorFallback extends StatelessWidget {
  const _PlayerWithErrorFallback({
    required this.controller,
    required this.video,
    required this.player,
  });

  final YoutubePlayerController controller;
  final LibraryVideo video;
  final Widget player;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        player,
        ValueListenableBuilder<YoutubePlayerValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (!value.hasError) return const SizedBox.shrink();
            return _PlaybackFallback(video: video);
          },
        ),
      ],
    );
  }
}

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
        if (controller != null)
          _PlayerSeekControls(
            controller: controller!,
            allowFullscreen: !video.isShortForm,
          ),
        _VideoMetadataOverlay(
          video: video,
          isExpanded: isDescriptionExpanded,
          onToggleDescription: onToggleDescription,
        ),
      ],
    );
  }
}

class _PlayerSeekControls extends StatelessWidget {
  const _PlayerSeekControls({
    required this.controller,
    required this.allowFullscreen,
  });

  final YoutubePlayerController controller;
  final bool allowFullscreen;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.72),
      child: ValueListenableBuilder<YoutubePlayerValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final duration = value.metaData.duration;
          final durationMs = duration.inMilliseconds;
          final positionMs = value.position.inMilliseconds
              .clamp(0, durationMs > 0 ? durationMs : 0);
          final maxMs = durationMs > 0 ? durationMs.toDouble() : 1.0;

          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                PlayPauseButton(controller: controller),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: maxMs,
                    value: positionMs.toDouble().clamp(0, maxMs),
                    onChanged: durationMs <= 0
                        ? null
                        : (newValue) {
                            controller.seekTo(
                              Duration(milliseconds: newValue.round()),
                            );
                          },
                  ),
                ),
                if (allowFullscreen) ...[
                  const SizedBox(width: AppSpacing.xs),
                  FullScreenButton(
                    controller: controller,
                    color: Colors.white,
                  ),
                ],
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
