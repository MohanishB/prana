import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/bloc/catalog_refresh_cubit.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/offer_page.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/gut_reset_checkout_cubit.dart';
import '../data/gut_reset_models.dart';

/// 3-day / 7-day Gut Reset page. The data comes from the catalogue list, so
/// there is nothing to load here. "Book now" (test mode) records a paid booking.
class ProgramOfferScreen extends StatelessWidget {
  const ProgramOfferScreen({required this.offer, super.key});

  final GutResetOffer offer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GutResetCheckoutCubit(context.read<AppDependencies>().gutResetRepository),
      child: _OfferBody(offer: offer),
    );
  }
}

class _OfferBody extends StatelessWidget {
  const _OfferBody({required this.offer});

  final GutResetOffer offer;

  Future<void> _book(BuildContext context) async {
    final l10n = context.l10n;
    final signedIn =
        context.read<AppDependencies>().sessionManager.current != null;
    if (!signedIn) {
      // A guest enters the details first.
      context.pushNamed(
        RouteNames.gutResetCheckout,
        pathParameters: {'type': offer.type},
        extra: offer,
      );
      return;
    }
    final cubit = context.read<GutResetCheckoutCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.gutResetConfirmTitle),
        content: Text(l10n.gutResetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.bookNow),
          ),
        ],
      ),
    );
    if (ok == true) cubit.book(offer.type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocListener<GutResetCheckoutCubit, GutResetCheckoutState>(
      listenWhen: (a, b) => a.result == null && b.result != null,
      listener: (context, state) {
        context.read<CatalogRefreshCubit>().refresh();
        context.pushReplacementNamed(
          RouteNames.gutResetBooked,
          extra: state.result,
        );
      },
      child: Scaffold(
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
              ],
            ),
          ),
        ),
        // Book now stays fixed at the bottom.
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            child: BlocBuilder<GutResetCheckoutCubit, GutResetCheckoutState>(
              builder: (context, state) {
                if (!offer.canBook) {
                  return Text(
                    l10n.programAlreadyBooked,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.error != null) ...[
                      Text(
                        state.error!.userMessage(context),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    FilledButton(
                      onPressed: state.placing ? null : () => _book(context),
                      child: state.placing
                          ? const SizedBox.square(
                              dimension: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.bookThisProgram),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
