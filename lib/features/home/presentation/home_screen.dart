import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/workshop_date_formatter.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/offer_card.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_pill.dart';
import '../../masterclass/data/masterclass_models.dart';
import '../../workshops/data/workshop_models.dart';
import '../bloc/home_cubit.dart';
import '../data/home_models.dart';

/// Home, in this order:
///  1. the student's name (logged in only)
///  2. Gut Reset: the student's running/upcoming programs, then programs to book
///  3. Masterclasses: the student's own first, then the ones they can book
///  4. Consultations
/// A guest sees the same sections with only the bookable items.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<AppDependencies>().sessionManager.current;
    final firstName = session?.firstName.trim() ?? '';

    return Scaffold(
      appBar: const PranaAppBar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final home = state.home;
          final Widget content;
          if (home != null) {
            content = _HomeSections(home: home);
          } else if (state.loading) {
            content = const Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            content = AppErrorView(
              message:
                  state.error?.userMessage(context) ?? l10n.errorGeneric,
              retryLabel: l10n.retry,
              onRetry: context.read<HomeCubit>().load,
            );
          }

          return RefreshIndicator(
            onRefresh: context.read<HomeCubit>().load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM').format(DateTime.now())
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.brick,
                            letterSpacing: AppTypography.eyebrowLetterSpacing,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (session != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l10n.namasteUser(
                          firstName.isEmpty ? l10n.friendFallback : firstName,
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    content,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeSections extends StatelessWidget {
  const _HomeSections({required this.home});

  final HomeData home;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final running = home.runningPrograms;
    final programOffers = home.bookableGutReset;
    final hasGutReset = running.isNotEmpty || programOffers.isNotEmpty;
    final hasMasterclasses =
        home.bookedCourses.isNotEmpty || home.masterclasses.isNotEmpty;

    if (!hasGutReset && !hasMasterclasses && home.consultations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(l10n.nothingToBook, textAlign: TextAlign.center),
      );
    }

    // The first program with an open day becomes the hero card.
    WorkshopProgram? hero;
    for (final program in running) {
      if (program.currentDay != null) {
        hero = program;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasGutReset) ...[
          SectionHeader(title: l10n.gutResetPrograms),
          const SizedBox(height: AppSpacing.xs),
          CardColumn(
            children: [
              if (hero != null) _ProgramHero(program: hero),
              for (final program in running)
                if (!identical(program, hero)) _ProgramCard(program: program),
              for (final offer in programOffers)
                OfferCard(
                  icon: Icons.calendar_month_outlined,
                  title: offer.title,
                  subtitle: offer.scheduleText,
                  price: offer.price.formatted,
                  onTap: () => context.pushNamed(
                    RouteNames.programOffer,
                    pathParameters: {'type': offer.type},
                    extra: offer,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (hasMasterclasses) ...[
          SectionHeader(
            title: l10n.masterclasses,
            actionLabel: l10n.seeAll,
            onAction: () => context.goNamed(RouteNames.masterclass),
          ),
          const SizedBox(height: AppSpacing.xs),
          CardColumn(
            children: [
              for (final course in home.bookedCourses)
                _BookedCourseCard(course: course),
              for (final offer in home.masterclasses)
                OfferCard(
                  icon: Icons.school_outlined,
                  title: offer.title,
                  subtitle: offer.shortDescription,
                  price: offer.price.formatted,
                  onTap: () => context.pushNamed(
                    RouteNames.masterclassOffer,
                    pathParameters: {'courseId': '${offer.courseId}'},
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (home.consultations.isNotEmpty) ...[
          SectionHeader(
            title: l10n.consultations,
            actionLabel: l10n.seeAll,
            onAction: () => context.goNamed(RouteNames.consult),
          ),
          const SizedBox(height: AppSpacing.xs),
          CardColumn(
            children: [
              for (final offer in home.consultations)
                OfferCard(
                  icon: Icons.monitor_heart_outlined,
                  title: offer.title,
                  subtitle: offer.shortDescription,
                  price: offer.price.formatted,
                  onTap: () => context.pushNamed(
                    RouteNames.consultationOffer,
                    pathParameters: {
                      'consultationId': '${offer.consultationId}',
                    },
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The program that has a day open right now.
class _ProgramHero extends StatelessWidget {
  const _ProgramHero({required this.program});

  final WorkshopProgram program;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final day = program.currentDay!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: AppGradients.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(
            label: l10n.dayOpenNow(day.number, program.totalDays),
            background: AppColors.whiteOverlay,
            foreground: AppColors.white,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            program.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                ),
          ),
          if (day.heading.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              day.heading,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.whiteMuted,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.brick,
            ),
            onPressed: () => context.pushNamed(
              RouteNames.workshopDayVideo,
              pathParameters: {
                'bookingId': '${program.bookingId}',
                'itemId': '${day.itemId}',
              },
            ),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.playTodaysVideo),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final WorkshopProgram program;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final next = program.nextUnlock;
    final subtitle = next != null && program.status == 'upcoming'
        ? WorkshopDateFormatter.nextDay(next.number, next.startsAt)
        : l10n.programDays(program.totalDays);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.pushNamed(
          RouteNames.workshopDetail,
          pathParameters: {'bookingId': '${program.bookingId}'},
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.event_available, size: AppSizes.iconSmall),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(program.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// A masterclass the student already owns (same idea as the old "Keep going" card).
class _BookedCourseCard extends StatelessWidget {
  const _BookedCourseCard({required this.course});

  final MasterclassCourse course;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.pushNamed(
          RouteNames.course,
          pathParameters: {'courseId': '${course.id}'},
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: AppSizes.progressRing,
                height: AppSizes.thumbnailHeight,
                decoration: BoxDecoration(
                  color: AppColors.forest2,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.play_arrow, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.chapterProgress(
                        course.completedChapters,
                        course.totalChapters,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: course.progressPercent.clamp(0, 100) / 100,
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
