import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../data/masterclass_checkout_models.dart';

/// Shown after "Buy now". Explains how to sign in (a new student gets the
/// default password) and where the courses are.
class MasterclassOrderSuccessScreen extends StatelessWidget {
  const MasterclassOrderSuccessScreen({required this.result, super.key});

  final MasterclassOrderResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final guest = context.watch<AuthBloc>().state is AuthGuest;
    // The purchase page behind this one is out of date: leave only by the buttons.
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
                  l10n.orderSuccessTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.orderSuccessBody,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.coursesAdded,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        for (final title in result.courses)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xxs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check, size: 16),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(child: Text(title)),
                              ],
                            ),
                          ),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.amountPaid),
                            Text(
                              result.paid.formatted,
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (guest) ...[
                  const SizedBox(height: AppSpacing.md),
                  _AccountCard(result: result),
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
                    onPressed: () => context.goNamed(RouteNames.masterclass),
                    child: Text(l10n.openMyMasterclasses),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.result});

  final MasterclassOrderResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final password = result.defaultPassword;
    final newAccount = result.newStudent && password != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (newAccount) ...[
              Text(l10n.newAccountTitle, style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              SelectableText(l10n.newAccountBody(result.email, password)),
            ] else
              Text(l10n.existingAccountBody),
            const SizedBox(height: AppSpacing.xs),
            Text(
              result.emailSent
                  ? l10n.checkEmailNote(result.email)
                  : l10n.emailNotSentNote,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
