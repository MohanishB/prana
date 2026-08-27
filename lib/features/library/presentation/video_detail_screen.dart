import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../domain/library_video.dart';

class VideoDetailScreen extends StatelessWidget {
  const VideoDetailScreen({required this.video, super.key});

  final LibraryVideo video;

  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: video.youtubeVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );

    return Scaffold(
      appBar: PranaAppBar(title: video.title, showBack: true),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: YoutubePlayer(controller: controller),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                video.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.transcript,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(video.transcript),
            ],
          ),
        ),
      ),
    );
  }
}
