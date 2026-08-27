import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/library_bloc.dart';

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
                            bloc.add(LibraryQueryChanged(query));
                          }
                        },
                      ),
                    LibraryLoaded(:final videos) when videos.isEmpty => Center(
                        child: Text(l10n.libraryNoResults),
                      ),
                    LibraryLoaded(:final videos) => ListView.separated(
                        itemCount: videos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          return Card(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.all(AppSpacing.sm),
                              leading: Container(
                                width: AppSizes.thumbnailWidth,
                                height: AppSizes.thumbnailHeight,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(Icons.play_arrow),
                              ),
                              title: Text(video.title),
                              subtitle: Text(
                                '${video.durationLabel} · '
                                '${video.tags.join(', ')}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.pushNamed(
                                RouteNames.libraryVideo,
                                pathParameters: {'videoId': video.id},
                                extra: video,
                              ),
                            ),
                          );
                        },
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
