import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_pill.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chapters = [
      _ChapterViewData(
        number: '00',
        title: l10n.courseIntro,
        subtitle: l10n.watchFirst4Min,
        progress: 1,
        status: l10n.done,
      ),
      _ChapterViewData(
        number: '01',
        title: l10n.foundationsAyurvedaHerbalism,
        subtitle: l10n.threeVideosNotes,
        progress: 1,
        status: l10n.done,
      ),
      _ChapterViewData(
        number: '02',
        title: l10n.doshasDhatusBalance,
        subtitle: l10n.fiveVideosQuizNotes,
        progress: 1,
        status: l10n.done,
      ),
      _ChapterViewData(
        number: '03',
        title: l10n.sankhyaGunasHealing,
        subtitle: l10n.fourVideosQuizPending,
        progress: .55,
        status: l10n.resume,
        isActive: true,
      ),
      _ChapterViewData(
        number: '04',
        title: l10n.spicesForWellness,
        subtitle: l10n.sixVideosQuizNotes,
        progress: 0,
        status: l10n.notStarted,
      ),
    ];

    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.ayurvedaHerbalism,
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: AppGradients.hero,
                ),
                child: Text(
                  l10n.masterclassEyebrow,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        letterSpacing: AppTypography.certificateLetterSpacing,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final chapter in chapters) ...[
                _ChapterCard(data: chapter),
                const SizedBox(height: AppSpacing.md),
              ],
              OutlinedButton.icon(
                onPressed: () => context.pushNamed(
                  RouteNames.certificate,
                  pathParameters: const {'certificateId': 'ah-4821'},
                ),
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(l10n.certificate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterViewData {
  const _ChapterViewData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.status,
    this.isActive = false,
  });

  final String number;
  final String title;
  final String subtitle;
  final double progress;
  final String status;
  final bool isActive;
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.data});

  final _ChapterViewData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.number,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(data.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(value: data.progress),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            StatusPill(
              label: data.status,
              background: data.isActive
                  ? AppColors.errorContainer
                  : AppColors.successContainer,
              foreground:
                  data.isActive ? AppColors.brick : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
