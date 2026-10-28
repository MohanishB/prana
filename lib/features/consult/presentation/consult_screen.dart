import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/offer_card.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/consult_cubit.dart';

/// Consult tab: the consultations that can be booked (guest or student).
class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.consult,
        // Booked consultations only exist for a signed-in student.
        actions: [
          if (context.watch<AuthBloc>().state is AuthAuthenticated)
            IconButton(
              tooltip: l10n.myConsultations,
              onPressed: () => context.pushNamed(RouteNames.myConsultations),
              icon: const Icon(Icons.event_available_outlined),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: context.read<ConsultCubit>().load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.consultations,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.consultListSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<ConsultCubit, ConsultState>(
                  builder: (context, state) {
                    if (state.consultations.isNotEmpty) {
                      return CardColumn(
                        children: [
                          for (final offer in state.consultations)
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
                      );
                    }
                    if (state.loading || (!state.loaded && state.error == null)) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xxxl),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.error != null) {
                      return AppErrorView(
                        message: state.error!.userMessage(context),
                        retryLabel: l10n.retry,
                        onRetry: context.read<ConsultCubit>().load,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        l10n.nothingToBook,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
