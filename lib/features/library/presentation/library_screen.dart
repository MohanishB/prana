import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/library_bloc.dart';
import '../domain/library_video.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.library),
      body: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              textInputAction: TextInputAction.search,
              autocorrect: false,
              onChanged: (value) => context
                  .read<LibraryBloc>()
                  .add(LibraryQueryChanged(value)),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.librarySearchHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.librarySearchDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  return switch (state) {
                    LibraryLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    LibraryFailure(:final error, :final query) => AppErrorView(
                        message: error.userMessage(context),
                        retryLabel: l10n.retry,
                        onRetry: () {
                          final bloc = context.read<LibraryBloc>();
                          if (query.isEmpty) {
                            bloc.add(const LibraryStarted());
                          } else {
                            bloc.add(LibrarySearchSubmitted(query));
                          }
                        },
                      ),
                    LibraryLoaded(
                      :final videos,
                      :final query,
                      :final nextPageToken,
                      :final isSearching,
                      :final isLoadingMore,
                    ) =>
                      _LibraryResults(
                        videos: videos,
                        query: query,
                        nextPageToken: nextPageToken,
                        isSearching: isSearching,
                        isLoadingMore: isLoadingMore,
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryResults extends StatefulWidget {
  const _LibraryResults({
    required this.videos,
    required this.query,
    required this.nextPageToken,
    required this.isSearching,
    required this.isLoadingMore,
  });

  final List<LibraryVideo> videos;
  final String query;
  final String? nextPageToken;
  final bool isSearching;
  final bool isLoadingMore;

  @override
  State<_LibraryResults> createState() => _LibraryResultsState();
}

class _LibraryResultsState extends State<_LibraryResults> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _LibraryResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSearching && !widget.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.videos.isEmpty && widget.isSearching) {
      return _SearchLoadingStatus(query: widget.query);
    }
    if (widget.videos.isEmpty) {
      return Column(
        children: [
          if (widget.query.trim().isNotEmpty)
            _SearchCompleteStatus(count: 0),
          Expanded(
            child: Center(child: Text(l10n.libraryNoResults)),
          ),
        ],
      );
    }

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: widget.isSearching
              ? _SearchLoadingStatus(
                  key: const ValueKey('library-searching'),
                  query: widget.query,
                  compact: true,
                )
              : widget.query.trim().isNotEmpty
                  ? _SearchCompleteStatus(
                      key: const ValueKey('library-search-complete'),
                      count: widget.videos.length,
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('library-search-idle'),
                    ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 500 &&
                  widget.nextPageToken != null &&
                  !widget.isLoadingMore) {
                context
                    .read<LibraryBloc>()
                    .add(const LibraryLoadMoreRequested());
              }
              return false;
            },
            child: ListView.separated(
              controller: _scrollController,
              itemCount: widget.videos.length + (widget.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == widget.videos.length) {
                  return _LoadMoreStatus(
                    label: l10n.libraryLoadingMore,
                  );
                }

                final video = widget.videos[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.pushNamed(
                      RouteNames.libraryVideo,
                      pathParameters: {'videoId': video.id},
                      extra: LibraryPlaybackArgs(
                        videos: widget.videos,
                        initialIndex: index,
                        query: widget.query,
                        nextPageToken: widget.nextPageToken,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _Thumbnail(video: video),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  video.durationLabel,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                                if (video.description.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    video.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchLoadingStatus extends StatelessWidget {
  const _SearchLoadingStatus({
    required this.query,
    this.compact = false,
    super.key,
  });

  final String query;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final queryText = query.trim();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: compact ? AppSpacing.sm : 0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: compact ? 22 : 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.librarySearching,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (queryText.isNotEmpty && !compact) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '“$queryText”',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchCompleteStatus extends StatelessWidget {
  const _SearchCompleteStatus({
    required this.count,
    super.key,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.librarySearchComplete(count),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreStatus extends StatelessWidget {
  const _LoadMoreStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video});

  final LibraryVideo video;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 124,
        height: 78,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (video.thumbnailUrl.isNotEmpty)
              Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => _fallback(context),
              )
            else
              _fallback(context),
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.08),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Icon(Icons.play_arrow),
    );
  }
}
