import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_pill.dart';
import '../bloc/masterclass_cubit.dart';
import '../data/masterclass_models.dart';

class MasterclassScreen extends StatelessWidget {
  const MasterclassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.masterclass),
      body: BlocBuilder<MasterclassCubit, MasterclassState>(
        builder: (context, state) {
          final section = state.section;
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
                    _Masterclasses(state: state),
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
  const _Masterclasses({required this.state});
  final MasterclassState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.loading && state.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.courses.isEmpty) {
      return AppErrorView(
        message: state.error!.userMessage(context),
        retryLabel: l10n.retry,
        onRetry: context.read<MasterclassCubit>().loadCourses,
      );
    }
    if (state.courses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(l10n.noMasterclasses),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < state.courses.length; i++) ...[
          _CourseCard(
            course: state.courses[i],
            onTap: () => context.goNamed(
              RouteNames.course,
              pathParameters: {'courseId': '${state.courses[i].id}'},
            ),
          ),
          if (i != state.courses.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
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
  const _CourseCard({required this.course, required this.onTap});
  final MasterclassCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = course.progressPercent.clamp(0, 100) / 100;
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
                        '${course.progressPercent}%',
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
                    Text(course.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.chapterProgress(
                        course.completedChapters,
                        course.totalChapters,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (course.shortDescription.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        course.shortDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (course.certificateGenerated) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TextButton.icon(
                        onPressed: () => context.pushNamed(
                          RouteNames.certificate,
                          pathParameters: {'certificateId': '${course.id}'},
                          queryParameters: {
                            'title': course.title,
                            if (course.certificateDownloadUrl.isNotEmpty)
                              'url': course.certificateDownloadUrl,
                            if (course.certificateGeneratedOn.isNotEmpty)
                              'generatedOn': course.certificateGeneratedOn,
                          },
                        ),
                        icon: const Icon(Icons.workspace_premium_outlined),
                        label: Text(l10n.certificateReady),
                      ),
                    ],
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
