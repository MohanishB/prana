import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: const PranaAppBar(),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeDateLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.brick,
                      letterSpacing: AppTypography.eyebrowLetterSpacing,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.namasteUser(l10n.accountUserName.split(' ').first),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _TodayHero(
                onPlay: () => context.goNamed(RouteNames.masterclass),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.keepGoing,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton(
                    onPressed: () => context.goNamed(RouteNames.masterclass),
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
              const _ContinueCard(),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet =
                      constraints.maxWidth >= AppSizes.tabletBreakpoint;
                  final cards = [
                    _QuickAction(
                      icon: Icons.calendar_month_outlined,
                      title: l10n.bookConsultation,
                      subtitle: l10n.doctorDietPlan,
                      onTap: () => context.goNamed(RouteNames.consult),
                    ),
                    _QuickAction(
                      icon: Icons.school_outlined,
                      title: l10n.browseMasterclasses,
                      subtitle: l10n.coursesAndWorkshops,
                      onTap: () => context.goNamed(RouteNames.masterclass),
                    ),
                  ];

                  if (isTablet) {
                    return Row(
                      children: [
                        Expanded(child: cards.first),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: cards.last),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards.first),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: cards.last),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            label: l10n.dayOpenStatus,
            background: AppColors.whiteOverlay,
            foreground: AppColors.white,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.gutResetAgni,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.closesIn('17h 37m'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.whiteMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.brick,
            ),
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.playTodaysVideo),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
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
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ayurvedaHerbalism,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.chapter3Sankhya,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const LinearProgressIndicator(value: .42),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                child: Icon(icon, size: AppSizes.iconSmall),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
