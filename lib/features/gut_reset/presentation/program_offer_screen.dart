import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/offer_page.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/gut_reset_models.dart';

/// 3-day / 7-day Gut Reset page. The data comes from the catalogue list, so
/// there is nothing to load here.
class ProgramOfferScreen extends StatelessWidget {
  const ProgramOfferScreen({required this.offer, super.key});

  final GutResetOffer offer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PranaAppBar(title: offer.title, showBack: true),
      body: SingleChildScrollView(
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OfferBanner(imageUrl: offer.imageUrl),
              const SizedBox(height: AppSpacing.md),
              Text(offer.title, style: theme.textTheme.titleLarge),
              if (offer.subTitle.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(offer.subTitle, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.xs),
              Text(
                offer.price.formatted,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.programDays(offer.days),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(offer.scheduleText, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              if (offer.canBook)
                FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.bookingComingSoon)),
                  ),
                  child: Text(l10n.bookThisProgram),
                )
              else
                Text(
                  l10n.programAlreadyBooked,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
