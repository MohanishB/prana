import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_pill.dart';
import '../bloc/masterclass_cubit.dart';

class MasterclassScreen extends StatelessWidget {
  const MasterclassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.masterclass),
      body: BlocBuilder<MasterclassCubit, MasterclassSection>(
        builder: (context, section) {
          return SingleChildScrollView(
            child: ResponsiveContent(
              child: Column(
                children: [
                  SegmentedButton<MasterclassSection>(
                    segments: [
                      ButtonSegment(
                        value: MasterclassSection.workshops,
                        label: Text(l10n.workshops),
                      ),
                      ButtonSegment(
                        value: MasterclassSection.masterclasses,
                        label: Text(l10n.masterclasses),
                      ),
                    ],
                    selected: {section},
                    onSelectionChanged: (value) =>
                        context.read<MasterclassCubit>().select(value.first),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (section == MasterclassSection.workshops)
                    const _Workshops()
                  else
                    const _Masterclasses(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Workshops extends StatelessWidget {
  const _Workshops();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        _WorkshopCard(
          title: l10n.sevenDayGutReset,
          subtitle: l10n.gutResetProgress,
          status: l10n.day3Open,
          progress: .29,
        ),
        const SizedBox(height: AppSpacing.md),
        _WorkshopCard(
          title: l10n.threeDayImmunityBooster,
          subtitle: l10n.immunityUnlock,
          status: l10n.startsTomorrow,
          progress: 0,
        ),
        const SizedBox(height: AppSpacing.md),
        const _DoneCard(),
      ],
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  const _WorkshopCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final String status;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: AppSizes.workshopHeroHeight,
            padding: const EdgeInsets.all(AppSpacing.sm),
            alignment: Alignment.topLeft,
            decoration: const BoxDecoration(gradient: AppGradients.hero),
            child: StatusPill(
              label: status,
              background: AppColors.white,
              foreground: AppColors.brick,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: ListTile(
        title: Text(l10n.fiveDaySleepRitual),
        subtitle: Text(l10n.sleepRitualCompleted),
        trailing: StatusPill(
          label: l10n.done,
          background: AppColors.successContainer,
          foreground: AppColors.success,
          icon: Icons.check,
        ),
      ),
    );
  }
}

class _Masterclasses extends StatelessWidget {
  const _Masterclasses();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        _CourseCard(
          progress: .42,
          title: l10n.ayurvedaHerbalism,
          subtitle: l10n.courseProgressPending,
          badge: l10n.resumeChapter3,
          onTap: () => context.goNamed(
            RouteNames.course,
            pathParameters: const {'courseId': 'ayurveda-herbalism'},
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CourseCard(
          progress: 1,
          title: l10n.ayurvedicNutrition,
          subtitle: l10n.allChaptersComplete,
          badge: l10n.certificateReady,
          onTap: () => context.pushNamed(
            RouteNames.certificate,
            pathParameters: const {'certificateId': 'nutrition-001'},
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CourseCard(
          progress: 0,
          title: l10n.herbsWomensHealth,
          subtitle: l10n.sixChaptersDuration,
          badge: l10n.notStarted,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.masterclassesLifetime,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.onTap,
  });

  final double progress;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox.square(
                dimension: AppSizes.progressRing,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: AppSizes.progressStroke,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      badge,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.brick,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
