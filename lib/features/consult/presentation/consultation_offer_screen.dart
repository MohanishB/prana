import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/offer_page.dart';
import '../bloc/consultation_detail_cubit.dart';

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
                const SizedBox(height: AppSpacing.xl),
                if (data.alreadyBooked)
                  Text(
                    l10n.alreadyBooked,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(content: Text(l10n.bookingComingSoon)),
                    ),
                    child: Text(l10n.bookConsultation),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
