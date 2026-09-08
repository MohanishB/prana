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
                  const Positioned(
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
    super.key,
  });

  final LibraryVideo video;
  final bool isActive;

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
                    child: controller == null
                        ? _VideoPoster(video: video)
                        : ValueListenableBuilder<YoutubePlayerValue>(
                            valueListenable: controller,
                            builder: (context, value, _) {
                              if (value.hasError) {
                                return _PlaybackFallback(video: video);
                              }

                              return YoutubePlayer(
                                controller: controller,
                                aspectRatio: playerAspectRatio,
                                showVideoProgressIndicator: true,
                                progressIndicatorColor:
                                    Theme.of(context).colorScheme.primary,
                                bottomActions: const [
                                  CurrentPosition(),
                                  ProgressBar(isExpanded: true),
                                  RemainingDuration(),
                                  FullScreenButton(),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _VideoMetadataOverlay(video: video),
            ),
          ],
        );
      },
    );
  }

}

class _VideoMetadataOverlay extends StatelessWidget {
  const _VideoMetadataOverlay({required this.video});

  final LibraryVideo video;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.72),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (video.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
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

