import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/offer_page.dart';
import '../bloc/masterclass_cart_cubit.dart';
import '../bloc/masterclass_offer_detail_cubit.dart';
import '../data/masterclass_checkout_models.dart';
import '../data/masterclass_offer_models.dart';
import 'widgets/cart_action_button.dart';

/// Masterclass page for someone who has not bought it (guest or student):
/// details, "Buy now" and "Add to cart".
class MasterclassOfferScreen extends StatelessWidget {
  const MasterclassOfferScreen({required this.courseId, super.key});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MasterclassOfferDetailCubit(
        context.read<AppDependencies>().masterclassOfferRepository,
        courseId,
      )..load(),
      child: const _MasterclassOfferBody(),
    );
  }
}

class _MasterclassOfferBody extends StatelessWidget {
  const _MasterclassOfferBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MasterclassOfferDetailCubit,
        MasterclassOfferDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        return OfferPageScaffold(
          title: detail?.offer.title ?? l10n.masterclass,
          loading: state.loading,
          error: state.error,
          hasData: detail != null,
          onRetry: context.read<MasterclassOfferDetailCubit>().load,
          actions: const [CartActionButton()],
          bottomBar: _BottomBar(detail: detail),
          content: (context) => _Content(detail: detail!),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail});

  final MasterclassOfferDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final offer = detail.offer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OfferBanner(imageUrl: detail.bannerUrl ?? offer.thumbnailUrl),
        const SizedBox(height: AppSpacing.md),
        Text(offer.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(offer.price.formatted, style: theme.textTheme.headlineSmall),
        if (offer.priceNote.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(offer.priceNote, style: theme.textTheme.bodySmall),
        ],
        if (offer.shortDescription.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(offer.shortDescription, style: theme.textTheme.bodyMedium),
        ],
        OfferHtmlSection(title: '', html: detail.descriptionHtml),
        OfferHtmlSection(title: detail.aboutTitle, html: detail.aboutHtml),
        OfferHtmlSection(title: detail.termsTitle, html: detail.termsHtml),
        const SizedBox(height: AppSpacing.md),
        if (!detail.alreadyBooked && !detail.canBook)
          Text(
            l10n.notAvailableToBuy,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
      ],
    );
  }
}

/// Buy now and Add to cart, always visible at the bottom, side by side.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.detail});

  /// Null while the page is loading: the buttons are shown but disabled.
  final MasterclassOfferDetail? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = detail;
    if (data != null && data.alreadyBooked) {
      return FilledButton(
        onPressed: () => context.goNamed(
          RouteNames.course,
          pathParameters: {'courseId': '${data.offer.courseId}'},
        ),
        child: Text(l10n.openMasterclass),
      );
    }
    final offer = data?.offer;
    final enabled = data != null && data.canBook;
    return BlocBuilder<MasterclassCartCubit, MasterclassCartState>(
      builder: (context, cart) {
        final inCart = offer != null && cart.contains(offer.courseId);
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: !enabled
                    ? null
                    : inCart
                        ? () => context.pushNamed(RouteNames.masterclassCart)
                        : () => context.read<MasterclassCartCubit>().add(
                              CartItem(
                                courseId: offer!.courseId,
                                title: offer.title,
                                thumbnailUrl: offer.thumbnailUrl,
                                price: offer.price,
                              ),
                            ),
                child: Text(inCart ? l10n.goToCart : l10n.addToCart),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: !enabled
                    ? null
                    : () => context.pushNamed(
                          RouteNames.masterclassCheckout,
                          extra: CheckoutArgs(
                            courseIds: [offer!.courseId],
                            mode: CheckoutMode.single,
                          ),
                        ),
                child: Text(l10n.buyNow),
              ),
            ),
          ],
        );
      },
    );
  }
}
