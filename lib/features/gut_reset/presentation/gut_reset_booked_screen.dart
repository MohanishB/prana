import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/checkout_amount_row.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../data/gut_reset_order_models.dart';

/// Shown after "Book now" for a Gut Reset: when it starts (3-day) or how to
/// start it (7-day), and, for a new student, the sign-in details.
class GutResetBookedScreen extends StatelessWidget {
  const GutResetBookedScreen({required this.result, super.key});

  final GutResetOrderResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final guest = context.watch<AuthBloc>().state is AuthGuest;
    final startsOn = result.startsOn;
    final body = startsOn != null
        ? l10n.gutResetBookedStarts(DateFormat('EEEE, d MMM').format(startsOn))
        : l10n.gutResetBookedStartWhenReady;
    final password = result.defaultPassword;
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
                  body,
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
                        Text(result.title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.programDays(result.days)),
                        const Divider(height: AppSpacing.lg),
                        CheckoutAmountRow(
                          label: l10n.amountPaid,
                          value: result.paid.formatted,
                        ),
                      ],
                    ),
                  ),
                ),
                if (guest) ...[
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: result.newStudent && password != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.newAccountTitle,
                                    style: theme.textTheme.titleSmall),
                                const SizedBox(height: AppSpacing.xs),
                                SelectableText(
                                  l10n.newAccountBody(result.email, password),
                                ),
                              ],
                            )
                          : Text(l10n.existingAccountBody),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (guest)
                  FilledButton(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthLoginRequested()),
                    child: Text(l10n.signInToStart),
                  )
                else
                  FilledButton(
                    // The student's programs are listed in the Masterclass tab.
                    onPressed: () => context.goNamed(RouteNames.masterclass),
                    child: Text(l10n.openMyPrograms),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
