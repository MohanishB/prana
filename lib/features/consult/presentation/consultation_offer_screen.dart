import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/offer_page.dart';
import '../bloc/consultation_detail_cubit.dart';
import '../data/consult_models.dart';

/// Consultation page (guest or student).
class ConsultationOfferScreen extends StatelessWidget {
  const ConsultationOfferScreen({required this.consultationId, super.key});

  final int consultationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsultationDetailCubit(
        context.read<AppDependencies>().consultRepository,
        consultationId,
      )..load(),
      child: const _ConsultationOfferBody(),
    );
  }
}

class _ConsultationOfferBody extends StatelessWidget {
  const _ConsultationOfferBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<ConsultationDetailCubit, ConsultationDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        return OfferPageScaffold(
          title: detail?.offer.title ?? l10n.consult,
          loading: state.loading,
          error: state.error,
          hasData: detail != null,
          onRetry: context.read<ConsultationDetailCubit>().load,
          bottomBar: _BottomBar(detail: detail),
          content: (context) {
            final data = detail!;
            final offer = data.offer;
            final theme = Theme.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OfferBanner(imageUrl: offer.imageUrl),
                const SizedBox(height: AppSpacing.md),
                Text(offer.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  offer.price.formatted,
                  style: theme.textTheme.headlineSmall,
                ),
                if (offer.shortDescription.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    offer.shortDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                OfferHtmlSection(title: '', html: data.descriptionHtml),
                OfferHtmlSection(title: data.aboutTitle, html: data.aboutHtml),
                OfferHtmlSection(title: data.termsTitle, html: data.termsHtml),
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        );
      },
    );
  }
}

/// "Book now", always visible at the bottom of the page.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.detail});

  /// Null while the page is loading: the button is shown but disabled.
  final ConsultationOfferDetail? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = detail;
    if (data != null && data.alreadyBooked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.alreadyBooked,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          FilledButton(
            onPressed: () => context.pushNamed(RouteNames.myConsultations),
            child: Text(l10n.myConsultations),
          ),
        ],
      );
    }
    return FilledButton(
      onPressed: data == null || !data.canBook
          ? null
          : () => context.pushNamed(
                RouteNames.consultationCheckout,
                pathParameters: {
                  'consultationId': '${data.offer.consultationId}',
                },
              ),
      child: Text(l10n.bookNow),
    );
  }
}
