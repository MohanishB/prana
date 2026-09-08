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

class _LibraryResults extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (videos.isEmpty && isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (videos.isEmpty) {
      return Center(child: Text(l10n.libraryNoResults));
    }

    return Column(
      children: [
        if (isSearching)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 500 &&
                  nextPageToken != null &&
                  !isLoadingMore) {
                context
                    .read<LibraryBloc>()
                    .add(const LibraryLoadMoreRequested());
              }
              return false;
            },
            child: ListView.separated(
              itemCount: videos.length + (isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == videos.length) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final video = videos[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.pushNamed(
                      RouteNames.libraryVideo,
                      pathParameters: {'videoId': video.id},
                      extra: LibraryPlaybackArgs(
                        videos: videos,
                        initialIndex: index,
                        query: query,
                        nextPageToken: nextPageToken,
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.video});

  final LibraryVideo video;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: 112,
        height: 72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (video.thumbnailUrl.isNotEmpty)
              Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(context),
              )
            else
              _fallback(context),
            ColoredBox(
              color: Colors.black..withValues(alpha: 0.08),
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
