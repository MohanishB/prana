import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/checkout_amount_row.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../data/consult_checkout_models.dart';

/// Shown after "Book now": confirms the booking and opens the schedule page.
class ConsultationBookedScreen extends StatelessWidget {
  const ConsultationBookedScreen({required this.result, super.key});

  final ConsultationOrderResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheduleUrl = result.scheduleUrl;
    // The pages behind this one are out of date: leave only by the buttons.
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const PranaAppBar(),
        body: SingleChildScrollView(
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.bookingConfirmedTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.bookingConfirmedBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (result.simulated) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Center(child: Chip(label: Text(l10n.testOrderBadge))),
                ],
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.consultationLabel,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(result.title),
                        const Divider(height: AppSpacing.lg),
                        CheckoutAmountRow(
                          label: l10n.amountPaid,
                          value: result.paid.formatted,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          result.emailSent
                              ? l10n.scheduleEmailSent(result.email)
                              : l10n.scheduleEmailNotSent,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (scheduleUrl != null)
                  FilledButton(
                    onPressed: () => context.pushNamed(
                      RouteNames.consultationSchedule,
                      queryParameters: {
                        'url': scheduleUrl,
                        'title': result.title,
                      },
                    ),
                    child: Text(l10n.scheduleNow),
                  )
                else
                  Text(
                    l10n.scheduleNotReady,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(
                  onPressed: () => context.goNamed(RouteNames.consult),
                  child: Text(l10n.backToConsultations),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
