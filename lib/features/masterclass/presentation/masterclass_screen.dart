import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/offer_card.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../gut_reset/bloc/gut_reset_offers_cubit.dart';
import '../../workshops/presentation/workshop_list.dart';
import '../bloc/masterclass_cubit.dart';
import '../bloc/masterclass_offers_cubit.dart';
import '../data/masterclass_models.dart';
import 'widgets/cart_action_button.dart';

class MasterclassScreen extends StatelessWidget {
  const MasterclassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // A guest has no purchases: only the programs / masterclasses to book are shown.
    final guest = context.watch<AuthBloc>().state is AuthGuest;

    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.masterclass,
        actions: const [CartActionButton()],
      ),
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
                    _WorkshopsSection(guest: guest)
                  else
                    _MasterclassesSection(guest: guest, state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Workshops tab: the student's programs (logged in), then programs to book.
class _WorkshopsSection extends StatelessWidget {
  const _WorkshopsSection({required this.guest});
  final bool guest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!guest) const WorkshopList(),
        BlocBuilder<GutResetOffersCubit, GutResetOffersState>(
          builder: (context, state) {
            final offers = state.bookable;
            if (offers.isEmpty) {
              if (state.loading) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state.error != null) {
                return AppErrorView(
                  message: state.error!.userMessage(context),
                  retryLabel: l10n.retry,
                  onRetry: context.read<GutResetOffersCubit>().load,
                );
              }
              return guest
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l10n.nothingToBook),
                    )
                  : const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: guest
                      ? l10n.programsYouCanBook
                      : l10n.bookAnotherProgram,
                ),
                const SizedBox(height: AppSpacing.xs),
                CardColumn(
                  children: [
                    for (final offer in offers)
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
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Masterclasses tab: the student's masterclasses (logged in), then ones to buy.
class _MasterclassesSection extends StatelessWidget {
  const _MasterclassesSection({required this.guest, required this.state});
  final bool guest;
  final MasterclassState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!guest) _Masterclasses(state: state),
        BlocBuilder<MasterclassOffersCubit, MasterclassOffersState>(
          builder: (context, offersState) {
            final offers = offersState.offers;
            if (offers.isEmpty) {
              if (offersState.error != null) {
                return AppErrorView(
                  message: offersState.error!.userMessage(context),
                  retryLabel: l10n.retry,
                  onRetry: context.read<MasterclassOffersCubit>().load,
                );
              }
              if (!offersState.loaded) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return guest
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(l10n.nothingToBook),
                    )
                  : const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: guest
                      ? l10n.masterclassesYouCanBook
                      : l10n.availableToBook,
                ),
                const SizedBox(height: AppSpacing.xs),
                CardColumn(
                  children: [
                    for (final offer in offers)
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
                if (guest) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.masterclassesLifetime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            );
          },
        ),
      ],
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
